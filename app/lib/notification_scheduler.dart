import 'package:flutter/material.dart' show TimeOfDay, Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzData;
import 'package:shared_preferences/shared_preferences.dart';
import 'services/notification_service.dart';

// ─── Notification ID ranges ──────────────────────────────────────────────────
// 100–104 → reminders   (5 daily slots)
// 200–204 → recommendations (5 daily slots)

const _kScheduledKey = 'alarm_scheduled_v2';

/// Initialises the timezone database and schedules all daily alarm-based
/// notifications. Safe to call every app launch — it checks a flag and only
/// re-schedules if needed (or if preferences changed).
Future<void> initAndSchedule() async {
  tzData.initializeTimeZones();

  // Attempt to use the device local timezone; fall back to UTC
  try {
    final String localName = tz.local.name;
    if (localName.isEmpty) tz.setLocalLocation(tz.UTC);
  } catch (_) {
    tz.setLocalLocation(tz.UTC);
  }

  await schedulePeriodicNotifications();
}

/// Schedules 5 daily reminders and 5 daily recommendations using
/// flutter_local_notifications zonedSchedule with DateTimeComponents.time.
///
/// WHY NOT WorkManager?
/// WorkManager needs to spin up a Dart isolate every time a task fires, and
/// OEM battery managers (MIUI, OneUI, ColorOS etc.) aggressively kill those
/// background isolates. zonedSchedule() registers the alarm directly with
/// Android AlarmManager — the notification fires even when the app is fully
/// closed, with NO background Dart code required at fire-time.
Future<void> schedulePeriodicNotifications() async {
  final plugin = FlutterLocalNotificationsPlugin();

  // Check user preferences before scheduling
  final remindersOn = await NotificationService.remindersEnabled;
  final recoOn = await NotificationService.recoEnabled;

  // Cancel all existing scheduled alarms first
  await plugin.cancelAll();

  if (!remindersOn && !recoOn) return;

  // ── Reminder time slots (spread across the day) ───────────────────────────
  // 9:00  12:00  15:00  18:00  21:00
  final reminderTimes = [
    const TimeOfDay(hour: 9, minute: 0),
    const TimeOfDay(hour: 12, minute: 0),
    const TimeOfDay(hour: 15, minute: 0),
    const TimeOfDay(hour: 18, minute: 0),
    const TimeOfDay(hour: 21, minute: 0),
  ];

  // ── Recommendation time slots (offset 30 min from reminders) ─────────────
  // 9:30  12:30  15:30  18:30  21:30
  final recoTimes = [
    const TimeOfDay(hour: 9, minute: 30),
    const TimeOfDay(hour: 12, minute: 30),
    const TimeOfDay(hour: 15, minute: 30),
    const TimeOfDay(hour: 18, minute: 30),
    const TimeOfDay(hour: 21, minute: 30),
  ];

  for (int i = 0; i < 5; i++) {
    if (remindersOn) {
      await _scheduleDailyAlarm(
        plugin: plugin,
        id: 100 + i,
        time: reminderTimes[i],
        channelId: 'decormatch_reminders',
        channelName: 'Saved Items Reminders',
        content: _reminderContent(i),
      );
    }

    if (recoOn) {
      await _scheduleDailyAlarm(
        plugin: plugin,
        id: 200 + i,
        time: recoTimes[i],
        channelId: 'decormatch_reco',
        channelName: 'Recommendations',
        content: _recoContent(i),
      );
    }
  }

  // Persist flag so we know alarms are set
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_kScheduledKey, true);
}

/// Cancels all OS-level scheduled notification alarms.
Future<void> cancelAllScheduledNotifications() async {
  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.cancelAll();
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_kScheduledKey);
}

// ─── Internal helpers ─────────────────────────────────────────────────────────

Future<void> _scheduleDailyAlarm({
  required FlutterLocalNotificationsPlugin plugin,
  required int id,
  required TimeOfDay time,
  required String channelId,
  required String channelName,
  required ({String title, String body}) content,
}) async {
  final now = tz.TZDateTime.now(tz.local);

  // Build a TZDateTime for today at the target time
  var scheduledDate = tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day,
    time.hour,
    time.minute,
  );

  // If the time has already passed today, push to tomorrow
  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }

  await plugin.zonedSchedule(
    id,
    content.title,
    content.body,
    scheduledDate,
    NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        importance: Importance.high,
        priority: Priority.high,
        color: const Color(0xFF0D5C4A),
        styleInformation: BigTextStyleInformation(
          content.body,
          contentTitle: content.title,
          summaryText: 'DecorMatch AI',
        ),
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}

// ─── Notification content banks ───────────────────────────────────────────────

({String title, String body}) _reminderContent(int slot) {
  const messages = [
    (
      title: '🛋️ Your Saved Items Are Waiting',
      body: 'You have curated pieces saved — explore and transform your space today!',
    ),
    (
      title: '🏡 Style Your Dream Room',
      body: 'Check out the items you loved. Your perfect interior is just a click away.',
    ),
    (
      title: '💡 Redecorate with Confidence',
      body: 'Your saved decor collection is ready to preview in AR. Give it a try!',
    ),
    (
      title: '🌿 Refresh Your Space',
      body: 'Revisit your saved picks and find the perfect finishing touch for your room.',
    ),
    (
      title: '✨ Your Wishlist is Calling',
      body: 'Browse your saved items and preview them in Augmented Reality — for free!',
    ),
  ];
  return messages[slot % messages.length];
}

({String title, String body}) _recoContent(int slot) {
  const messages = [
    (
      title: '🪴 New Arrivals for Your Style',
      body: 'Fresh decor pieces curated for your aesthetic just landed. Tap to discover!',
    ),
    (
      title: '🛒 Trending in Your Style',
      body: 'These handpicked items are trending among homeowners with your taste.',
    ),
    (
      title: '🎨 Curated Just for You',
      body: 'New products matching your style preferences are ready to view in 3D & AR.',
    ),
    (
      title: '🏠 Elevate Your Interior Today',
      body: 'Browse new recommendations tailored to your room\'s aesthetic profile.',
    ),
    (
      title: '✨ Your Style, Perfectly Matched',
      body: 'DecorMatch AI found new products that align with your saved preferences!',
    ),
  ];
  return messages[slot % messages.length];
}


