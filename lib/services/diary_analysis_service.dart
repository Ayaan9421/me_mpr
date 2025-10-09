import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:me_mpr/failure/depression_report.dart';

class DiaryAnalysisService {
  // --- Replace with your actual base URL ---
  final String _baseUrl = 'https://coletta-snouted-rigoberto.ngrok-free.dev';

  // Method to analyze text input
  Future<DepressionReport> analyzeText(String text) async {
    final url = Uri.parse('$_baseUrl/text');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'text': text}),
      );

      if (response.statusCode == 200) {
        return DepressionReport.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Failed to analyze text. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error connecting to the text analysis server: $e');
    }
  }

  // Method to analyze an audio file
  Future<DepressionReport> analyzeAudio(String filePath) async {
    final url = Uri.parse('$_baseUrl/analyze');
    try {
      var request = http.MultipartRequest('POST', url);
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return DepressionReport.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Failed to analyze audio. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error connecting to the audio analysis server: $e');
    }
  }
}
