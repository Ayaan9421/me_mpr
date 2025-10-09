import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:me_mpr/failure/chat_message.dart';
import 'package:me_mpr/services/ai_chat_service.dart';
import 'package:me_mpr/widgets/ai_typing_indicator.dart';
import 'package:me_mpr/widgets/chat_message_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isAiTyping = false;
  final AiChatService _chatService = AiChatService();
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
  }

  // Handles sending a message by calling the API
  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userMessage = ChatMessage(text: _controller.text, isUser: true);
    final userInput = _controller.text.trim();

    setState(() {
      _messages.add(userMessage);
      _isAiTyping = true;
    });

    _controller.clear();
    _scrollToBottom();

    // Get the response from the API
    try {
      final aiResponseText = await _chatService.getAiResponse(userInput);
      final aiMessage = ChatMessage(text: aiResponseText, isUser: false);
      setState(() {
        _messages.add(aiMessage);
      });
    } catch (e) {
      final errorMessage = ChatMessage(
        text: "Sorry, an error occurred.",
        isUser: false,
      );
      setState(() {
        _messages.add(errorMessage);
      });
    } finally {
      // Hide the typing indicator regardless of success or failure
      setState(() {
        _isAiTyping = false;
      });
      _scrollToBottom();
    }
  }

  // Auto-scrolls to the latest message
  void _scrollToBottom() {
    Timer(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB3E5FC),
        elevation: 1.0,
        title: const Text(
          'Calmora',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      backgroundColor: const Color(0xFFF1F8E9),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length + (_isAiTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isAiTyping && index == _messages.length) {
                  return const AiTypingIndicator();
                }
                final message = _messages[index];
                return ChatMessageBubble(message: message);
              },
            ),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  // Builds the text input field and send button at the bottom
  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  fillColor: const Color(0xFFF5F5F5),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: const Color(0xFFFFC107),
              borderRadius: BorderRadius.circular(50),
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: _sendMessage,
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Icon(Icons.send, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
