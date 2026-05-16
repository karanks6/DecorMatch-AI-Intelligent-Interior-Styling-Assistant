import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import '../../services/user_service.dart';
import '../../core/constants.dart';
import 'ar_preview_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> productData;

  const ProductDetailScreen({super.key, required this.productData});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isSaved = false;
  bool _savingInProgress = false;

  Map<String, dynamic> get productData => widget.productData;

  String get _rawId =>
      (productData['product_id'] ?? productData['name'] ?? '').toString();

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
  }

  Future<void> _checkIfSaved() async {
    final saved = await UserService.isItemSaved(_rawId);
    if (mounted) setState(() => _isSaved = saved);
  }

  Future<void> _toggleSave() async {
    if (_savingInProgress) return;
    setState(() => _savingInProgress = true);
    try {
      if (_isSaved) {
        await UserService.removeSavedItem(_rawId);
        if (mounted) {
          setState(() => _isSaved = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Removed from saved items'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 1),
          ));
        }
      } else {
        await UserService.saveItem({
          ...productData,
          'image_url_full':
              '${ApiService.baseUrl}${productData["image_url"] ?? ""}',
        });
        if (mounted) {
          setState(() => _isSaved = true);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('✓ Saved to your collection'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 1),
          ));
        }
      }
    } finally {
      if (mounted) setState(() => _savingInProgress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 380.0,
            pinned: true,
            backgroundColor: AppColors.primary,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              // ── Heart / Save button — always visible backdrop ──────────
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(
                  child: _savingInProgress
                      ? Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(9),
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          ),
                        )
                      : GestureDetector(
                          onTap: _toggleSave,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              // Dark pill always visible on any background
                              color: _isSaved
                                  ? Colors.red.withValues(alpha: 0.85)
                                  : Colors.black.withValues(alpha: 0.40),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                _isSaved
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                key: ValueKey(_isSaved),
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    '${ApiService.baseUrl}${productData["image_url"]}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.secondary,
                      child: const Center(
                        child: Icon(Icons.image_not_supported_rounded,
                            size: 64, color: AppColors.tertiaryText),
                      ),
                    ),
                  ),
                  // Gradient overlay at bottom
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.5),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              transform: Matrix4.translationValues(0, -28, 0),
              // Extra top padding so style badge doesn't collide with the image
              padding: const EdgeInsets.fromLTRB(28, 36, 28, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Style badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      productData['style_category'] ?? 'Style',
                      style: GoogleFonts.inter(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Name + price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          productData['name'] ?? 'Decor Item',
                          style: GoogleFonts.playfairDisplay(
                            color: AppColors.primaryText,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '₹${productData['price'] ?? '0'}',
                        style: GoogleFonts.inter(
                          color: AppColors.primary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Divider
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: 20),

                  // Features
                  Text('Features',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _buildFeature(Icons.aspect_ratio_rounded, '3D Model'),
                      const SizedBox(width: 12),
                      _buildFeature(Icons.view_in_ar_rounded, 'AR Ready'),
                      const SizedBox(width: 12),
                      _buildFeature(Icons.palette_rounded, 'Style Match'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text('Description',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Text(
                    'Add a touch of texture and warmth to your space with this beautiful handcrafted piece. It perfectly complements your ${productData['style_category'] ?? ''} aesthetic.',
                    style: GoogleFonts.inter(
                      color: AppColors.secondaryText,
                      fontSize: 14,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // AR button
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ArPreviewScreen(
                                    modelUrl:
                                        '${ApiService.baseUrl}${productData["ar_model_url"]}',
                                  )),
                        );
                      },
                      icon: const Icon(Icons.view_in_ar_rounded, size: 20),
                      label: const Text('Preview in AR'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Cart button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.shopping_bag_outlined, size: 20),
                      label: const Text('Add to Cart'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider, width: 0.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 6),
            Text(label,
                style: GoogleFonts.inter(
                    color: AppColors.primaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
