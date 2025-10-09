import 'package:flutter/material.dart';

import 'package:me_mpr/failure/chat_message.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Align bubbles to the right for user, left for AI
    final alignment = message.isUser
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final color = message.isUser
        ? const Color(0xFFFFF9C4)
        : Colors.white; // Yellow for user, white for AI
    final textColor = Colors.black87;
    final bubbleAlignment = message.isUser
        ? MainAxisAlignment.end
        : MainAxisAlignment.start;

    return Row(
      mainAxisAlignment: bubbleAlignment,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          margin: const EdgeInsets.symmetric(vertical: 5.0),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: alignment,
            children: [
              Text(
                message.text,
                style: TextStyle(color: textColor, fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
