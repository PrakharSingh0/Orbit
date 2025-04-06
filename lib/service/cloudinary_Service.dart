import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<String?> uploadToCloudinary(File imageFile) async {
  final cloudName = 'YOUR_CLOUD_NAME';
  final uploadPreset = 'YOUR_UNSIGNED_UPLOAD_PRESET'; // You can create one in Cloudinary settings

  final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

  final request = http.MultipartRequest('POST', uri)
    ..fields['upload_preset'] = uploadPreset
    ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

  final response = await request.send();

  if (response.statusCode == 200) {
    final responseData = await http.Response.fromStream(response);
    final data = json.decode(responseData.body);
    return data['secure_url']; // This is your Cloudinary URL
  } else {
    print('Failed to upload image. Status code: ${response.statusCode}');
    return null;
  }
}
