import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // For Android emulator to access local Node server, use 10.0.2.2.
  // Change to your laptop's IP if testing on a physical device.
  static const String baseUrl = 'http://10.167.18.24:3000';
  static const String apiUrl = '$baseUrl/api';

  Future<Map<String, dynamic>> analyzeRoom(File imageFile, String roomType) async {
    var uri = Uri.parse('$apiUrl/analyze-room');
    var request = http.MultipartRequest('POST', uri);

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ),
    );

    request.fields['room_type'] = roomType;

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
