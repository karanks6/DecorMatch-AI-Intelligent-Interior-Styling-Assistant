import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin_flutterflow/ar_flutter_plugin.dart';
import '../../core/constants.dart';

class ArPreviewScreen extends StatefulWidget {
  const ArPreviewScreen({super.key});

  @override
  State<ArPreviewScreen> createState() => _ArPreviewScreenState();
}

class _ArPreviewScreenState extends State<ArPreviewScreen> {
  // In a real implementation this would manage AR nodes and controllers

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR Preview', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // The actual AR View plugin goes here
          Container(
            color: Colors.black87,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.view_in_ar,
                      size: 100, color: Colors.white54),
                  const SizedBox(height: 24),
                  Text(
                    'Point camera at a flat surface',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '(AR Plugin requires physical device)',
                    style: TextStyle(color: Colors.white54),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: 'rotate',
                  onPressed: () {},
                  backgroundColor: AppColors.cardSurface,
                  child: const Icon(Icons.rotate_right,
                      color: AppColors.primaryText),
                ),
                const SizedBox(width: 32),
                FloatingActionButton(
                  heroTag: 'place',
                  onPressed: () {},
                  backgroundColor: AppColors.primary,
                  child:
                      const Icon(Icons.add_location_alt, color: Colors.white),
                ),
                const SizedBox(width: 32),
                FloatingActionButton(
                  heroTag: 'scale',
                  onPressed: () {},
                  backgroundColor: AppColors.cardSurface,
                  child: const Icon(Icons.settings_overscan,
                      color: AppColors.primaryText),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
