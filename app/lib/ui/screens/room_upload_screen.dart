import 'package:flutter/material.dart';
import '../../core/constants.dart';
import 'analysis_results_screen.dart';

class RoomUploadScreen extends StatefulWidget {
  const RoomUploadScreen({super.key});

  @override
  State<RoomUploadScreen> createState() => _RoomUploadScreenState();
}

class _RoomUploadScreenState extends State<RoomUploadScreen> {
  bool _isAnalyzing = false;

  void _analyzeRoom() {
    setState(() {
      _isAnalyzing = true;
    });

    // Simulate API call and AI processing
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isAnalyzing = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AnalysisResultsScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Style Your Room'),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryText),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: AppColors.divider,
                        width: 2,
                        style: BorderStyle.solid),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined,
                            size: 64,
                            color: AppColors.primaryText.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text(
                          'Tap to Upload or Take a Photo',
                          style: TextStyle(
                              color: AppColors.primaryText.withOpacity(0.7)),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _isAnalyzing
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    )
                  : ElevatedButton(
                      onPressed: _analyzeRoom,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Analyze Room'),
                    ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
