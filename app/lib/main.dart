import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'core/theme.dart';
import 'ui/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
