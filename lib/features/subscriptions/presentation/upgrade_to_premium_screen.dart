import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../logic/subscription_provider.dart';
import '../data/subscription_model.dart';
import 'payment_screen.dart';
import 'widgets/pricing_plan_card.dart';
import 'widgets/premium_features_list.dart';

class UpgradeToPremiumScreen extends ConsumerStatefulWidget {
  const UpgradeToPremiumScreen({super.key});

  @override
  ConsumerState<UpgradeToPremiumScreen> createState() => _UpgradeToPremiumScreenState();
}

class _UpgradeToPremiumScreenState extends ConsumerState<UpgradeToPremiumScreen> {
  bool isYearlySelected = true;

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(availablePlansProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: const Text('Upgrade to Premium'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: plansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red.shade400,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load pricing plans',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(availablePlansProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (plans) {
          final premiumPlan = plans.firstWhere(
            (plan) => plan.plan == SubscriptionPlan.premium,
            orElse: () => SubscriptionPlanDetails.availablePlans.last,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryBlue, AppColors.sageGreen],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.workspace_premium,
                        color: Colors.white,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Unlock Premium Features',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Get unlimited access to all CommitBuddy features and support our development!',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Billing period toggle
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => isYearlySelected = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !isYearlySelected ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: !isYearlySelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              'Monthly',
                              style: TextStyle(
                                color: !isYearlySelected 
                                    ? AppColors.primaryBlue 
                                    : Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => isYearlySelected = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isYearlySelected ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: isYearlySelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Yearly',
                                  style: TextStyle(
                                    color: isYearlySelected 
                                        ? AppColors.primaryBlue 
                                        : Colors.grey.shade600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (isYearlySelected) ...[
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Save 17%',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Pricing card
                PricingPlanCard(
                  plan: premiumPlan,
                  isYearly: isYearlySelected,
                  isSelected: true,
                  onTap: () {},
                ),
                const SizedBox(height: 32),

                // Features list
                const Text(
                  'What you get with Premium:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 16),
                const PremiumFeaturesList(showOnlyPremiumFeatures: true),
                const SizedBox(height: 32),

                // Continue button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PaymentScreen(
                            plan: premiumPlan,
                            isYearly: isYearlySelected,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Continue to Payment - \$${isYearlySelected ? premiumPlan.yearlyPrice.toStringAsFixed(2) : premiumPlan.monthlyPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Terms and conditions
                Text(
                  '• Payment will be charged to your account\n'
                  '• Subscription automatically renews unless auto-renew is turned off\n'
                  '• Account will be charged for renewal within 24-hours prior to the end of the current period\n'
                  '• You can manage and cancel subscriptions in your account settings',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),

                // Support link
                Center(
                  child: TextButton(
                    onPressed: () {
                      // TODO: Open support/help screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Support coming soon!'),
                        ),
                      );
                    },
                    child: const Text(
                      'Questions? Contact Support',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
} 