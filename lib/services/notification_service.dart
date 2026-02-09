import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import '../models/subscription.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _exactAlarmChannel = MethodChannel('com.vibecoding.subscription_tracker/exact_alarm');

  /// Check if the app can schedule exact alarms (API 31+).
  Future<bool> canScheduleExactAlarms() async {
    try {
      final result = await _exactAlarmChannel.invokeMethod<bool>('canScheduleExactAlarms');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Open system settings so the user can grant the exact alarm permission.
  Future<void> requestExactAlarmPermission() async {
    try {
      await _exactAlarmChannel.invokeMethod('requestExactAlarmPermission');
    } on PlatformException {
      // Ignore – settings screen could not be opened
    }
  }

  Future<void> initialize() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for Android 13+
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      // Request exact alarms for Android 12+ (needed for scheduled notifications)
      await androidPlugin.requestExactAlarmsPermission();
    }

    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
  }

  Future<void> scheduleSubscriptionReminder(Subscription subscription) async {
    if (!_initialized) await initialize();
    if (!subscription.notificationsEnabled) return;

    final reminderDate = subscription.nextBillingDate.subtract(
      Duration(days: subscription.reminderDaysBefore),
    );

    // If reminder date is in the past, skip
    if (reminderDate.isBefore(DateTime.now())) return;

    // Set reminder for 9:00 AM on the reminder date
    final scheduledDate = DateTime(
      reminderDate.year, reminderDate.month, reminderDate.day,
      9, 0, 0,
    );

    // If 9 AM already passed today, skip
    if (scheduledDate.isBefore(DateTime.now())) return;

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    await _notifications.zonedSchedule(
      subscription.id.hashCode,
      '${subscription.name} — Renewal Coming',
      '${subscription.currency}${subscription.price.toStringAsFixed(2)} due in ${subscription.reminderDaysBefore} day${subscription.reminderDaysBefore == 1 ? '' : 's'}',
      tzScheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'subscription_reminders',
          'Subscription Reminders',
          channelDescription: 'Reminders for upcoming subscription renewals',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFFE8E8E8),
          styleInformation: const BigTextStyleInformation(''),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelSubscriptionReminder(String subscriptionId) async {
    await _notifications.cancel(subscriptionId.hashCode);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> rescheduleAllReminders(List<Subscription> subscriptions) async {
    if (!_initialized) await initialize();
    await _notifications.cancelAll();
    
    for (final subscription in subscriptions) {
      if (subscription.isActive && subscription.notificationsEnabled) {
        try {
          await scheduleSubscriptionReminder(subscription);
        } catch (_) {
          // Skip individual failures
        }
      }
    }
  }

  Future<void> showTestNotification() async {
    if (!_initialized) await initialize();
    await _notifications.show(
      0,
      'SubTracker',
      'Notifications are working! You will receive reminders before each renewal.',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',
          channelDescription: 'Test notification channel',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFFE8E8E8),
        ),
      ),
    );
  }
}
