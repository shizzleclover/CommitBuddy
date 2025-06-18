import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_texts.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../data/models/routine.dart';
import '../../../../shared/widgets/duration_picker.dart';

class SubtaskEditorTile extends StatefulWidget {
  final Subtask subtask;
  final Function(Subtask) onChanged;
  final VoidCallback onDelete;
  final bool showReorderHandle;

  const SubtaskEditorTile({
    super.key,
    required this.subtask,
    required this.onChanged,
    required this.onDelete,
    this.showReorderHandle = true,
  });

  @override
  State<SubtaskEditorTile> createState() => _SubtaskEditorTileState();
}

class _SubtaskEditorTileState extends State<SubtaskEditorTile> {
  late TextEditingController _nameController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.subtask.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGray.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (widget.showReorderHandle)
                    Container(
                      padding: const EdgeInsets.all(4),
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: AppColors.lightGray.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.drag_handle,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.subtask.name.isEmpty 
                              ? 'Untitled Subtask' 
                              : widget.subtask.name,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: widget.subtask.name.isEmpty 
                                ? AppColors.textSecondary 
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${widget.subtask.durationMinutes} min',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (widget.subtask.requiresPhotoProof) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accentGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.camera_alt,
                                      size: 12,
                                      color: AppColors.accentGreen,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Proof',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.accentGreen,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: widget.onDelete,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Expanded Content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: AppColors.lightGray),
                  const SizedBox(height: 16),
                  
                  // Name Input
                  Text(
                    AppTexts.subtaskName,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    onChanged: (value) => _updateSubtask(name: value),
                    decoration: InputDecoration(
                      hintText: AppTexts.subtaskNameHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.lightGray),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.lightGray),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primaryBlue,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Duration
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppTexts.duration,
                              style: AppTextStyles.labelMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DurationPicker(
                              minutes: widget.subtask.durationMinutes,
                              onChanged: (minutes) => _updateSubtask(
                                durationMinutes: minutes,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Photo Proof Toggle
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppTexts.requiresPhotoProof,
                              style: AppTextStyles.labelMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppTexts.photoProofTip,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: widget.subtask.requiresPhotoProof,
                        onChanged: (value) => _updateSubtask(
                          requiresPhotoProof: value,
                        ),
                        activeColor: AppColors.accentGreen,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            crossFadeState: _isExpanded 
                ? CrossFadeState.showSecond 
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  void _updateSubtask({
    String? name,
    int? durationMinutes,
    bool? requiresPhotoProof,
  }) {
    final updatedSubtask = widget.subtask.copyWith(
      name: name,
      durationMinutes: durationMinutes,
      requiresPhotoProof: requiresPhotoProof,
    );
    widget.onChanged(updatedSubtask);
  }
} 