import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _notificationService = NotificationService
      ._internal(); // Singleton pattern for NotificationService

  factory NotificationService() {
    return _notificationService; // Factory constructor returns the singleton instance
  }

  NotificationService._internal(); // Private internal constructor for singleton

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin(); // Instance of FlutterLocalNotificationsPlugin

  // Initialization method for setting up notifications
  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
            '@mipmap/ic_launcher'); // Android specific initialization settings

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    ); // Initialization settings for all platforms

    await flutterLocalNotificationsPlugin.initialize(
        initializationSettings); // Initialize the plugin with settings
  }

  // Method to show notifications
  Future<void> showNotifications(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'water_usage_id',
      'Water Usage Notifications',
      channelDescription: 'Notification channel for water usage app',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    ); // Android specific notification details

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android:
            androidPlatformChannelSpecifics); // Platform specific notification details

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    ); // Show the notification with specified details
  }
}
