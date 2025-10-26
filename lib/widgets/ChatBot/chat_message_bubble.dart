import 'package:flutter/material.dart';
import 'package:me_mpr/models/chat_message.dart';
import 'package:me_mpr/utils/app_colors.dart'; // Import AppColors

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          // User message uses primary color, AI uses card background
          color: isUser ? colorScheme.primary : AppColors.cardBackground,
          // Add border for AI messages to match card theme
          border: isUser ? null : Border.all(color: AppColors.border),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20.0),
            topRight: const Radius.circular(20.0),
            bottomLeft: isUser
                ? const Radius.circular(20.0)
                : const Radius.circular(4.0),
            bottomRight: isUser
                ? const Radius.circular(4.0)
                : const Radius.circular(20.0),
          ),
          boxShadow: isUser
              ? [
                  // Optional: Add subtle shadow to user messages
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null, // No shadow for AI messages to match card style
        ),
        constraints: BoxConstraints(
          // Constrain width to prevent bubble taking full screen width
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Text(
          message.text,
          style: TextStyle(
            // User text is white, AI text is primary text color
            color: isUser ? Colors.white : AppColors.primaryText,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
