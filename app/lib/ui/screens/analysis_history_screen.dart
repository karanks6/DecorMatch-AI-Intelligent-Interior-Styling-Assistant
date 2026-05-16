import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants.dart';
import '../../services/user_service.dart';

class AnalysisHistoryScreen extends StatelessWidget {
  const AnalysisHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Analysis History',
            style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.w700, fontSize: 20)),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: UserService.analysisHistoryStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Could not load history.',
                  style: GoogleFonts.inter(color: AppColors.secondaryText)),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();
              return _HistoryCard(data: data);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(Icons.history_rounded,
                  size: 48,
                  color: AppColors.primary.withValues(alpha: 0.4)),
            ),
            const SizedBox(height: 28),
            Text('No Analyses Yet',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText)),
            const SizedBox(height: 12),
            Text(
              'Your room analysis history will appear here after you upload and analyze a room photo.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  color: AppColors.secondaryText, fontSize: 14, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _HistoryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final style = data['style'] ?? 'Unknown Style';
    final confidence = ((data['confidence'] ?? 0.0) * 100).toInt();
    final roomType = (data['roomType'] ?? 'Room').toString();
    final colors = List<String>.from(data['dominant_colors'] ?? []);
    final items = List<String>.from(data['detected_items'] ?? []);
    final recCount = data['recommendationCount'] ?? 0;
    final timestamp = data['timestamp'] as Timestamp?;
    final dateStr = timestamp != null
        ? _formatDate(timestamp.toDate())
        : 'Just now';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Row: style + date ────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Text(style,
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText)),
                ),
                Text(dateStr,
                    style: GoogleFonts.inter(
                        color: AppColors.tertiaryText, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 10),

            // ── Badges ───────────────────────────────────────────────────
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _badge('$confidence% Confidence', AppColors.primary),
                _badge(
                    _capitalize(roomType.replaceAll('_', ' ')),
                    AppColors.accent),
                _badge('$recCount Recommendations',
                    const Color(0xFF6366F1)),
              ],
            ),
            const SizedBox(height: 14),

            // ── Color Palette ────────────────────────────────────────────
            if (colors.isNotEmpty) ...[
              Text('Color Palette',
                  style: GoogleFonts.inter(
                      color: AppColors.secondaryText,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5)),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 22,
                  child: Row(
                    children: colors.map((hex) {
                      return Expanded(
                          child: Container(color: _hexToColor(hex)));
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // ── Detected Items ───────────────────────────────────────────
            if (items.isNotEmpty) ...[
              Text('Detected Items',
                  style: GoogleFonts.inter(
                      color: AppColors.secondaryText,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: items
                    .map((item) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: AppColors.divider, width: 0.5),
                          ),
                          child: Text(item,
                              style: GoogleFonts.inter(
                                  color: AppColors.primaryText,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500)),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Text(label,
          style: GoogleFonts.inter(
              color: color, fontWeight: FontWeight.w600, fontSize: 11)),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) {
      if (diff.inHours == 0) return '${diff.inMinutes}m ago';
      return '${diff.inHours}h ago';
    }
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
