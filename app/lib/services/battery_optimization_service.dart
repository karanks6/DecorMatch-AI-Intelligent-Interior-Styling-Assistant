import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';

/// Handles the battery optimization whitelist request.
///
/// On Xiaomi/MIUI and many Android OEMs, background tasks are killed unless
/// the user explicitly disables battery optimization for the app.
/// This service shows a one-time dialog guiding the user to do so.
class BatteryOptimizationService {
  static const _platform =
      MethodChannel('decormatch/battery');
  static const _prefKey = 'battery_opt_prompted';

  /// Show the dialog once per install (checks SharedPreferences).
  static Future<void> promptIfNeeded(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_prefKey) == true) return;

    await prefs.setBool(_prefKey, true);

    if (!context.mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _BatteryDialog(),
    );
  }

  /// Opens Android's battery optimization settings for this app.
  static Future<void> openBatterySettings() async {
    try {
      await _platform.invokeMethod('openBatterySettings');
    } catch (_) {
      // Fallback: ignore if the channel isn't registered yet
    }
  }
}

class _BatteryDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_active_outlined,
                  color: AppColors.primary, size: 36),
            ),
            const SizedBox(height: 20),

            Text('Enable Background Notifications',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText)),

            const SizedBox(height: 12),

            Text(
              'To receive reminders and recommendations even when the app is '
              'closed, please allow DecorMatch to run in the background.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  color: AppColors.secondaryText,
                  fontSize: 13,
                  height: 1.6),
            ),

            const SizedBox(height: 20),

            // Step-by-step guide for MIUI
            _StepCard(
              step: '1',
              text: 'Tap "Open Settings" below',
            ),
            _StepCard(
              step: '2',
              text: 'Select "No restrictions" under Battery',
            ),
            _StepCard(
              step: '3',
              text: 'Also enable "Autostart" in Security app',
            ),

            const SizedBox(height: 24),

            // Open Settings button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await BatteryOptimizationService.openBatterySettings();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Open Settings',
                    style: GoogleFonts.inter(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Maybe Later',
                  style: GoogleFonts.inter(
                      color: AppColors.secondaryText, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String step;
  final String text;

  const _StepCard({required this.step, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(step,
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: GoogleFonts.inter(
                    color: AppColors.primaryText,
                    fontSize: 13,
                    height: 1.4)),
          ),
        ],
      ),
    );
  }
}
