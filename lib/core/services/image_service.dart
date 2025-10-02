import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../config.dart'; // Import the new config file

/// A service to handle picking and uploading images using a manual HTTP request.
class ImageService {
  final ImagePicker _picker = ImagePicker();

  /// Opens the device's gallery and returns the image as a byte list.
  Future<Uint8List?> pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // Compresses the image slightly for faster uploads
      );
      return pickedFile != null ? await pickedFile.readAsBytes() : null;
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image: $e');
      }
      return null;
    }
  }

  /// Uploads the given image bytes to ImageKit using the private key.
  Future<String?> uploadImage({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    try {
      // 1. Create the multipart request
      var request = http.MultipartRequest('POST', Uri.parse(Config.imagekitUrl));

      // 2. Set the Authorization header using your private key
      request.headers['Authorization'] =
          'Basic ${base64Encode(utf8.encode('${Config.privateKey}:'))}';

      // 3. Add the required fields for the upload
      request.fields['fileName'] = fileName;
      request.fields['publicKey'] = Config.publicKey;
      request.fields['folder'] = '/agrolink_listings'; // Optional: specify a folder

      // 4. Add the image file itself
      request.files.add(http.MultipartFile.fromBytes('file', imageBytes, filename: fileName));

      // 5. Send the request and wait for the response
      var response = await request.send();

      // 6. Check the response status and get the URL
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseData);
        return jsonResponse['url']; // Return the URL of the uploaded image
      } else {
        if (kDebugMode) {
          print('Failed to upload image. Status code: ${response.statusCode}');
          print('Response: ${await response.stream.bytesToString()}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Image upload error: $e');
      }
      return null;
    }
  }
}

