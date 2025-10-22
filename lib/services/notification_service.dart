import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Initialization settings for Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
          '@mipmap/ic_launcher',
        ); // Use default app icon

    // Initialization settings for iOS - Requesting permissions
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _notificationsPlugin.initialize(initializationSettings);

    // Request Android 13+ notification permission explicitly
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    await androidImplementation?.requestNotificationsPermission();
  }

  // --- Notification Methods ---

  Future<void> showProgressNotification({
    required int id,
    required String title,
    required String body,
    required int progress,
    required int maxProgress,
  }) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'progress_channel', // Channel ID
          'Analysis Progress', // Channel Name
          channelDescription: 'Notifications showing analysis progress',
          importance: Importance.low, // Low importance for progress
          priority: Priority.low,
          showProgress: true,
          progress: progress,
          maxProgress: maxProgress,
          ongoing: true, // Makes it sticky until cancelled/completed
          onlyAlertOnce: true, // Don't make sound/vibrate on update
          icon: '@mipmap/ic_launcher',
        );
    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: false, // Don't show initial alert for progress
      presentBadge: false,
      presentSound: false,
    );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails, // iOS doesn't have built-in progress bars
    );

    await _notificationsPlugin.show(id, title, body, platformDetails);
  }

  Future<void> showCompletionNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    // Cancel the progress notification first
    await _notificationsPlugin.cancel(id);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'completion_channel', // Different Channel ID
          'Analysis Completed', // Channel Name
          channelDescription: 'Notifications for completed analysis',
          importance: Importance.defaultImportance, // Default importance
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true, // Optionally update badge count
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      id + 1000, // Use a different ID for completion to avoid conflicts
      title,
      body,
      platformDetails,
    );
  }

  Future<void> showErrorNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await _notificationsPlugin.cancel(id); // Cancel progress

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'error_channel', // Different Channel ID
          'Analysis Error', // Channel Name
          channelDescription: 'Notifications for analysis errors',
          importance: Importance.high, // High importance for errors
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      id + 2000, // Use a different ID
      title,
      body,
      platformDetails,
    );
  }
}
