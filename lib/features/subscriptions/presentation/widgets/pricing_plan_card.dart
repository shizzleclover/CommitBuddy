import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/subscription_model.dart';

class PricingPlanCard extends StatelessWidget {
  final SubscriptionPlanDetails plan;
  final bool isYearly;
  final bool isSelected;
  final VoidCallback onTap;

  const PricingPlanCard({
    super.key,
    required this.plan,
    required this.isYearly,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final price = isYearly ? plan.yearlyPrice : plan.monthlyPrice;
    final period = isYearly ? 'year' : 'month';
    final monthlyEquivalent = isYearly ? plan.yearlyPrice / 12 : plan.monthlyPrice;
    final savings = isYearly ? ((plan.monthlyPrice * 12) - plan.yearlyPrice) : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? AppColors.primaryBlue 
                : plan.isPopular 
                    ? AppColors.primaryBlue.withOpacity(0.5)
                    : Colors.grey.shade300,
            width: isSelected ? 2 : plan.isPopular ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? AppColors.primaryBlue.withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 12 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with popular badge
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.primaryBlue : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plan.description,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (plan.isPopular) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'POPULAR',
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
            const SizedBox(height: 20),

            // Price section
            if (plan.plan != SubscriptionPlan.free) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${price.toStringAsFixed(price == price.toInt() ? 0 : 2)}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primaryBlue : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '/$period',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
              
              if (isYearly && savings > 0) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Text(
                    'Save \$${savings.toStringAsFixed(2)} annually',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              
              if (isYearly) ...[
                const SizedBox(height: 4),
                Text(
                  '\$${monthlyEquivalent.toStringAsFixed(2)}/month when billed annually',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ] else ...[
              // Free plan
              const Text(
                'Free',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Forever',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            ],
            
            const SizedBox(height: 24),

            // Features list
            if (plan.features.isNotEmpty) ...[
              ...plan.features.take(3).map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? AppColors.primaryBlue 
                            : Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        feature.title,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
              
              if (plan.features.length > 3) ...[
                Text(
                  '+${plan.features.length - 3} more features',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],

            if (isSelected) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.primaryBlue,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                                          Text(
                        'Selected',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 