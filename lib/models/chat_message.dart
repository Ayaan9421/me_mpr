class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp; // Added timestamp

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  // Factory constructor for creating a new ChatMessage instance from a map.
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.parse(
        json['timestamp'] as String,
      ), // Parse timestamp string
    );
  }

  // Method for converting a ChatMessage instance into a map.
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(), // Store timestamp as ISO string
    };
  }
}
