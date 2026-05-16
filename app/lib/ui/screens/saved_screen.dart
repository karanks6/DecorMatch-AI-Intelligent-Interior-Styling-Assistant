import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants.dart';
import '../../services/user_service.dart';
import '../../services/api_service.dart';
import 'product_detail_screen.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Saved Items',
            style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.w700, fontSize: 20)),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: UserService.savedItemsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading saved items.',
                  style: GoogleFonts.inter(color: AppColors.secondaryText)),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();
              return _SavedItemCard(
                product: data,
                onRemove: () => UserService.removeSavedItem(
                  (data['product_id'] ?? data['name'] ?? docs[index].id).toString(),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(Icons.favorite_border_rounded,
                  size: 48,
                  color: AppColors.accent.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 28),
            Text('No Saved Items Yet',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText)),
            const SizedBox(height: 12),
            Text(
              'Tap the ♥ heart icon on any recommended product to save it here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  color: AppColors.secondaryText, fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.camera_alt_outlined, size: 18),
              label: const Text('Analyze a Room'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                side:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedItemCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onRemove;

  const _SavedItemCard({required this.product, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final name = product['name'] ?? 'Decor Item';
    final style = product['style_category'] ?? '';
    final price = product['price'];
    final imageUrl = product['image_url_full'] ??
        (product['image_url'] != null
            ? '${ApiService.baseUrl}${product["image_url"]}'
            : '');

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(productData: product),
        ),
      ),
      child: Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(18)),
            child: SizedBox(
              width: 100,
              height: 100,
              child: imageUrl.isNotEmpty
                  ? Image.network(imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                            color: AppColors.secondary,
                            child: const Icon(Icons.image_outlined,
                                color: AppColors.tertiaryText, size: 28),
                          ))
                  : Container(
                      color: AppColors.secondary,
                      child: const Icon(Icons.image_outlined,
                          color: AppColors.tertiaryText, size: 28),
                    ),
            ),
          ),
          // Info
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (style.isNotEmpty)
                    Text(style,
                        style: GoogleFonts.inter(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                            letterSpacing: 0.5)),
                  const SizedBox(height: 4),
                  Text(name,
                      style: GoogleFonts.inter(
                          color: AppColors.primaryText,
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                  if (price != null) ...[
                    const SizedBox(height: 6),
                    Text('₹$price',
                        style: GoogleFonts.inter(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                  ],
                ],
              ),
            ),
          ),
          // Remove button — stops tap propagation so it doesn't open details
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => _confirmRemove(context),
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.favorite_rounded,
                    color: AppColors.error, size: 22),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  void _confirmRemove(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Remove Item',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Text('Remove "${product['name']}" from saved items?',
            style: GoogleFonts.inter(color: AppColors.secondaryText, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: AppColors.secondaryText)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onRemove();
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('Remove',
                style: GoogleFonts.inter(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
