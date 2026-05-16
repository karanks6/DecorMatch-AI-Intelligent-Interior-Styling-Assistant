import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/constants.dart';
import '../../services/user_service.dart';
import '../../services/notification_service.dart';
import '../../notification_scheduler.dart';
import 'login_screen.dart';
import 'saved_screen.dart';
import 'analysis_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isUploadingPhoto = false;
  String? _localPhotoUrl;

  String? get _photoUrl =>
      _localPhotoUrl ?? FirebaseAuth.instance.currentUser?.photoURL;

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80, maxWidth: 512);
    if (picked == null) return;

    setState(() => _isUploadingPhoto = true);
    try {
      final url = await UserService.uploadProfileImage(File(picked.path));
      if (mounted) setState(() => _localPhotoUrl = url);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Profile photo updated!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'DecorMatch User';
    final email = user?.email ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<dynamic>(
        stream: UserService.statsStream(),
        builder: (context, snapshot) {
          final stats = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          final analysisCount = stats['analysisCount'] ?? 0;
          final savedCount = stats['savedCount'] ?? 0;
          final arViewCount = stats['arViewCount'] ?? 0;

          return SingleChildScrollView(
            child: Column(
              children: [
                // ── Gradient Header ──────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(32)),
                  ),
                  child: Column(
                    children: [
                      // Avatar with upload button
                      GestureDetector(
                        onTap: _isUploadingPhoto ? null : _pickAndUploadPhoto,
                        child: Stack(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    width: 3),
                              ),
                              child: ClipOval(
                                child: _isUploadingPhoto
                                    ? Container(
                                        color: Colors.white.withValues(alpha: 0.15),
                                        child: const Center(
                                          child: SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white),
                                          ),
                                        ),
                                      )
                                    : _photoUrl != null
                                        ? Image.network(
                                            _photoUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                _defaultAvatar(),
                                          )
                                        : _defaultAvatar(),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppColors.accent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.camera_alt_rounded,
                                    color: Colors.white, size: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(displayName,
                          style: GoogleFonts.playfairDisplay(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(email,
                          style: GoogleFonts.inter(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 13)),
                      const SizedBox(height: 20),
                      // ── Real-time Stats ──────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStat(analysisCount.toString(), 'Analyses'),
                          _buildStatDivider(),
                          _buildStat(savedCount.toString(), 'Saved'),
                          _buildStatDivider(),
                          _buildStat(arViewCount.toString(), 'AR Views'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Menu Options ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _buildOption(
                        context,
                        Icons.history_rounded,
                        'Analysis History',
                        'View your past room analyses',
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const AnalysisHistoryScreen())),
                      ),
                      _buildOption(
                        context,
                        Icons.favorite_rounded,
                        'Saved Items',
                        'Your favourite decor pieces',
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SavedScreen())),
                      ),
                      _buildOption(
                        context,
                        Icons.palette_rounded,
                        'Style Preferences',
                        'Customize your design profile',
                        onTap: () => _showStylePreferences(context),
                      ),
                      _buildOption(
                        context,
                        Icons.notifications_rounded,
                        'Notifications',
                        'Manage your alerts',
                        onTap: () => _showNotifications(context),
                      ),
                      _buildOption(
                        context,
                        Icons.help_outline_rounded,
                        'Help & Support',
                        'Get assistance',
                        onTap: () => _showHelpSupport(context),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.25)),
                        ),
                        child: TextButton.icon(
                          onPressed: () => _showLogoutDialog(context),
                          icon: Icon(Icons.logout_rounded,
                              color: AppColors.error.withValues(alpha: 0.8),
                              size: 20),
                          label: Text('Log Out',
                              style: GoogleFonts.inter(
                                  color: AppColors.error.withValues(alpha: 0.8),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14)),
                          style: TextButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('DecorMatch AI v1.0.0',
                          style: GoogleFonts.inter(
                              color: AppColors.tertiaryText, fontSize: 12)),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _defaultAvatar() => Container(
        color: Colors.white.withValues(alpha: 0.15),
        child:
            const Icon(Icons.person_rounded, size: 42, color: Colors.white),
      );

  Widget _buildStatDivider() => Container(
        width: 1,
        height: 30,
        margin: const EdgeInsets.symmetric(horizontal: 24),
        color: Colors.white.withValues(alpha: 0.2),
      );

  Widget _buildStat(String value, String label) => Column(
        children: [
          Text(value,
              style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
        ],
      );

  Widget _buildOption(BuildContext context, IconData icon, String title,
      String subtitle,
      {required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(title,
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.primaryText)),
        subtitle: Text(subtitle,
            style: GoogleFonts.inter(
                color: AppColors.secondaryText, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right_rounded,
            size: 20, color: AppColors.tertiaryText),
        onTap: onTap,
      ),
    );
  }

  // ── Style Preferences Sheet ───────────────────────────────────────────────

  void _showStylePreferences(BuildContext context) async {
    final existing = await UserService.getStylePreferences();
    if (!mounted) return;
    final styles = [
      'Minimalist', 'Bohemian', 'Modern', 'Scandinavian',
      'Industrial', 'Traditional Indian',
    ];

    // ⚠️ MUST be declared here — outside the builder callback.
    // If placed inside StatefulBuilder.builder it gets re-created on every
    // setSheet() call, which resets all selections immediately.
    final selected = <String>{...existing};

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: AppColors.divider,
                            borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                Text('Style Preferences',
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text('Select one or more styles you love',
                    style: GoogleFonts.inter(
                        color: AppColors.secondaryText, fontSize: 13)),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: styles.map((s) {
                    // Read directly from `selected` each build — not a
                    // captured `isSel` variable which would be stale.
                    final isSelected = selected.contains(s);
                    return GestureDetector(
                      onTap: () => setSheet(() {
                        if (selected.contains(s)) {
                          selected.remove(s);
                        } else {
                          selected.add(s);
                        }
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          // Emerald green (AppColors.primary) when selected
                          color: isSelected
                              ? AppColors.primary
                              : Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.divider,
                              width: 1.5),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : [],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected) ...[
                              const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 14),
                              const SizedBox(width: 6),
                            ],
                            Text(s,
                                style: GoogleFonts.inter(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.primaryText,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await UserService.saveStylePreferences(
                          selected.toList());
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text('Preferences saved!'),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ));
                    },
                    child: const Text('Save Preferences'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Notifications Sheet (fully functional) ────────────────────────────────

  void _showNotifications(BuildContext context) async {
    // Load current preferences before opening the sheet
    final initAnalysis = await NotificationService.analysisEnabled;
    final initReminders = await NotificationService.remindersEnabled;
    final initReco = await NotificationService.recoEnabled;
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) {
        // Declared outside StatefulBuilder so they persist across rebuilds
        bool analysisOn = initAnalysis;
        bool remindersOn = initReminders;
        bool recoOn = initReco;

        return StatefulBuilder(
          builder: (ctx, setSheet) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                      child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                              color: AppColors.divider,
                              borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 20),
                  Text('Notifications',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Choose which alerts you want to receive',
                      style: GoogleFonts.inter(
                          color: AppColors.secondaryText, fontSize: 13)),
                  const SizedBox(height: 20),

                  // 1. Analysis results
                  _notifTile(
                    icon: Icons.analytics_outlined,
                    title: 'Analysis Results',
                    subtitle: 'Notified instantly when your room analysis is ready',
                    value: analysisOn,
                    onChanged: (v) async {
                      setSheet(() => analysisOn = v);
                      await NotificationService.setAnalysisEnabled(v);
                    },
                  ),

                  // 2. Saved items reminders
                  _notifTile(
                    icon: Icons.favorite_outline_rounded,
                    title: 'Saved Items Reminders',
                    subtitle: 'Reminders to revisit your saved decor picks (4–5×/day)',
                    value: remindersOn,
                    onChanged: (v) async {
                      setSheet(() => remindersOn = v);
                      await NotificationService.setRemindersEnabled(v);
                      // If all are off → cancel all background tasks
                      if (!v && !recoOn) {
                        await cancelAllScheduledNotifications();
                      } else {
                        await schedulePeriodicNotifications();
                      }
                    },
                  ),

                  // 3. Recommendations
                  _notifTile(
                    icon: Icons.auto_awesome_outlined,
                    title: 'Style Recommendations',
                    subtitle: 'New curated decor matching your preferences (4–5×/day)',
                    value: recoOn,
                    onChanged: (v) async {
                      setSheet(() => recoOn = v);
                      await NotificationService.setRecoEnabled(v);
                      if (!v && !remindersOn) {
                        await cancelAllScheduledNotifications();
                      } else {
                        await schedulePeriodicNotifications();
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  // Info banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            color: AppColors.primary, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Reminder and recommendation notifications are '
                            'delivered 4–5 times throughout the day.',
                            style: GoogleFonts.inter(
                                color: AppColors.secondaryText,
                                fontSize: 12,
                                height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text('Notification preferences saved'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          duration: const Duration(seconds: 2),
                        ));
                      },
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// A styled notification toggle row matching the app's design system.
  Widget _notifTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Future<void> Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: value
            ? AppColors.primary.withValues(alpha: 0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: value
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.divider,
          width: value ? 1.5 : 0.8,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (value ? AppColors.primary : AppColors.secondaryText)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon,
                color: value ? AppColors.primary : AppColors.secondaryText,
                size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.primaryText)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.secondaryText,
                        height: 1.4)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: AppColors.primary,
            onChanged: (v) => onChanged(v),
          ),
        ],
      ),
    );
  }

  Widget _toggle(
      String title, String subtitle, bool value, ValueChanged<bool> onChange) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppColors.primaryText)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: GoogleFonts.inter(
                        color: AppColors.secondaryText, fontSize: 11)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChange, activeColor: AppColors.primary),
        ],
      ),
    );
  }

  // ── Help & Support Sheet ──────────────────────────────────────────────────

  void _showHelpSupport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text('Help & Support',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            _helpItem(Icons.chat_outlined, 'Chat with Support',
                'Get help from our design experts'),
            _helpItem(Icons.quiz_outlined, 'FAQ',
                'Find answers to common questions'),
            _helpItem(Icons.book_outlined, 'User Guide',
                'Learn how to use DecorMatch AI'),
            _helpItem(Icons.bug_report_outlined, 'Report a Bug',
                'Help us improve the experience'),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.divider, width: 0.5)),
              child: Column(children: [
                Text('Contact Us',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText)),
                const SizedBox(height: 4),
                Text('support@decormatch.ai',
                    style: GoogleFonts.inter(
                        color: AppColors.primary, fontSize: 13)),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _helpItem(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider, width: 0.5)),
      child: Row(children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.primaryText)),
            Text(subtitle,
                style: GoogleFonts.inter(
                    color: AppColors.secondaryText, fontSize: 11)),
          ]),
        ),
        const Icon(Icons.chevron_right_rounded,
            size: 18, color: AppColors.tertiaryText),
      ]),
    );
  }

  // ── Logout Dialog ─────────────────────────────────────────────────────────

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Log Out',
            style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700)),
        content: Text(
            'Are you sure you want to log out of DecorMatch AI?',
            style: GoogleFonts.inter(
                color: AppColors.secondaryText, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style:
                    GoogleFonts.inter(color: AppColors.secondaryText)),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            child: Text('Log Out',
                style: GoogleFonts.inter(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
