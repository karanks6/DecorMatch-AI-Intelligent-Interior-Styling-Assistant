import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../../core/constants.dart';
import '../../services/user_service.dart';

class ArPreviewScreen extends StatefulWidget {
  final String modelUrl;
  const ArPreviewScreen({super.key, required this.modelUrl});

  @override
  State<ArPreviewScreen> createState() => _ArPreviewScreenState();
}

class _ArPreviewScreenState extends State<ArPreviewScreen>
    with WidgetsBindingObserver {
  /// True once the OS switches to Scene Viewer (app goes to background).
  bool _arLaunched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    UserService.incrementArViews();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// When Scene Viewer takes over, the app pauses.
  /// When the user returns, it resumes — we immediately pop at that point.
  /// This prevents the RenderThread from trying to draw to a destroyed
  /// OpenGL surface (SIGABRT: drawRenderNode called on a context with no surface).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Scene Viewer / AR just launched
      _arLaunched = true;
    } else if (state == AppLifecycleState.resumed && _arLaunched) {
      // Returning from AR — close this screen before the WebView
      // tries to re-attach to the destroyed OpenGL surface.
      _arLaunched = false;
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1923),
      appBar: AppBar(
        title: Text('AR Preview',
            style: GoogleFonts.playfairDisplay(
                color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF0F1923),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Stack(
        children: [
          ModelViewer(
            src: widget.modelUrl,
            alt: 'A 3D model of a furniture item',
            ar: true,
            arModes: const ['scene-viewer', 'webxr', 'quick-look'],
            autoRotate: true,
            cameraControls: true,
            shadowIntensity: 1.0,
            backgroundColor: const Color(0xFF0F1923),
          ),
          // Instruction pill
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(30),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.touch_app_rounded,
                        color: AppColors.accentLight, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Pinch to zoom  •  Drag to rotate',
                      style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
