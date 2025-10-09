import 'dart:convert';
import 'package:http/http.dart' as http;

class AiChatService {
  // This uses the correct localhost IP for Android/iOS emulators.
  // Make sure your FastAPI server is running on port 8000.
  final String _baseUrl = 'https://coletta-snouted-rigoberto.ngrok-free.dev';

  /// Fetches a response from the AI chatbot backend.
  Future<String> getAiResponse(String userInput) async {
    final url = Uri.parse('$_baseUrl/chat');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'user_input': userInput, 'session_id': 'pqr'}),
      );

      if (response.statusCode == 200) {
        // Use utf8.decode to handle potential special characters in the response
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['reply'] ?? 'Sorry, I could not understand that.';
      } else {
        // Handle server-side errors
        print('Server Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        return 'Sorry, something went wrong with the server.';
      }
    } catch (e) {
      // Handle network or other client-side errors
      print('Error fetching AI response: $e');
      return 'Sorry, I couldn\'t connect. Please check your connection and that the server is running.';
    }
  }
}
