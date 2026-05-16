import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  String _selectedRoomType = 'bedroom';

  final List<Map<String, dynamic>> _roomTypes = [
    {'key': 'bedroom', 'label': 'Bedroom', 'icon': Icons.bed_rounded},
    {'key': 'living_room', 'label': 'Living Room', 'icon': Icons.weekend_rounded},
    {'key': 'drawing room', 'label': 'Drawing Room', 'icon': Icons.chair_rounded},
    {'key': 'kitchen', 'label': 'Kitchen', 'icon': Icons.kitchen_rounded},
  ];

  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() => _imageFile = File(pickedFile.path));
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Select Image Source',
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildSourceOption(
                        Icons.camera_alt_rounded,
                        'Camera',
                        () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.camera);
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildSourceOption(
                        Icons.photo_library_rounded,
                        'Gallery',
                        () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.gallery);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSourceOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider, width: 0.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 32),
            const SizedBox(height: 8),
            Text(label, style: GoogleFonts.inter(
              color: AppColors.primaryText,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            )),
          ],
        ),
      ),
    );
  }

  Future<void> _analyzeRoom() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      final resultData = await _apiService.analyzeRoom(_imageFile!, _selectedRoomType);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnalysisResultsScreen(
            resultData: resultData,
            roomType: _selectedRoomType,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Analysis failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Style Your Room')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Upload zone
              Expanded(
                child: GestureDetector(
                  onTap: _isAnalyzing ? null : _showImageSourceDialog,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: _imageFile != null ? Colors.transparent : AppColors.secondary,
                      borderRadius: BorderRadius.circular(22),
                      border: _imageFile == null
                          ? Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5)
                          : null,
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: _imageFile != null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(_imageFile!, fit: BoxFit.cover),
                              Positioned(
                                bottom: 12, right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 16),
                                      const SizedBox(width: 6),
                                      Text('Change', style: GoogleFonts.inter(
                                        color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500,
                                      )),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 72, height: 72,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Icon(Icons.add_a_photo_outlined,
                                      size: 32, color: AppColors.primary.withOpacity(0.5)),
                                ),
                                const SizedBox(height: 16),
                                Text('Tap to Upload or Take a Photo',
                                    style: GoogleFonts.inter(
                                      color: AppColors.secondaryText,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    )),
                                const SizedBox(height: 6),
                                Text('JPG, PNG up to 10MB',
                                    style: GoogleFonts.inter(
                                      color: AppColors.tertiaryText,
                                      fontSize: 12,
                                    )),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Room type
              Text('Room Type',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _roomTypes.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final type = _roomTypes[index];
                    final isSelected = _selectedRoomType == type['key'];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedRoomType = type['key']),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.divider,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(type['icon'] as IconData,
                                size: 16,
                                color: isSelected ? Colors.white : AppColors.secondaryText),
                            const SizedBox(width: 8),
                            Text(
                              type['label'] as String,
                              style: GoogleFonts.inter(
                                color: isSelected ? Colors.white : AppColors.primaryText,
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),

              // Analyze button
              _isAnalyzing
                  ? Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text('Analyzing your room...',
                              style: GoogleFonts.inter(
                                  color: AppColors.primary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )
                  : Container(
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
                        onPressed: _imageFile != null ? _analyzeRoom : _showImageSourceDialog,
                        icon: Icon(_imageFile != null ? Icons.auto_awesome : Icons.add_photo_alternate_outlined, size: 20),
                        label: Text(_imageFile != null ? 'Analyze Room' : 'Select Photo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
