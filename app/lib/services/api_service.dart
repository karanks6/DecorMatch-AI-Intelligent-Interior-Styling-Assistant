import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // For Android emulator to access local Node server, use 10.0.2.2.
  // Change to your laptop's IP if testing on a physical device.
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  Future<Map<String, dynamic>> analyzeRoom(File imageFile) async {
    var uri = Uri.parse('$baseUrl/analyze-room');
    var request = http.MultipartRequest('POST', uri);

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ),
    );

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Failed to analyze room: ${response.statusCode} - ${response.body}');
    }
  }
}
