import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'notification_service.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure Flutter binding is initialized
  await NotificationService().init(); // Initialize the notification service
  runApp(WaterManagementApp()); // Run the main app
}

class WaterManagementApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Water Management System', // Title of the app
      theme: ThemeData(
        primarySwatch: Colors.blue, // Set the primary color to blue
        visualDensity: VisualDensity
            .adaptivePlatformDensity, // Adjust visual density for different platforms
      ),
      home: LoginScreen(), // Set the home screen to LoginScreen
    );
  }
}
