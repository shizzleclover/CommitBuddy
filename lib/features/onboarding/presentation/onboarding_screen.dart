import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_texts.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/onboarding_page.dart';
import '../../../app/router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 4;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToAuth();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    _navigateToAuth();
  }

  void _navigateToAuth() {
    AppRouter.pushReplacementNamed(context, AppRouter.login);
  }

  Widget _buildIllustration(IconData icon, Color color) {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 80,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Illustration',
            style: AppTextStyles.bodySmall.copyWith(
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // Page View
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              // Page 1 - Welcome
              OnboardingPage(
                title: AppTexts.onboarding1Title,
                subtitle: AppTexts.onboarding1Subtitle,
                description: AppTexts.onboarding1Description,
                illustration: _buildIllustration(
                  Icons.handshake_outlined,
                  AppColors.primaryBlue,
                ),
              ),
              
              // Page 2 - Routines
              OnboardingPage(
                title: AppTexts.onboarding2Title,
                subtitle: AppTexts.onboarding2Subtitle,
                description: AppTexts.onboarding2Description,
                illustration: _buildIllustration(
                  Icons.schedule_outlined,
                  AppColors.sageGreen,
                ),
              ),
              
              // Page 3 - Proof
              OnboardingPage(
                title: AppTexts.onboarding3Title,
                subtitle: AppTexts.onboarding3Subtitle,
                description: AppTexts.onboarding3Description,
                illustration: _buildIllustration(
                  Icons.camera_alt_outlined,
                  Colors.orange,
                ),
              ),
              
              // Page 4 - Accountability
              OnboardingPage(
                title: AppTexts.onboarding4Title,
                subtitle: AppTexts.onboarding4Subtitle,
                description: AppTexts.onboarding4Description,
                illustration: _buildIllustration(
                  Icons.people_outline,
                  Colors.purple,
                ),
              ),
            ],
          ),
          
          // Top Navigation (Skip button)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button (only show after first page)
                  if (_currentPage > 0)
                    GestureDetector(
                      onTap: _previousPage,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.arrow_back_ios,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              AppTexts.back,
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 60),
                  
                  // Skip Button
                  GestureDetector(
                    onTap: _skipOnboarding,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        AppTexts.skip,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Navigation
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Page Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _totalPages,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? AppColors.primaryBlue
                                : AppColors.mediumGray,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Next/Get Started Button
                    CustomButton(
                      text: _currentPage == _totalPages - 1
                          ? AppTexts.getStarted
                          : AppTexts.next,
                      onPressed: _nextPage,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 