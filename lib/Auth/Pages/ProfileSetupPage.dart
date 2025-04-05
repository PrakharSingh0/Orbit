import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:orbit/Pages/HomeFeed/HomePageMain.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

extension Capitalize on String {
  String capitalize() {
    if (isEmpty) return this;
    return split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _userTagController = TextEditingController();
  final _dobController = TextEditingController();
  final _locationController = TextEditingController();
  final _genderController = TextEditingController();
  final _professionController = TextEditingController();

  bool _isLoading = false;
  String? _userTagError;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _userTagController.addListener(_onUserTagChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _userTagController.removeListener(_onUserTagChanged);
    _userNameController.dispose();
    _userTagController.dispose();
    _dobController.dispose();
    _locationController.dispose();
    _genderController.dispose();
    _professionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      final formatted = "${_monthName(picked.month)} ${picked.day}, ${picked.year}";
      setState(() => _dobController.text = formatted);
    }
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  Future<bool> _isUserTagAvailable(String userTag) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('userTags')
        .doc(userTag)
        .get();
    return !snapshot.exists;
  }

  void _onUserTagChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 600), () async {
      final rawInput = _userTagController.text.trim();
      final formattedTag = rawInput.replaceAll(' ', '-').toLowerCase();

      if (formattedTag.isEmpty || formattedTag.length < 3) {
        if (mounted) {
          setState(() => _userTagError = null);
        }
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('userTags')
          .doc(formattedTag)
          .get();

      if (!mounted) return;

      setState(() {
        _userTagError = doc.exists ? "Username is already taken" : null;
      });
    });
  }

  Future<void> _completeProfile() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final formattedTag = _userTagController.text.trim().replaceAll(' ', '-').toLowerCase();
    final isAvailable = await _isUserTagAvailable(formattedTag);

    if (!isAvailable) {
      setState(() => _userTagError = "Username is already taken");
      return;
    }

    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final data = {
      'userName': _userNameController.text.trim().capitalize(),
      'userTag': formattedTag,
      'dob': _dobController.text.trim(),
      'location': _locationController.text.trim(),
      'gender': _genderController.text.trim(),
      'profession': _professionController.text.trim(),
      'profileCompleted': true,
    };

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(data, SetOptions(merge: true));

      await FirebaseFirestore.instance
          .collection('userTags')
          .doc(formattedTag)
          .set({'uid': user.uid});

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePageMain()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Something went wrong: ${e.toString()}")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 80),
                Text(
                  "Complete Your Profile",
                  style: TextStyle(
                    fontSize: size.width * 0.08,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ).animate().fade().slideY(),

                const SizedBox(height: 10),
                Text(
                  "Let’s get to know you",
                  style: TextStyle(
                    fontSize: size.width * 0.04,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ).animate().fade(duration: 700.ms),

                const SizedBox(height: 40),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _userNameController,
                        label: "Full Name",
                        icon: Icons.person_outline,
                        isDark: isDark,
                        validator: (v) => v!.isEmpty ? "Enter your name" : null,
                      ),
                      const SizedBox(height: 20),

                      _buildTextField(
                        controller: _userTagController,
                        label: "Username",
                        icon: Icons.alternate_email,
                        isDark: isDark,
                        errorText: _userTagError,
                        validator: (v) {
                          if (v!.isEmpty) return "Enter a username";
                          if (v.length < 3) return "Minimum 3 characters";
                          return _userTagError;
                        },
                        suffixIcon: _userTagController.text.trim().length >= 3
                            ? _userTagError == null
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : const Icon(Icons.cancel, color: Colors.red)
                            : null,
                      ),
                      const SizedBox(height: 20),

                      _buildTextField(
                        controller: _dobController,
                        label: "Date of Birth",
                        icon: Icons.cake_outlined,
                        isDark: isDark,
                        readOnly: true,
                        onTap: _selectDate,
                        validator: (v) => v!.isEmpty ? "Select your DOB" : null,
                      ),
                      const SizedBox(height: 20),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            "Gender",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      _genderSelector(isDark),
                      const SizedBox(height: 20),

                      _buildTextField(
                        controller: _professionController,
                        label: "Job / Profession",
                        icon: Icons.work_outline,
                        isDark: isDark,
                        validator: (v) => v!.isEmpty ? "Enter your profession" : null,
                      ),
                      const SizedBox(height: 20),

                      _buildTextField(
                        controller: _locationController,
                        label: "Location (City, State)",
                        icon: Icons.location_on_outlined,
                        isDark: isDark,
                        validator: (v) => v!.isEmpty ? "Enter your location" : null,
                      ),
                      const SizedBox(height: 30),

                      _buildButton("Complete Profile", _completeProfile, isDark),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    String? errorText,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: isDark ? Colors.white70 : Colors.black87),
        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDark ? Colors.white12 : Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        errorText: errorText,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: isDark ? Colors.white : Colors.black),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed, bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _genderSelector(bool isDark) {
    final genders = [
      {'label': 'Male', 'icon': Icons.male},
      {'label': 'Female', 'icon': Icons.female},
      {'label': 'Other', 'icon': Icons.transgender},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: genders.map((gender) {
        final label = gender['label'] as String;
        final isSelected = _genderController.text == label;

        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark ? Colors.white : Colors.black)
                  : (isDark ? Colors.transparent : Colors.grey[200]),
              borderRadius: BorderRadius.circular(30),
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: isDark
                      ? Colors.white.withOpacity(0.3)
                      : Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ]
                  : [],
              border: Border.all(
                color: isSelected
                    ? (isDark ? Colors.white : Colors.black)
                    : (isDark ? Colors.white30 : Colors.black26),
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () => setState(() => _genderController.text = label),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      gender['icon'] as IconData,
                      size: 20,
                      color: isSelected
                          ? (isDark ? Colors.black : Colors.white)
                          : (isDark ? Colors.white70 : Colors.black87),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: isSelected
                            ? (isDark ? Colors.black : Colors.white)
                            : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
