import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../app/router.dart';

class CommitmentOnboardingScreen extends ConsumerStatefulWidget {
  const CommitmentOnboardingScreen({super.key});

  @override
  ConsumerState<CommitmentOnboardingScreen> createState() => _CommitmentOnboardingScreenState();
}

class _CommitmentOnboardingScreenState extends ConsumerState<CommitmentOnboardingScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          _buildHeader(),
                          const SizedBox(height: 40),
                          _buildCommitmentExplanation(),
                          const SizedBox(height: 32),
                          _buildAccountabilityFeatures(),
                          const SizedBox(height: 32),
                          _buildPricingCard(),
                          const SizedBox(height: 32),
                          _buildHowItWorks(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              _buildBottomActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryBlue,
                AppColors.primaryBlue.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.handshake,
            color: AppColors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Your Accountability\nCommitment',
          style: AppTextStyles.headlineLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Transform your goals into reality with gentle accountability and meaningful support.',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCommitmentExplanation() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.lightSageGreen,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.sageGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.sageGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.favorite,
                  color: AppColors.sageGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Why We Care About Your Success',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'We believe in your potential to build lasting habits. That\'s why we\'ve created a gentle accountability system that supports your journey with love, not judgment.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '💚 Your success is our mission\n'
            '🤝 We\'re here to support, not punish\n'
            '🌱 Every small step counts towards growth',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountabilityFeatures() {
    final features = [
      {
        'icon': Icons.track_changes,
        'title': 'Gentle Reminders',
        'description': 'Loving nudges to keep you on track with your goals',
        'color': AppColors.primaryBlue,
      },
      {
        'icon': Icons.people,
        'title': 'Buddy Support',
        'description': 'Connect with like-minded people on similar journeys',
        'color': AppColors.sageGreen,
      },
      {
        'icon': Icons.insights,
        'title': 'Progress Insights',
        'description': 'Celebrate your wins and learn from setbacks',
        'color': AppColors.accentOrange,
      },
      {
        'icon': Icons.psychology,
        'title': 'Mindful Accountability',
        'description': 'Small consequences that encourage consistency',
        'color': AppColors.accentPurple,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What Makes Us Different',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...features.map((feature) => _buildFeatureCard(
          icon: feature['icon'] as IconData,
          title: feature['title'] as String,
          description: feature['description'] as String,
          color: feature['color'] as Color,
        )),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue,
            AppColors.primaryBlue.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: AppColors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Your Commitment Investment',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$15',
                style: AppTextStyles.headlineLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                  fontSize: 48,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '/month',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'This isn\'t just a subscription - it\'s your commitment to becoming the person you want to be.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '💡 The small monthly investment helps you take your goals seriously while funding the support system that keeps you motivated.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.white,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How Gentle Accountability Works',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.lightGray.withOpacity(0.5),
            ),
          ),
          child: Column(
            children: [
              _buildHowItWorksStep(
                number: '1',
                title: 'Set Your Routines',
                description: 'Create meaningful habits that align with your goals',
                color: AppColors.primaryBlue,
              ),
              const SizedBox(height: 16),
              _buildHowItWorksStep(
                number: '2',
                title: 'Track Progress',
                description: 'Complete your routines and build momentum',
                color: AppColors.sageGreen,
              ),
              const SizedBox(height: 16),
              _buildHowItWorksStep(
                number: '3',
                title: 'Gentle Consequences',
                description: 'If you miss a day, a small \$20 reminder helps you refocus (from your monthly commitment)',
                color: AppColors.accentOrange,
              ),
              const SizedBox(height: 16),
              _buildHowItWorksStep(
                number: '4',
                title: 'Celebrate Success',
                description: 'Consistent streaks earn you rewards and build lasting confidence',
                color: AppColors.accentPurple,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHowItWorksStep({
    required String number,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: Text(
              number,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _proceedToPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Start My Accountability Journey - \$15/month',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _proceedToAuth,
          child: Text(
            'I\'ll decide later',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Cancel anytime • No hidden fees • Your data is secure',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _proceedToPayment() {
    // TODO: Navigate to payment setup
    // For now, just proceed to auth
    _proceedToAuth();
  }

  void _proceedToAuth() {
    // Navigate to auth screen
    AppRouter.pushReplacementNamed(context, AppRouter.login);
  }
} 