import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class OnboardingPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final Widget illustration;
  final Color backgroundColor;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.illustration,
    this.backgroundColor = AppColors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: backgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Illustration
              SizedBox(
                height: 300,
                child: illustration,
              ),
              
              const Spacer(),
              
              // Title
              Text(
                title,
                style: AppTextStyles.displaySmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Subtitle
              Text(
                subtitle,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Description
              Text(
                description,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
} 