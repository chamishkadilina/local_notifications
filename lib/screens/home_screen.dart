// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../../notification_service.dart';
import '../../widgets/time_picker_widget.dart';
import '../../widgets/day_selector_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isEnabled = false;
  TimeOfDay selectedTime =
      const TimeOfDay(hour: 5, minute: 0); // Default 5:00 AM
  List<bool> selectedDays = List.generate(7, (_) => true);
  bool hasPermission = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isEnabled = prefs.getBool('notificationsEnabled') ?? false;
      final hour = prefs.getInt('notificationHour') ?? 5; // Default to 5
      final minute = prefs.getInt('notificationMinute') ?? 0; // Default to 00
      selectedTime = TimeOfDay(hour: hour, minute: minute);
      selectedDays = List.generate(
          7, (index) => prefs.getBool('notificationDay$index') ?? true);
    });
  }

  Future<void> _requestPermissionAndSave(bool value) async {
    if (value && !hasPermission) {
      hasPermission = await NotificationService().requestPermissions();
      if (!hasPermission) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Notifications Required'),
                content: const Text(
                    'Please enable notifications in your system settings to use this feature.'),
                actions: [
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
        setState(() {
          isEnabled = false;
        });
        return;
      }
    }
    setState(() {
      isEnabled = value && hasPermission;
    });
    _saveSettings();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', isEnabled);
    await prefs.setInt('notificationHour', selectedTime.hour);
    await prefs.setInt('notificationMinute', selectedTime.minute);
    for (int i = 0; i < selectedDays.length; i++) {
      await prefs.setBool('notificationDay$i', selectedDays[i]);
    }

    if (isEnabled) {
      await NotificationService().scheduleDailyNotifications(
        selectedTime,
        selectedDays,
      );
    } else {
      await NotificationService().cancelAllNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notification Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Enable Daily Reminders'),
              value: isEnabled,
              onChanged: (bool value) => _requestPermissionAndSave(value),
            ),
            if (isEnabled) ...[
              const SizedBox(height: 16),
              TimePickerWidget(
                selectedTime: selectedTime,
                onTimeChanged: (TimeOfDay newTime) {
                  setState(() {
                    selectedTime = newTime;
                  });
                  _saveSettings();
                },
              ),
              const SizedBox(height: 16),
              DaySelectorWidget(
                selectedDays: selectedDays,
                onDaysChanged: (List<bool> newDays) {
                  setState(() {
                    selectedDays = newDays;
                  });
                  _saveSettings();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
