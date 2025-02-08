// lib/main.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications and get permission status
  final hasPermission = await NotificationService().initNotification();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // If no permission, ensure notifications are disabled
  if (!hasPermission) {
    await prefs.setBool('notificationsEnabled', false);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
