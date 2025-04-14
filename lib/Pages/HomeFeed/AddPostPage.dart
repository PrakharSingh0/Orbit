import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class CloudinaryService {
  static const _cloudName = 'orbit-01';
  static const _uploadPreset = 'orbit-upload Preset';

  static Future<String> uploadImage(File imageFile) async {
    // Compress the image before upload
    final compressedImageBytes = await FlutterImageCompress.compressWithFile(
      imageFile.path,
      quality: 60,
      format: CompressFormat.jpeg,
    );

    if (compressedImageBytes == null) {
      throw Exception('Image compression failed');
    }

    // Save compressed image to a temporary file
    final tempDir = Directory.systemTemp;
    final compressedFile = File('${tempDir.path}/compressed_image.jpg');
    await compressedFile.writeAsBytes(compressedImageBytes);

    // Upload compressed image
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = _uploadPreset
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        compressedFile.readAsBytesSync(),
        filename: 'compressed_image.jpg',
        contentType: MediaType('image', 'jpeg'),
      ));

    final response = await request.send();
    final res = await http.Response.fromStream(response);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['secure_url'];
    } else {
      throw Exception('Cloudinary upload failed: ${res.body}');
    }
  }
}


class AddPostPage extends StatefulWidget {
  const AddPostPage({Key? key}) : super(key: key);

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final _captionController = TextEditingController();
  final _bodyController = TextEditingController();
  final _linkController = TextEditingController();

  File? _selectedImage;
  bool _isPosting = false;
  bool _showLinkField = false;

  String? _userName;
  String? _userTag;
  String? _profilePicUrl;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          _userName = data['userName'] ?? 'User';
          _userTag = data['userTag'] ?? '';
          _profilePicUrl = data['profilePictureUrl'];
        });
      }
    }
  }

  Future<void> _pickImage({required ImageSource source}) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  void _submitPost() async {
    final caption = _captionController.text.trim();
    final body = _bodyController.text.trim();
    final String link = _linkController.text.trim();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (caption.isEmpty && body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add both caption & body text.")),
      );
      return;
    }

    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in to post.")),
      );
      return;
    }

    setState(() => _isPosting = true);

    try {
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await CloudinaryService.uploadImage(_selectedImage!);
      }

      final postData = {
        'uid': uid,
        'userName': _userName,
        'userTag': _userTag,
        'profilePictureUrl': _profilePicUrl,
        'caption': caption,
        'body': body,
        'link': link,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      };

      final postRef = await FirebaseFirestore.instance.collection('posts').add(postData);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('posts')
          .doc(postRef.id)
          .set(postData);

      setState(() {
        _isPosting = false;
        _captionController.clear();
        _bodyController.clear();
        _linkController.clear();
        _selectedImage = null;
        _showLinkField = false;
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post submitted successfully!")),
      );
    } catch (e) {
      setState(() => _isPosting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to post: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = DateFormat('dd MMMM yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: _isPosting ? null : _submitPost,
              icon: const Icon(Icons.send_rounded, size: 20),
              label: const Text("Post"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundImage: (_profilePicUrl != null &&
                            _profilePicUrl!.isNotEmpty)
                            ? NetworkImage(_profilePicUrl!)
                            : const AssetImage("assets/avatar_placeholder.png")
                        as ImageProvider,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Text(
                              _userName ?? "Loading...",
                              style: GoogleFonts.akshar(
                                  fontSize: 22, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _userTag != null ? "@$_userTag" : "",
                              style: GoogleFonts.sanchez(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.onSurface
                                    .withAlpha((0.4 * 255).toInt()),
                              ),
                            ),
                          ]),
                          Text(
                            date,
                            style: GoogleFonts.aBeeZee(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: theme.colorScheme.onSurface
                                  .withAlpha((0.8 * 255).toInt()),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _captionController,
                    maxLines: 1,
                    maxLength: 100,
                    style: GoogleFonts.poppins(
                        fontSize: 24, fontWeight: FontWeight.w800),
                    decoration: InputDecoration(
                      counterStyle: const TextStyle(fontSize: 10,),
                      hintText: "What's New",
                      filled: true,
                      fillColor: theme.cardColor,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  TextField(
                    controller: _bodyController,
                    maxLines: null,
                    minLines: 1,
                    maxLength: 1000,
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: "Write your thoughts...",
                      filled: true,
                      fillColor: theme.cardColor,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_selectedImage != null)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(_selectedImage!,
                              width: double.infinity, fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedImage = null),
                            child: const CircleAvatar(
                              backgroundColor: Colors.black54,
                              radius: 16,
                              child: Icon(Icons.close,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (_selectedImage != null) const SizedBox(height: 16),
                  if (_showLinkField)
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: theme.colorScheme.onSurface,
                          ),
                          borderRadius: BorderRadius.circular(12)),
                      child: TextField(
                        controller: _linkController,
                        style: GoogleFonts.sanchez(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface
                                .withAlpha((0.4 * 255).toInt())),
                        decoration: InputDecoration(
                          hintText: "Add an external link",
                          prefixIcon: const Icon(Icons.link_outlined),
                          filled: true,
                          fillColor: theme.cardColor,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.onSurface
                      .withAlpha((0.2 * 255).toInt()),
                  offset: const Offset(0, -0.1),
                  blurRadius: 8,
                )
              ],
            ),
            child: Row(
              children: [
                _iconButton(Icons.photo_library_outlined,
                        () => _pickImage(source: ImageSource.gallery)),
                const SizedBox(width: 12),
                _iconButton(Icons.camera_alt_outlined,
                        () => _pickImage(source: ImageSource.camera)),
                // const SizedBox(width: 12),
                // _iconButton(PixelArtIcons.gif, () => _pickImage(source: ImageSource.gallery)),
                const SizedBox(width: 12),
                _iconButton(OctIcons.link, () {
                  setState(() => _showLinkField = !_showLinkField);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              width: 1,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withAlpha((0.25 * 255).toInt()),
            )),
        child:
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }
}
