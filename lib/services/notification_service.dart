import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/subscription.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for Android 13+
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - can navigate to specific subscription
    // TODO: Implement deep linking if needed
  }

  Future<void> scheduleSubscriptionReminder(Subscription subscription) async {
    if (!subscription.notificationsEnabled) return;

    final reminderDate = subscription.nextBillingDate.subtract(
      Duration(days: subscription.reminderDaysBefore),
    );

    if (reminderDate.isBefore(DateTime.now())) return;

    final tzReminderDate = tz.TZDateTime.from(reminderDate, tz.local);

    await _notifications.zonedSchedule(
      subscription.id.hashCode,
      '${subscription.name} Renewal Coming Up',
      '${subscription.currency}${subscription.price.toStringAsFixed(2)} due in ${subscription.reminderDaysBefore} days',
      tzReminderDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'subscription_reminders',
          'Subscription Reminders',
          channelDescription: 'Reminders for upcoming subscription renewals',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFFDC2626),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
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
    await _notifications.cancelAll();
    
    for (final subscription in subscriptions) {
      if (subscription.isActive && subscription.notificationsEnabled) {
        await scheduleSubscriptionReminder(subscription);
      }
    }
  }

  Future<void> showTestNotification() async {
    await _notifications.show(
      0,
      'Subscription Tracker',
      'Notifications are working!',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',
          channelDescription: 'Test notification channel',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFFDC2626),
        ),
      ),
    );
  }
}
