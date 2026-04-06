import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ArPreviewScreen extends StatelessWidget {
  final String modelUrl;
  const ArPreviewScreen({super.key, required this.modelUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('AR Decor Preview',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // The model viewer with AR support
          ModelViewer(
            src: modelUrl,
            alt: 'A 3D model of a furniture item',
            ar: true,
            arModes: const ['scene-viewer', 'webxr', 'quick-look'],
            autoRotate: true,
            cameraControls: true,
            shadowIntensity: 1.0,
            backgroundColor: const Color(0xFF1A1A2E),
          ),
          // Instruction overlay at top
          Positioned(
            top: 16,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Pinch to zoom, drag to rotate.\nTap the AR button (bottom-right) to place it in your room!",
                style: TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
