import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants.dart';
import '../../services/api_service.dart';
import '../../services/user_service.dart';
import '../../services/notification_service.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class AnalysisResultsScreen extends StatefulWidget {
  final Map<String, dynamic> resultData;
  final String roomType;

  const AnalysisResultsScreen({
    super.key,
    required this.resultData,
    required this.roomType,
  });

  @override
  State<AnalysisResultsScreen> createState() => _AnalysisResultsScreenState();
}

class _AnalysisResultsScreenState extends State<AnalysisResultsScreen> {
  final Set<String> _savedIds = {};
  bool _historySaved = false;

  late final Map<String, dynamic> _analysis;
  late final List<dynamic> _recommendations;

  @override
  void initState() {
    super.initState();
    _analysis = widget.resultData['analysis'] ?? {};
    _recommendations = widget.resultData['recommendations'] as List<dynamic>? ?? [];
    _saveHistoryOnce();
  }

  Future<void> _saveHistoryOnce() async {
    if (_historySaved) return;
    _historySaved = true;
    await UserService.saveAnalysis(
      analysis: _analysis,
      recommendationCount: _recommendations.length,
      roomType: widget.roomType,
    );
    // Fire analysis-complete notification
    await NotificationService.showAnalysisComplete(
      style: (_analysis['style'] ?? 'your style').toString(),
      itemCount: _recommendations.length,
    );
  }

  Future<void> _toggleSave(Map<String, dynamic> product) async {
    final id = (product['product_id'] ?? product['name'] ?? '').toString();
    final safeId = id.replaceAll(RegExp(r'[^\w]'), '_').toLowerCase();
    final isSaved = _savedIds.contains(safeId);

    setState(() {
      if (isSaved) {
        _savedIds.remove(safeId);
      } else {
        _savedIds.add(safeId);
      }
    });

    if (isSaved) {
      await UserService.removeSavedItem(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Removed from saved items'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 1),
        ));
      }
    } else {
      await UserService.saveItem({
        ...product,
        'image_url_full': '${ApiService.baseUrl}${product["image_url"] ?? ""}',
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('✓ Saved to your collection'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 1),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _analysis['style'] ?? 'Unknown Style';
    final confidence = ((_analysis['confidence'] ?? 0.0) * 100).toInt();
    final dominantColors = List<String>.from(_analysis['dominant_colors'] ?? []);
    final detectedItems = List<String>.from(_analysis['detected_items'] ?? []);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Gradient Header ────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Detected Style',
                            style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w400)),
                        const SizedBox(height: 4),
                        Text(style,
                            style: GoogleFonts.playfairDisplay(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text('$confidence% Confidence',
                                  style: GoogleFonts.inter(
                                      color: AppColors.accentLight,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(widget.roomType.toUpperCase(),
                                  style: GoogleFonts.inter(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 11,
                                      letterSpacing: 0.8)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Color Palette ──────────────────────────────────────────
                  if (dominantColors.isNotEmpty) ...[
                    Text('Color Palette',
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 20, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.divider, width: 0.5),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Row(
                        children: dominantColors
                            .map((hex) => Expanded(
                                child: Container(color: _hexToColor(hex))))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: dominantColors
                          .map((hex) => Expanded(
                                child: Text(
                                  hex.toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                      color: AppColors.tertiaryText,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.5),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 28),
                  ],

                  // ── Detected Items ─────────────────────────────────────────
                  if (detectedItems.isNotEmpty) ...[
                    Text('Detected Items',
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 20, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: detectedItems
                          .map((item) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: AppColors.divider, width: 0.5),
                                ),
                                child: Text(item,
                                    style: GoogleFonts.inter(
                                        color: AppColors.primaryText,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500)),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 28),
                  ],

                  // ── Recommendations ────────────────────────────────────────
                  Text('Recommended Decor',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 20, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Curated pieces to match your style — tap ♥ to save',
                      style: GoogleFonts.inter(
                          color: AppColors.secondaryText, fontSize: 13)),
                  const SizedBox(height: 16),

                  SizedBox(
                    height: 300,
                    child: _recommendations.isEmpty
                        ? Center(
                            child: Text('No recommendations found.',
                                style: GoogleFonts.inter(
                                    color: AppColors.secondaryText)))
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _recommendations.length,
                            itemBuilder: (context, index) {
                              final p = _recommendations[index] as Map<String, dynamic>;
                              final rawId = (p['product_id'] ?? p['name'] ?? index.toString()).toString();
                              final safeId = rawId.replaceAll(RegExp(r'[^\w]'), '_').toLowerCase();
                              final isSaved = _savedIds.contains(safeId);

                              return Padding(
                                padding: const EdgeInsets.only(right: 14),
                                child: SizedBox(
                                  width: 190,
                                  child: Stack(
                                    children: [
                                      GestureDetector(
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => ProductDetailScreen(
                                                  productData: p)),
                                        ),
                                        child: ProductCard(
                                          name: p['name'] ?? 'Style Item',
                                          styleCategory:
                                              p['style_category'] ?? style,
                                          imageUrl: p['image_url'] != null
                                              ? '${ApiService.baseUrl}${p["image_url"]}'
                                              : '',
                                          price: '₹${p['price'] ?? 0}',
                                        ),
                                      ),
                                      // Save heart button
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: GestureDetector(
                                          onTap: () => _toggleSave(p),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            width: 34,
                                            height: 34,
                                            decoration: BoxDecoration(
                                              color: isSaved
                                                  ? AppColors.error
                                                  : Colors.white
                                                      .withValues(alpha: 0.9),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.12),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              isSaved
                                                  ? Icons.favorite_rounded
                                                  : Icons
                                                      .favorite_border_rounded,
                                              color: isSaved
                                                  ? Colors.white
                                                  : AppColors.tertiaryText,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
