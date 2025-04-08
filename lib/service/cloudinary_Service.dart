import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

Future<String?> uploadToCloudinaryPost(File file) async {
  try {
    final compressedBytes = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: 50,
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

