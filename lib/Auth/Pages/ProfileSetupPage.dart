import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:orbit/Pages/HomeFeed/HomePageMain.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({Key? key}) : super(key: key);

  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
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
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userTagController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  bool _isLoading = false;
  String? _userTagError;

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _dobController.text = "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
      });
    }
  }

  Future<bool> _isUserTagAvailable(String userTag) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('userTags')
        .doc(userTag)
        .get();
    return !snapshot.exists;
  }

  Future<void> _completeProfile() async {
    setState(() => _userTagError = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String userTag = _userTagController.text.trim();
    bool isAvailable = await _isUserTagAvailable(userTag);

    if (!isAvailable) {
      setState(() {
        _userTagError = "Username is already taken";
        _isLoading = false;
      });
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userData = {
      'userName': _userNameController.text.trim().capitalize(),
      'userTag': userTag.replaceAll(' ', '-').toLowerCase(),
      'dob': _dobController.text.trim(),
      'location': _locationController.text.trim(),
      'profileCompleted': true,
    };

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(userData, SetOptions(merge: true));
      await FirebaseFirestore.instance.collection('userTags').doc(userTag).set({'uid': user.uid});
      if (mounted) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePageMain(),
            ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Complete Your Profile",
                style: TextStyle(
                  fontSize: screenSize.width * 0.08,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ).animate().fade(duration: 500.ms).slideY(),

              const SizedBox(height: 10),

              Text(
                "Fill in the details to continue",
                style: TextStyle(
                  fontSize: screenSize.width * 0.04,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
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
                      validator: (value) => value!.isEmpty ? "Enter your name" : null,
                    ),

                    const SizedBox(height: 20),

                    _buildTextField(
                      controller: _userTagController,
                      label: "Username",
                      icon: Icons.alternate_email,
                      isDark: isDark,
                      errorText: _userTagError,
                      validator: (value) {
                        if (value!.isEmpty) return "Enter a username";
                        if (value.length < 3) return "Username must be at least 3 characters";
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    _buildTextField(
                      controller: _dobController,
                      label: "Date of Birth",
                      icon: Icons.calendar_today_outlined,
                      isDark: isDark,
                      readOnly: true,
                      onTap: _selectDate,
                      validator: (value) => value!.isEmpty ? "Select your date of birth" : null,
                    ),

                    const SizedBox(height: 20),

                    _buildTextField(
                      controller: _locationController,
                      label: "Location (City, State)",
                      icon: Icons.location_on_outlined,
                      isDark: isDark,
                      validator: (value) => value!.isEmpty ? "Enter your location" : null,
                    ),

                    const SizedBox(height: 30),

                    _isLoading
                        ? CircularProgressIndicator()
                        : _buildButton("Complete Profile", _completeProfile, isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
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
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        prefixIcon: Icon(icon, color: isDark ? Colors.white70 : Colors.black87),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        errorText: errorText,
      ),
      validator: validator,
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed, bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(text, style: TextStyle(fontSize: 16, color: isDark ? Colors.black : Colors.white)),
      ),
    );
  }
}
