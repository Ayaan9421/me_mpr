import 'dart:convert';
import 'package:me_mpr/models/chat_message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ChatStorageService {
  static const _storageKey = 'chat_history';
  static const _lastTimestampKey = 'last_message_timestamp';
  static const _sessionIdKey = 'current_chat_session_id';
  static const _resetHourKey = 'chat_reset_hour';
  static const _defaultResetHour = 3; // Default reset time: 3 AM
  final _uuid = const Uuid();

  Future<void> setResetHour(int hour) async {
    if (hour < 0 || hour > 23) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_resetHourKey, hour);
    print("Chat reset hour set to: $hour:00");
  }

  Future<int> getResetHour() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_resetHourKey) ?? _defaultResetHour;
  }

  // --- NEW: Check if the reset hour preference exists ---
  Future<bool> hasSetResetHour() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_resetHourKey);
  }

  Future<DateTime> _getLastResetTime() async {
    final resetHour = await getResetHour();
    final now = DateTime.now();
    DateTime lastResetToday = DateTime(now.year, now.month, now.day, resetHour);

    if (now.isBefore(lastResetToday)) {
      return lastResetToday.subtract(const Duration(days: 1));
    } else {
      return lastResetToday;
    }
  }

  Future<void> saveMessage(ChatMessage message) async {
    // Ensure timestamp is recent before saving relative to last reset
    final lastResetTime = await _getLastResetTime();
    if (message.timestamp.isBefore(lastResetTime)) {
      print("Attempted to save message older than last reset time. Ignoring.");
      return; // Don't save messages from previous sessions
    }

    final messages = await loadMessages();
    messages.add(message);
    await _persistMessages(messages);
    await _updateLastTimestamp(message.timestamp);
  }

  Future<List<ChatMessage>> loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final String? messagesString = prefs.getString(_storageKey);
    if (messagesString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(messagesString);
      List<ChatMessage> messages = jsonList
          .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
          .toList();

      final lastResetTime = await _getLastResetTime();
      messages.retainWhere((msg) => msg.timestamp.isAfter(lastResetTime));

      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      // No need to persist filtered list here, happens on save
      return messages;
    } catch (e) {
      print("Error decoding chat messages: $e");
      await prefs.remove(_storageKey);
      return [];
    }
  }

  Future<void> clearChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    // Keep last timestamp and session ID, they get reset by getCurrentSessionId if needed
    // await prefs.remove(_lastTimestampKey);
    // await prefs.remove(_sessionIdKey);
    print("Chat message history cleared (session info retained).");
  }

  Future<void> _persistMessages(List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> jsonList = messages
        .map((e) => e.toJson())
        .toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  Future<void> _updateLastTimestamp(DateTime timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastTimestampKey, timestamp.millisecondsSinceEpoch);
  }

  Future<int> _getLastTimestampMillis() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lastTimestampKey) ?? 0;
  }

  Future<String> getCurrentSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    final lastTimestampMillis = await _getLastTimestampMillis();
    final lastTimestamp = DateTime.fromMillisecondsSinceEpoch(
      lastTimestampMillis,
    );
    final lastResetTime = await _getLastResetTime();

    String? currentSessionId = prefs.getString(_sessionIdKey);

    // Reset if no ID, OR last message is before last reset
    bool shouldReset =
        currentSessionId == null || lastTimestamp.isBefore(lastResetTime);

    if (shouldReset) {
      currentSessionId = _uuid.v4();
      await prefs.setString(_sessionIdKey, currentSessionId);
      print(
        "Generated new chat session ID: $currentSessionId (Last msg: $lastTimestamp, Last reset: $lastResetTime)",
      );
      // --- Clear old messages only when session actually resets ---
      final messages =
          await loadMessages(); // Load checks timestamp, filtering old ones
      if (messages.isNotEmpty) {
        await _persistMessages(
          [],
        ); // Explicitly save empty list if reset needed
        print("Old chat messages cleared due to session reset.");
      }
      // Update the last timestamp to now prevent immediate re-reset
      await _updateLastTimestamp(DateTime.now());
      // ---
    } else {
      print(
        "Using existing chat session ID: $currentSessionId (Last msg: $lastTimestamp, Last reset: $lastResetTime)",
      );
    }
    return currentSessionId;
  }
}
