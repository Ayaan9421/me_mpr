import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:me_mpr/models/chat_message.dart'; // Correct path
import 'package:me_mpr/screens/ChatBot/chat_analysis_page.dart'; // Import new page
import 'package:me_mpr/services/ChatBot/ai_chat_service.dart';
import 'package:me_mpr/services/ChatBot/chat_storage_service.dart'; // Import storage
import 'package:me_mpr/utils/app_colors.dart';
import 'package:me_mpr/widgets/ChatBot/ai_typing_indicator.dart'; // Correct path
import 'package:me_mpr/widgets/ChatBot/chat_message_bubble.dart'; // Correct path

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = []; // Not final anymore
  bool _isLoadingHistory = true; // Loading state
  bool _isAiTyping = false;
  final AiChatService _chatService = AiChatService();
  final ChatStorageService _storageService =
      ChatStorageService(); // Storage service
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadHistory(); // Load history when screen opens
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoadingHistory = true);
    final history = await _storageService.loadMessages();
    setState(() {
      _messages = history;
      _isLoadingHistory = false;
      // Add welcome message if history is empty *after* loading
      if (_messages.isEmpty) {
        _messages.add(
          ChatMessage(
            text: "Hello! How can I help you today?",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      }
    });
    _scrollToBottom(instant: true); // Scroll instantly after loading
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      text: _controller.text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );
    final userInput = _controller.text.trim();

    setState(() {
      _messages.add(userMessage);
      _isAiTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    // Save user message immediately
    await _storageService.saveMessage(userMessage);

    try {
      final aiResponseText = await _chatService.getAiResponse(userInput);
      final aiMessage = ChatMessage(
        text: aiResponseText,
        isUser: false,
        timestamp: DateTime.now(),
      );

      if (mounted) {
        setState(() => _messages.add(aiMessage));
        // Save AI message
        await _storageService.saveMessage(aiMessage);
      }
    } catch (e) {
      print("Chat Error: $e");
      final errorMessage = ChatMessage(
        text: "Sorry, I couldn't connect right now. Please try again later.",
        isUser: false,
        timestamp: DateTime.now(),
      );
      if (mounted) {
        setState(() => _messages.add(errorMessage));
        // Optionally save error message? Depends on requirements.
        // await _storageService.saveMessage(errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isAiTyping = false);
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom({bool instant = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        if (instant) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        } else {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }

  // --- NEW: Format chat history for analysis ---
  String _formatChatHistory() {
    StringBuffer historyBuffer = StringBuffer();
    for (var msg in _messages) {
      historyBuffer.writeln("${msg.isUser ? 'User' : 'Calmora'}: ${msg.text}");
    }
    return historyBuffer.toString();
  }

  // --- NEW: Trigger analysis and navigate ---
  Future<void> _analyzeCurrentChat() async {
    if (_messages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No messages in the current chat to analyze.'),
        ),
      );
      return;
    }

    final historyString = _formatChatHistory();

    // Show loading indicator (optional)
    showDialog(
      context: context,
      builder: (_) => const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final report = await _chatService.analyzeChat(historyString);
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChatAnalysisPage(report: report)),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to analyze chat: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calmora AI'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // --- NEW: Analyze Button ---
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'Analyze Chat Session',
            onPressed: _analyzeCurrentChat,
          ),
        ],
      ),
      backgroundColor: colorScheme.background,
      body: Column(
        children: [
          Expanded(
            child: _isLoadingHistory
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
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
          _buildMessageComposer(colorScheme),
        ],
      ),
    );
  }

  Widget _buildMessageComposer(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(top: BorderSide(color: AppColors.border, width: 1.0)),
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.end, // Align items to bottom for multiline
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                // onSubmitted: (_) => _sendMessage(), // Let send button handle it
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  fillColor: AppColors.background,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      24.0,
                    ), // Slightly less round
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 5,
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              // Use InkWell for better tap feedback area
              onTap: _sendMessage,
              customBorder: const CircleBorder(),
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
