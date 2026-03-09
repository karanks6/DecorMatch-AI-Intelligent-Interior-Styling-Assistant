import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class AnalysisResultsScreen extends StatelessWidget {
  final Map<String, dynamic> resultData;

  const AnalysisResultsScreen({super.key, required this.resultData});

  @override
  Widget build(BuildContext context) {
    final analysis = resultData['analysis'] ?? {};
    final recommendations =
        resultData['recommendations'] as List<dynamic>? ?? [];

    final style = analysis['style'] ?? 'Unknown Style';
    final confidence = ((analysis['confidence'] ?? 0.0) * 100).toInt();
    final dominantColors = List<String>.from(analysis['dominant_colors'] ?? []);
    final detectedItems = List<String>.from(analysis['detected_items'] ?? []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Results'),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryText),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 250,
              width: double.infinity,
              color: AppColors.secondary,
              child: const Icon(Icons.image,
                  size: 80, color: AppColors.secondaryText),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Detected Style',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            style,
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium
                                ?.copyWith(
                                  color: AppColors.primary,
                                ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$confidence% Match',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text('Color Palette',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Row(
                    children: dominantColors
                        .map((hex) => Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: _buildColorSwatch(_hexToColor(hex)),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 32),
                  if (detectedItems.isNotEmpty) ...[
                    Text('Detected Items (YOLOv8)',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: detectedItems
                          .map((item) => Chip(
                                label: Text(item.toUpperCase()),
                                backgroundColor: AppColors.secondary,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 32),
                  ],
                  Text('Recommended Decor',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 280,
                    child: recommendations.isEmpty
                        ? const Text("No recommendations found.")
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: recommendations.length,
                            itemBuilder: (context, index) {
                              final p = recommendations[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const ProductDetailScreen()),
                                    );
                                  },
                                  child: ProductCard(
                                    name: p['name'] ?? 'Style Item',
                                    styleCategory: p['style_category'] ?? style,
                                    imageUrl: p['image_url'] ??
                                        "https://via.placeholder.com/200",
                                    price: "\$${p['price'] ?? 0.0}",
                                  ),
                                ),
                              );
                            },
                          ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildColorSwatch(Color color) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
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
