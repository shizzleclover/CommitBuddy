import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/routine.dart';

class WeekdaySelector extends StatelessWidget {
  final List<Weekday> selectedDays;
  final Function(List<Weekday>) onChanged;

  const WeekdaySelector({
    super.key,
    required this.selectedDays,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: Weekday.values.map((day) {
        final isSelected = selectedDays.contains(day);
        return GestureDetector(
          onTap: () => _toggleDay(day),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryBlue : AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primaryBlue : AppColors.lightGray,
                width: 1.5,
              ),
            ),
            child: Text(
              day.displayName,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? AppColors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _toggleDay(Weekday day) {
    final newDays = List<Weekday>.from(selectedDays);
    if (newDays.contains(day)) {
      newDays.remove(day);
    } else {
      newDays.add(day);
    }
    onChanged(newDays);
  }
} 