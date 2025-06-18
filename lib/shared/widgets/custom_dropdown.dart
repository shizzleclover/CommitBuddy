import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CustomDropdown<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String Function(T) itemBuilder;
  final void Function(T?) onChanged;
  final String? hint;
  final String? label;
  final bool isRequired;
  final String? errorText;
  final Widget? prefixIcon;
  final bool enabled;

  const CustomDropdown({
    super.key,
    this.value,
    required this.items,
    required this.itemBuilder,
    required this.onChanged,
    this.hint,
    this.label,
    this.isRequired = false,
    this.errorText,
    this.prefixIcon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label! + (isRequired ? ' *' : ''),
            style: AppTextStyles.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null 
                  ? AppColors.error 
                  : AppColors.lightGray,
              width: 1,
            ),
            color: enabled ? AppColors.white : AppColors.backgroundGray,
          ),
          child: DropdownButtonFormField<T>(
            value: value,
            onChanged: enabled ? onChanged : null,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              prefixIcon: prefixIcon,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              errorText: null, // We'll handle error display separately
            ),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
            dropdownColor: AppColors.white,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: enabled ? AppColors.textSecondary : AppColors.textTertiary,
            ),
            isExpanded: true,
            items: items.map((T item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(
                  itemBuilder(item),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }
} 