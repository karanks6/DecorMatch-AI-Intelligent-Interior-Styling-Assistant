import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central service for all local notifications in DecorMatch AI.
///
/// Notification channels (Android):
///  • decormatch_analysis   — immediate: analysis ready
///  • decormatch_reminders  — scheduled: saved-item reminders
///  • decormatch_reco       — scheduled: style recommendations
class NotificationService {
  NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();

  // ─── Shared-Prefs keys ────────────────────────────────────────────────────
  static const _kAnalysis = 'notif_analysis';
  static const _kReminders = 'notif_reminders';
  static const _kReco = 'notif_reco';

  // ─── Channel IDs ──────────────────────────────────────────────────────────
  static const _chAnalysis = 'decormatch_analysis';
  static const _chReminders = 'decormatch_reminders';
  static const _chReco = 'decormatch_reco';

  // ─── Notification IDs ─────────────────────────────────────────────────────
  static const int _idAnalysis = 1;
  static const int _idReminderBase = 100; // 100-109
  static const int _idRecoBase = 200;     // 200-209

  // ─── Initialise ───────────────────────────────────────────────────────────

  static Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    // Create Android channels
    await _createChannel(
      id: _chAnalysis,
      name: 'Analysis Results',
      desc: 'Notified when a new room analysis is complete.',
      importance: Importance.high,
    );
    await _createChannel(
      id: _chReminders,
      name: 'Saved Items Reminders',
      desc: 'Reminders to browse your saved decor items.',
      importance: Importance.defaultImportance,
    );
    await _createChannel(
      id: _chReco,
      name: 'Recommendations',
      desc: 'New decor items matching your style preferences.',
      importance: Importance.defaultImportance,
    );

    // Request runtime permission (Android 13+)
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> _createChannel({
    required String id,
    required String name,
    required String desc,
    required Importance importance,
  }) async {
    final channel = AndroidNotificationChannel(
      id,
      name,
      description: desc,
      importance: importance,
      enableVibration: true,
      playSound: true,
      ledColor: const Color(0xFF0D5C4A), // emerald teal
      enableLights: true,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // ─── Preference helpers ───────────────────────────────────────────────────

  static Future<bool> getPreference(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? true; // default ON
  }

  static Future<void> setPreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  // ─── Public getters for toggle state ─────────────────────────────────────

  static Future<bool> get analysisEnabled => getPreference(_kAnalysis);
  static Future<bool> get remindersEnabled => getPreference(_kReminders);
  static Future<bool> get recoEnabled => getPreference(_kReco);

  static Future<void> setAnalysisEnabled(bool v) => setPreference(_kAnalysis, v);
  static Future<void> setRemindersEnabled(bool v) => setPreference(_kReminders, v);
  static Future<void> setRecoEnabled(bool v) => setPreference(_kReco, v);

  // ─── 1. Analysis complete notification (immediate) ───────────────────────

  static Future<void> showAnalysisComplete({
    required String style,
    required int itemCount,
  }) async {
    if (!await analysisEnabled) return;

    await _plugin.show(
      _idAnalysis,
      '✨ Your Room Analysis is Ready!',
      'Detected style: $style · $itemCount matching products found for you.',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _chAnalysis,
          'Analysis Results',
          channelDescription: 'Notified when a new room analysis is complete.',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(
            'Your room analysis is complete! We detected a $style aesthetic '
            'and found $itemCount curated products that match your space perfectly. '
            'Tap to explore your personalised recommendations.',
            contentTitle: '✨ Analysis Complete',
            summaryText: 'DecorMatch AI',
          ),
          color: const Color(0xFF0D5C4A),
          largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          ticker: 'Analysis complete',
        ),
      ),
    );
  }

  // ─── 2. Saved-items reminder (called by WorkManager) ─────────────────────

  static Future<void> showSavedItemsReminder(int slot) async {
    if (!await remindersEnabled) return;

    final messages = [
      (
        '🛋️ Your Saved Items Are Waiting',
        'You have curated pieces saved — explore and transform your space today!'
      ),
      (
        '🏡 Style Your Dream Room',
        'Check out the items you loved. Your perfect interior is just a click away.'
      ),
      (
        '💡 Redecorate with Confidence',
        'Your saved decor collection is ready to preview in AR. Give it a try!'
      ),
      (
        '🌿 Refresh Your Space',
        'Revisit your saved picks and find the perfect finishing touch for your room.'
      ),
      (
        '✨ Your Wishlist is Calling',
        'Browse your saved items and preview them in Augmented Reality — for free!'
      ),
    ];

    final (title, body) = messages[slot % messages.length];

    await _plugin.show(
      _idReminderBase + slot,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _chReminders,
          'Saved Items Reminders',
          channelDescription: 'Reminders to browse your saved decor items.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          styleInformation: BigTextStyleInformation(
            body,
            contentTitle: title,
            summaryText: 'DecorMatch AI',
          ),
          color: const Color(0xFF0D5C4A),
          largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        ),
      ),
    );
  }

  // ─── 3. Recommendation notification (called by WorkManager) ──────────────

  static Future<void> showRecommendation(int slot) async {
    if (!await recoEnabled) return;

    final messages = [
      (
        '🪴 New Arrivals for Your Style',
        'Fresh decor pieces curated for your aesthetic just landed. Tap to discover!'
      ),
      (
        '🛒 Trending in Your Style',
        'These handpicked items are trending among homeowners with your taste.'
      ),
      (
        '🎨 Curated Just for You',
        'New products matching your style preferences are ready to view in 3D & AR.'
      ),
      (
        '🏠 Elevate Your Interior Today',
        'Browse new recommendations tailored to your room\'s aesthetic profile.'
      ),
      (
        '✨ Your Style, Perfectly Matched',
        'DecorMatch AI found new products that align with your saved preferences!'
      ),
    ];

    final (title, body) = messages[slot % messages.length];

    await _plugin.show(
      _idRecoBase + slot,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _chReco,
          'Recommendations',
          channelDescription: 'New decor items matching your style preferences.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          styleInformation: BigTextStyleInformation(
            body,
            contentTitle: title,
            summaryText: 'DecorMatch AI',
          ),
          color: const Color(0xFF0D5C4A),
          largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        ),
      ),
    );
  }

  // ─── Cancel all ───────────────────────────────────────────────────────────

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
