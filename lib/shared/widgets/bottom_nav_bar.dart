import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_texts.dart';
import '../../core/constants/app_text_styles.dart';
import 'dynamic_date_icon.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDateNavItem(
                label: AppTexts.todayTab,
                index: 0,
              ),
              _buildNavItem(
                icon: Icon(PhosphorIcons.listBullets()),
                activeIcon: Icon(PhosphorIcons.listBullets(PhosphorIconsStyle.fill)),
                label: AppTexts.routinesTab,
                index: 1,
              ),
              _buildNavItem(
                icon: Icon(PhosphorIcons.users()),
                activeIcon: Icon(PhosphorIcons.users(PhosphorIconsStyle.fill)),
                label: AppTexts.buddiesTab,
                index: 2,
              ),
              _buildNavItem(
                icon: Icon(PhosphorIcons.user()),
                activeIcon: Icon(PhosphorIcons.user(PhosphorIconsStyle.fill)),
                label: AppTexts.profileTab,
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateNavItem({
    required String label,
    required int index,
  }) {
    final isActive = currentIndex == index;
    
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedDateIcon(
              size: 24,
              isActive: isActive,
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: AppTextStyles.labelSmall.copyWith(
                color: isActive ? AppColors.primaryBlue : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required Widget icon,
    required Widget activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = currentIndex == index;
    
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isActive
                  ? IconTheme(
                      key: ValueKey('active_$index'),
                      data: IconThemeData(
                        color: AppColors.primaryBlue,
                        size: 24,
                      ),
                      child: activeIcon,
                    )
                  : IconTheme(
                      key: ValueKey('inactive_$index'),
                      data: IconThemeData(
                        color: AppColors.textSecondary,
                        size: 24,
                      ),
                      child: icon,
                    ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: AppTextStyles.labelSmall.copyWith(
                color: isActive ? AppColors.primaryBlue : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
} 