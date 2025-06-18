import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/subscription_model.dart';

class PremiumFeaturesList extends StatelessWidget {
  final bool showOnlyPremiumFeatures;

  const PremiumFeaturesList({
    super.key,
    this.showOnlyPremiumFeatures = false,
  });

  @override
  Widget build(BuildContext context) {
    final features = showOnlyPremiumFeatures
        ? SubscriptionPlanDetails.availablePlans
            .firstWhere((plan) => plan.plan == SubscriptionPlan.premium)
            .features
        : [
            ...SubscriptionPlanDetails.availablePlans
                .firstWhere((plan) => plan.plan == SubscriptionPlan.free)
                .features,
            ...SubscriptionPlanDetails.availablePlans
                .firstWhere((plan) => plan.plan == SubscriptionPlan.premium)
                .features,
          ];

    return Column(
      children: features.map((feature) => _buildFeatureItem(feature)).toList(),
    );
  }

  Widget _buildFeatureItem(PremiumFeature feature) {
    final isPremium = feature.id.contains('unlimited') || 
                     feature.id.contains('advanced') || 
                     feature.id.contains('custom') || 
                     feature.id.contains('priority');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isPremium
            ? Border.all(color: AppColors.primaryBlue.withOpacity(0.3))
            : Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isPremium
                  ? AppColors.primaryBlue.withOpacity(0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              feature.icon,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        feature.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: isPremium ? AppColors.primaryBlue : Colors.black87,
                        ),
                      ),
                    ),
                    if (isPremium) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'PRO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'FREE',
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
                const SizedBox(height: 4),
                Text(
                  feature.description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            feature.isAvailable ? Icons.check_circle : Icons.lock,
            color: feature.isAvailable
                ? (isPremium ? AppColors.primaryBlue : Colors.green)
                : Colors.grey.shade400,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class FeatureComparisonTable extends StatelessWidget {
  const FeatureComparisonTable({super.key});

  @override
  Widget build(BuildContext context) {
    final freePlan = SubscriptionPlanDetails.availablePlans
        .firstWhere((plan) => plan.plan == SubscriptionPlan.free);
    final premiumPlan = SubscriptionPlanDetails.availablePlans
        .firstWhere((plan) => plan.plan == SubscriptionPlan.premium);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Features',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    freePlan.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    premiumPlan.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.primaryBlue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          
          // Feature rows
          ...freePlan.features.map((feature) => _buildComparisonRow(
            feature.title,
            true,
            false,
          )),
          ...premiumPlan.features.map((feature) => _buildComparisonRow(
            feature.title,
            false,
            true,
          )),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String feature, bool freeIncluded, bool premiumIncluded) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            child: Icon(
              freeIncluded ? Icons.check : Icons.close,
              color: freeIncluded ? Colors.green : Colors.red,
              size: 18,
            ),
          ),
          Expanded(
            child: Icon(
              premiumIncluded ? Icons.check : Icons.close,
              color: premiumIncluded ? AppColors.primaryBlue : Colors.red,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
} 