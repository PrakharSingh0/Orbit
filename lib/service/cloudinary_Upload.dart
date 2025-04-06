import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

Future<String?> pickCompressAndUploadImage(File file) async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  if (pickedFile == null) return null;

  // Compress Image
  final tempDir = await getTemporaryDirectory();
  final targetPath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

  final compressedFile = await FlutterImageCompress.compressAndGetFile(
    pickedFile.path,
    targetPath,
    quality: 70, // adjust to get target size (200KB–300KB)
  );

  if (compressedFile == null) return null;

  // Upload to Cloudinary
  final uri = Uri.parse('https://api.cloudinary.com/v1_1/orbit-01/image/upload');
  final request = http.MultipartRequest('POST', uri)
    ..fields['upload_preset'] = 'orbit-upload Preset'
    ..files.add(await http.MultipartFile.fromPath('file', compressedFile.path));

  final response = await request.send();
  if (response.statusCode == 200) {
    final res = await http.Response.fromStream(response);
    final secureUrl = RegExp(r'"secure_url":"(.*?)"').firstMatch(res.body)?.group(1);
    return secureUrl;
  } else {
    debugPrint('Upload failed: ${response.statusCode}');
    return null;
  }
}
