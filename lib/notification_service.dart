// lib/notification_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidInitSettings);

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {},
    );

    if (Platform.isAndroid) {
      final androidPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
    }
  }

  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_reminder',
        'Daily Reminders',
        channelDescription: 'Daily practice reminder notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
  }

  Future<void> scheduleDailyNotifications(
    TimeOfDay time,
    List<bool> days,
  ) async {
    await cancelAllNotifications();

    final now = DateTime.now();
    final daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    for (int i = 0; i < days.length; i++) {
      if (days[i]) {
        var scheduledDate = _nextDayOfWeek(i + 1, time);
        await _notificationsPlugin.zonedSchedule(
          i,
          'Time to Practice',
          'It\'s time for your daily practice session!',
          tz.TZDateTime.from(scheduledDate, tz.local),
          _notificationDetails(),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    }
  }

  DateTime _nextDayOfWeek(int dayOfWeek, TimeOfDay time) {
    DateTime date = DateTime.now();
    while (date.weekday != dayOfWeek) {
      date = date.add(const Duration(days: 1));
    }
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
