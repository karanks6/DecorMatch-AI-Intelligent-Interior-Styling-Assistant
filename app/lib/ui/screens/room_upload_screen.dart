import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants.dart';
import '../../services/api_service.dart';
import 'analysis_results_screen.dart';

class RoomUploadScreen extends StatefulWidget {
  const RoomUploadScreen({super.key});

  @override
  State<RoomUploadScreen> createState() => _RoomUploadScreenState();
}

class _RoomUploadScreenState extends State<RoomUploadScreen> {
  bool _isAnalyzing = false;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _analyzeRoom() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final resultData = await _apiService.analyzeRoom(_imageFile!);
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnalysisResultsScreen(resultData: resultData),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Analysis failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
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
                child: GestureDetector(
                  onTap: _isAnalyzing ? null : _showImageSourceDialog,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: AppColors.divider,
                          width: 2,
                          style: BorderStyle.solid),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: _imageFile != null
                        ? Image.file(_imageFile!, fit: BoxFit.cover)
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_outlined,
                                    size: 64,
                                    color:
                                        AppColors.primaryText.withOpacity(0.5)),
                                const SizedBox(height: 16),
                                Text(
                                  'Tap to Upload or Take a Photo',
                                  style: TextStyle(
                                      color: AppColors.primaryText
                                          .withOpacity(0.7)),
                                )
                              ],
                            ),
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
                      onPressed: _imageFile != null
                          ? _analyzeRoom
                          : _showImageSourceDialog,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                          _imageFile != null ? 'Analyze Room' : 'Select Photo'),
                    ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
