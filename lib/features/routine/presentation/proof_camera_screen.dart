import 'package:flutter/material.dart';
import 'dart:io';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_texts.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/routine.dart';

class ProofCameraScreen extends StatefulWidget {
  final Subtask subtask;
  final String routineName;

  const ProofCameraScreen({
    super.key,
    required this.subtask,
    required this.routineName,
  });

  @override
  State<ProofCameraScreen> createState() => _ProofCameraScreenState();
}

class _ProofCameraScreenState extends State<ProofCameraScreen> {
  String? _capturedImagePath;
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Camera/Preview Area
            Expanded(
              child: _capturedImagePath == null
                  ? _buildCameraView()
                  : _buildImagePreview(),
            ),
            
            // Bottom Controls
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: AppColors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                                         Text(
                       AppTexts.photoProof,
                       style: AppTextStyles.headlineSmall.copyWith(
                         color: AppColors.white,
                         fontWeight: FontWeight.bold,
                       ),
                     ),
                    Text(
                      widget.routineName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.camera_alt,
                  color: AppColors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Take a photo to prove you completed: ${widget.subtask.name}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            size: 80,
            color: AppColors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 20),
                     Text(
             AppTexts.cameraPreview,
             style: AppTextStyles.titleLarge.copyWith(
               color: AppColors.white.withOpacity(0.8),
               fontWeight: FontWeight.w600,
             ),
           ),
           const SizedBox(height: 8),
           Text(
             AppTexts.cameraIntegrationSoon,
             style: AppTextStyles.bodyMedium.copyWith(
               color: AppColors.white.withOpacity(0.6),
             ),
           ),
          const SizedBox(height: 24),
          // Mock capture button for demo
          GestureDetector(
            onTap: _mockCapturePhoto,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryBlue,
                  width: 4,
                ),
              ),
              child: const Icon(
                Icons.camera,
                color: AppColors.primaryBlue,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accentGreen.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: AppColors.accentGreen,
          ),
          const SizedBox(height: 20),
                     Text(
             AppTexts.photoCaptured,
             style: AppTextStyles.titleLarge.copyWith(
               color: AppColors.white,
               fontWeight: FontWeight.w600,
             ),
           ),
          const SizedBox(height: 8),
          Text(
            'Great job completing: ${widget.subtask.name}',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 24),
          
          // Notes Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                                 Text(
                   AppTexts.addNoteOptional,
                   style: AppTextStyles.labelMedium.copyWith(
                     color: AppColors.white,
                     fontWeight: FontWeight.w600,
                   ),
                 ),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white,
                  ),
                  decoration: InputDecoration(
                                         hintText: AppTexts.howDidItGo,
                    hintStyle: TextStyle(
                      color: AppColors.white.withOpacity(0.6),
                    ),
                    filled: true,
                    fillColor: AppColors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: AppColors.black,
      child: Column(
        children: [
          if (_capturedImagePath != null) ...[
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _retakePhoto,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.white,
                      side: BorderSide(
                        color: AppColors.white.withOpacity(0.5),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      AppTexts.retake,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitProof,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGreen,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.white,
                              ),
                            ),
                          )
                        : Text(
                            AppTexts.submitProof,
                            style: AppTextStyles.labelLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.white.withOpacity(0.8),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppTexts.takeClearPhoto,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _mockCapturePhoto() {
    setState(() {
      _capturedImagePath = 'mock_image_path_${DateTime.now().millisecondsSinceEpoch}';
    });
  }

  void _retakePhoto() {
    setState(() {
      _capturedImagePath = null;
      _notesController.clear();
    });
  }

  void _submitProof() async {
    if (_capturedImagePath == null) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate upload delay
    await Future.delayed(const Duration(seconds: 1));

    // Return the image path to the runner screen
    if (mounted) {
      Navigator.pop(context, _capturedImagePath);
    }
  }
} 