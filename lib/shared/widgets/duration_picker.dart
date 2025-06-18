import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_texts.dart';
import '../../core/constants/app_text_styles.dart';

class DurationPicker extends StatelessWidget {
  final int minutes;
  final Function(int) onChanged;
  final int minMinutes;
  final int maxMinutes;

  const DurationPicker({
    super.key,
    required this.minutes,
    required this.onChanged,
    this.minMinutes = 1,
    this.maxMinutes = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => _decrementMinutes(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.lightGray.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.remove,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 80,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$minutes',
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
                Text(
                  AppTexts.minutes,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => _incrementMinutes(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.add,
                size: 20,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _incrementMinutes() {
    if (minutes < maxMinutes) {
      onChanged(minutes + 1);
    }
  }

  void _decrementMinutes() {
    if (minutes > minMinutes) {
      onChanged(minutes - 1);
    }
  }
} 