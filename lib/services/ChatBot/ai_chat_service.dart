import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:me_mpr/services/ChatBot/chat_storage_service.dart'; // Import storage service
import 'package:me_mpr/models/depression_report.dart'; // Import the report model

class AiChatService {
  final String _baseUrl =
      'https://mindease-fastapi-577798778961.asia-south1.run.app';
  final ChatStorageService _storageService =
      ChatStorageService(); // Instance of storage service

  Future<String> getAiResponse(String userInput) async {
    final url = Uri.parse('$_baseUrl/chat');
    // --- Get current session ID ---
    final sessionId = await _storageService.getCurrentSessionId();

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        // --- Pass session ID ---
        body: jsonEncode({'user_input': userInput, 'session_id': sessionId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['reply'] ?? 'Sorry, I could not understand that.';
      } else {
        print('Server Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        return 'Sorry, something went wrong with the server.';
      }
    } catch (e) {
      print('Error fetching AI response: $e');
      return 'Sorry, I couldn\'t connect.';
    }
  }

  // --- NEW: Method to analyze chat history ---
  Future<DepressionReport> analyzeChat(String chatHistory) async {
    final url = Uri.parse('$_baseUrl/analyze-chat');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'chat_history': chatHistory}),
      );

      if (response.statusCode == 200) {
        return DepressionReport.fromJson(json.decode(response.body));
      } else {
        print('Chat Analysis Server Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception(
          'Failed to analyze chat. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error connecting to chat analysis server: $e');
      throw Exception('Error connecting to the chat analysis server: $e');
    }
  }
}
