import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

// ... [keep existing imports]
import 'package:flutter/services.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController jobController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final FocusNode usernameFocus = FocusNode();

  DateTime? selectedDOB;
  String selectedGender = "Male";
  File? _profileImage;
  String? profileImageUrl;
  File? _bannerImage;
  String? bannerImageUrl;

  bool isLoading = true;
  bool isUsernameUnique = true;
  bool isCheckingUsername = false;
  String? originalTag;
  bool isUploading = false;

  final picker = ImagePicker();
  final user = FirebaseAuth.instance.currentUser;
  final firestore = FirebaseFirestore.instance;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    usernameController.addListener(_onUsernameChanged);
    usernameFocus.addListener(() {
      if (!usernameFocus.hasFocus) {
        _checkUsernameUniqueness(usernameController.text.trim().toLowerCase());
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    usernameController.removeListener(_onUsernameChanged);
    usernameFocus.dispose();
    super.dispose();
  }

  void _onUsernameChanged() {
    final input = usernameController.text.trim().toLowerCase();
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (input != originalTag?.toLowerCase()) {
        _checkUsernameUniqueness(input);
      }
    });
  }

  Future<void> _fetchUserData() async {
    if (user == null) return;

    final doc = await firestore.collection("users").doc(user!.uid).get();
    final data = doc.data();

    if (data != null) {
      final rawDob = data['dob'];
      if (rawDob is Timestamp) {
        selectedDOB = rawDob.toDate();
      } else if (rawDob is String && rawDob.trim().isNotEmpty) {
        try {
          selectedDOB = DateFormat("MMM d, yyyy").parse(rawDob);
        } catch (_) {}
      }

      setState(() {
        nameController.text = data['userName'] ?? '';
        usernameController.text = data['userTag'] ?? '';
        originalTag = data['userTag'];
        bioController.text = data['bio'] ?? '';
        jobController.text = data['profession'] ?? '';
        locationController.text = data['location'] ?? '';
        selectedGender = data['gender'] ?? 'Prefer not to say';
        isLoading = false;
        profileImageUrl = data['profilePictureUrl'];
        bannerImageUrl = data['bannerImageUrl'];
      });
    }
  }

  Future<void> _checkUsernameUniqueness(String username) async {
    if (username.isEmpty || username == originalTag?.toLowerCase()) {
      setState(() => isUsernameUnique = true);
      return;
    }

    setState(() => isCheckingUsername = true);
    final doc = await firestore.collection("userTags").doc(username).get();
    setState(() {
      isUsernameUnique = !doc.exists;
      isCheckingUsername = false;
    });
  }

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _profileImage = File(picked.path));
    }
  }

  Future<void> _pickBannerImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _bannerImage = File(picked.path));
    }
  }

  Future<void> _pickDOB() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDOB ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => selectedDOB = picked);
    }
  }

  Future<void> _saveProfile() async {
    if (user == null || !isUsernameUnique) return;

    setState(() => isUploading = true);
    _showUploadingDialog();

    String? uploadedImageUrl;
    String? uploadedBannerUrl;

    if (_profileImage != null) {
      uploadedImageUrl = await _uploadToCloudinary(_profileImage!);
    }

    if (_bannerImage != null) {
      uploadedBannerUrl = await _uploadToCloudinary(_bannerImage!);
    }

    if ((uploadedImageUrl == null && _profileImage != null) ||
        (uploadedBannerUrl == null && _bannerImage != null)) {
      _hideUploadingDialog();
      setState(() => isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to upload image(s)")),
      );
      return;
    }

    final trimmedTag = usernameController.text.trim().toLowerCase();
    final updatedData = {
      "userName": nameController.text.trim(),
      "userTag": trimmedTag,
      "bio": bioController.text.trim(),
      "profession": jobController.text.trim(),
      "location": locationController.text.trim(),
      "gender": selectedGender,
      "dob": selectedDOB != null ? DateFormat("MMM d, yyyy").format(selectedDOB!) : null,
    };

    if (uploadedImageUrl != null) {
      updatedData["profilePictureUrl"] = uploadedImageUrl;
    }

    if (uploadedBannerUrl != null) {
      updatedData["bannerImageUrl"] = uploadedBannerUrl;
    }

    try {
      await firestore.collection("users").doc(user!.uid).update(updatedData);
      await firestore.collection("userTags").doc(trimmedTag).set({'uid': user!.uid});

      if (trimmedTag != originalTag?.toLowerCase() && originalTag != null) {
        await firestore.collection("userTags").doc(originalTag!.toLowerCase()).delete();
      }

      _hideUploadingDialog();
      setState(() => isUploading = false);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      _hideUploadingDialog();
      setState(() => isUploading = false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating profile: $e")),
        );
      }
    }
  }

  Future<String?> _uploadToCloudinary(File file) async {
    try {
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        minWidth: 300,
        minHeight: 300,
        quality: 50,
        format: CompressFormat.webp,
      );

      if (compressedBytes == null) return null;

      final uri = Uri.parse('https://api.cloudinary.com/v1_1/orbit-01/image/upload');
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = 'orbit-upload Preset'
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            compressedBytes,
            filename: 'upload.webp',
            contentType: MediaType('image', 'webp'),
          ),
        );

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final json = jsonDecode(responseBody);
        return json['secure_url'];
      } else {
        print('Upload failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  void _showUploadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _hideUploadingDialog() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded),
            onPressed: isUsernameUnique ? _saveProfile : null,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              // 🔷 Banner Image with Edit Icon
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: _bannerImage != null
                        ? FileImage(_bannerImage!)
                        : (bannerImageUrl != null && bannerImageUrl!.isNotEmpty)
                        ? NetworkImage(bannerImageUrl!) as ImageProvider
                        : const AssetImage('assets/background_placeholder.png'),
                    fit: BoxFit.cover,
                  ),
                  color: Colors.grey[300],
                ),

          child: (_bannerImage == null && bannerImageUrl == null)
                    ? const Center(
                  child: Icon(Icons.photo_library_outlined, size: 36, color: Colors.black45),
                )
                    : Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.25), Colors.transparent],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              // 🔧 Banner Edit Icon
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: _pickBannerImage,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.edit, size: 18, color: Theme.of(context).primaryColor),
                  ),
                ),
              ),

              // 🧑 Profile Avatar - Centered
              Positioned(
                bottom: -35,
                right: 6,
                child: Align(
                  alignment: Alignment.center,
                  child: GestureDetector(onTap: _pickImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : (profileImageUrl != null
                                ? NetworkImage(profileImageUrl!)
                                : const AssetImage("assets/avatar_placeholder.png")) as ImageProvider,
                          ),
                        ),
                        Positioned(
                          bottom: 6,
                          right: 6,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: Colors.black26, blurRadius: 4),
                                ],
                              ),
                              child: Icon(Icons.edit, size: 18, color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
//
// // 🔻 Space to push content below avatar
//           const SizedBox(height: 30),

          const SizedBox(height: 50),
          _buildField(context, controller: nameController, label: "Full Name", icon: Icons.person_outline),
          _buildUserTagField(context),
          _buildField(context, controller: bioController, label: "Bio", icon: Icons.info_outline, maxLines: 3),
          _buildField(context, controller: jobController, label: "Profession", icon: Icons.work_outline),
          _buildField(context, controller: locationController, label: "Location", icon: Icons.location_on_outlined),
          const SizedBox(height: 16),
          _buildTile(
            context,
            title: "Date of Birth",
            subtitle: selectedDOB != null ? DateFormat("MMM d, yyyy").format(selectedDOB!) : "Not set",
            icon: Icons.cake_outlined,
            onTap: _pickDOB,
          ),
          const SizedBox(height: 12),
          _buildGenderPickerTile(),
        ],
      ),
    );
  }


  Widget _buildField(BuildContext context,
      {required TextEditingController controller, required String label, required IconData icon, int maxLines = 1}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: theme.iconTheme.color),
          labelText: label,
          labelStyle: const TextStyle(fontWeight: FontWeight.w500),
          filled: true,
          fillColor: theme.cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: theme.dividerColor),
          ),
        ),
      ),
    );
  }

  Widget _buildUserTagField(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: usernameController,
            focusNode: usernameFocus,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.alternate_email, color: theme.iconTheme.color),
              labelText: "Username",
              labelStyle: const TextStyle(fontWeight: FontWeight.w500),
              filled: true,
              fillColor: theme.cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: theme.dividerColor),
              ),
            ),
          ),
          const SizedBox(height: 6),
          if (isCheckingUsername)
            Text("Checking availability...", style: TextStyle(color: theme.hintColor, fontSize: 12)),
          if (!isUsernameUnique && !isCheckingUsername)
            const Text("This username is already taken", style: TextStyle(color: Colors.red, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context,
      {required String title,
        required String subtitle,
        required IconData icon,
        required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      leading: Icon(icon, color: theme.iconTheme.color),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(color: theme.hintColor)),
      trailing: Icon(Icons.keyboard_arrow_right_rounded, color: theme.iconTheme.color),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildGenderPickerTile() {
    final theme = Theme.of(context);
    final genderIcons = {
      "Male": Icons.male_rounded,
      "Female": Icons.female_rounded,
      "Others": Icons.transgender_rounded,
      "Prefer not to say": Icons.help_outline_rounded,
    };

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      leading: Icon(genderIcons[selectedGender], color: theme.iconTheme.color),
      title: const Text("Gender", style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(selectedGender, style: TextStyle(color: theme.hintColor)),
      trailing: Icon(Icons.keyboard_arrow_right_rounded, color: theme.iconTheme.color),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: _showGenderPickerBottomSheet,
    );
  }

  void _showGenderPickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Theme.of(context).cardColor,
      builder: (context) {
        final genderOptions = [
          {"label": "Male", "icon": Icons.male_rounded},
          {"label": "Female", "icon": Icons.female_rounded},
          {"label": "Others", "icon": Icons.transgender_rounded},
          {"label": "Prefer not to say", "icon": Icons.help_outline_rounded},
        ];

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              height: 4,
              width: 40,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                "Select Gender",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              itemCount: genderOptions.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (context, index) {
                final option = genderOptions[index];
                final isSelected = selectedGender == option["label"];
                return ListTile(
                  leading: Icon(option["icon"] as IconData, color: Colors.blueGrey),
                  title: Text(option["label"] as String),
                  trailing: isSelected
                      ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary)
                      : null,
                  onTap: () {
                    setState(() => selectedGender = option["label"] as String);
                    Navigator.pop(context);
                  },
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}
