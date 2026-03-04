import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class AnalysisResultsScreen extends StatelessWidget {
  const AnalysisResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                            'Bohemian',
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
                          '88% Match',
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
                    children: [
                      _buildColorSwatch(const Color(0xFFC65D4F)),
                      const SizedBox(width: 16),
                      _buildColorSwatch(const Color(0xFFD9A066)),
                      const SizedBox(width: 16),
                      _buildColorSwatch(const Color(0xFF3F4E4F)),
                    ],
                  ),
                  const SizedBox(height: 48),
                  Text('Recommended Decor',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 280,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ProductDetailScreen()),
                            );
                          },
                          child: ProductCard(
                            name: "Woven Wall Hanging",
                            styleCategory: "Bohemian",
                            imageUrl: "https://via.placeholder.com/200",
                            price: "\$45",
                          ),
                        ),
                        const SizedBox(width: 16),
                        ProductCard(
                          name: "Rattan Chair",
                          styleCategory: "Bohemian",
                          imageUrl: "https://via.placeholder.com/200",
                          price: "\$180",
                        ),
                      ],
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
}
