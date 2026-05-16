import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'core/theme.dart';
import 'ui/screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'notification_scheduler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialise local notifications (creates channels, requests permission)
  await NotificationService.init();

  // Schedule daily OS-level alarms for reminders & recommendations.
  // Uses flutter_local_notifications zonedSchedule → fires even when app is killed.
  await initAndSchedule();

  runApp(const ProviderScope(child: DecorMatchApp()));
}

class DecorMatchApp extends StatelessWidget {
  const DecorMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DecorMatch AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
