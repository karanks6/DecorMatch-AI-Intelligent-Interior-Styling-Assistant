import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';
import 'services/notification_service.dart';

// ─── Task name constants ─────────────────────────────────────────────────────
const kTaskReminder = 'decormatch_saved_reminder';
const kTaskReco = 'decormatch_recommendation';

/// Top-level callback — required by WorkManager 0.9.x.
/// Must be a top-level function (NOT inside a class).
///
/// IMPORTANT: The two ensureInitialized calls below are NOT optional.
/// Without them, Flutter plugins are not registered in the background
/// isolate and all notification show() calls silently do nothing.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    // Step 1 — bootstrap the Flutter engine binding in this isolate
    WidgetsFlutterBinding.ensureInitialized();
    // Step 2 — register all Flutter plugins (flutter_local_notifications etc.)
    DartPluginRegistrant.ensureInitialized();

    // Now it is safe to call plugin code
    await NotificationService.init();

    final slot = inputData?['slot'] as int? ?? 0;

    switch (taskName) {
      case kTaskReminder:
        await NotificationService.showSavedItemsReminder(slot);
        break;
      case kTaskReco:
        await NotificationService.showRecommendation(slot);
        break;
    }
    return true;
  });
}

/// Registers 5 staggered reminder + 5 staggered recommendation periodic tasks.
///
/// WorkManager 0.9.x changed the API: `uniqueName` is now the first positional
/// arg and `taskName` is the second. The minimum frequency is 15 minutes on
/// Android but we use 4 hours so OS batching is not an issue.
Future<void> schedulePeriodicNotifications() async {
  final wm = Workmanager();

  // Cancel existing before re-registering to avoid duplicates
  await wm.cancelAll();

  for (int i = 0; i < 5; i++) {
    // Reminders: 1h, 4h, 7h, 10h, 13h initial delay, repeat every 4h
    await wm.registerPeriodicTask(
      '${kTaskReminder}_$i',     // unique name (used to identify/replace)
      kTaskReminder,              // task name passed to callbackDispatcher
      frequency: const Duration(hours: 4),
      initialDelay: Duration(hours: 1 + i * 3),
      inputData: {'slot': i},
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
      ),
    );

    // Recommendations: offset 1h from reminders
    await wm.registerPeriodicTask(
      '${kTaskReco}_$i',
      kTaskReco,
      frequency: const Duration(hours: 4),
      initialDelay: Duration(hours: 2 + i * 3),
      inputData: {'slot': i},
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
      ),
    );
  }
}

/// Cancels all background notification tasks.
Future<void> cancelAllScheduledNotifications() async {
  await Workmanager().cancelAll();
}
