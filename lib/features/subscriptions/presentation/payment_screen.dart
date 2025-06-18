import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../logic/subscription_provider.dart';
import '../data/subscription_model.dart';

enum PaymentMethod {
  creditCard,
  paypal,
  applePay,
  googlePay,
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.creditCard:
        return 'Credit/Debit Card';
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.applePay:
        return 'Apple Pay';
      case PaymentMethod.googlePay:
        return 'Google Pay';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethod.creditCard:
        return Icons.credit_card;
      case PaymentMethod.paypal:
        return Icons.account_balance_wallet;
      case PaymentMethod.applePay:
        return Icons.phone_iphone;
      case PaymentMethod.googlePay:
        return Icons.android;
    }
  }

  String get subtitle {
    switch (this) {
      case PaymentMethod.creditCard:
        return 'Visa, MasterCard, American Express';
      case PaymentMethod.paypal:
        return 'Pay with your PayPal account';
      case PaymentMethod.applePay:
        return 'Pay with Touch ID or Face ID';
      case PaymentMethod.googlePay:
        return 'Pay with your Google account';
    }
  }
}

class PaymentScreen extends ConsumerStatefulWidget {
  final SubscriptionPlanDetails plan;
  final bool isYearly;

  const PaymentScreen({
    super.key,
    required this.plan,
    required this.isYearly,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  PaymentMethod? selectedPaymentMethod;
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    const userId = 'user_123';
    final subscriptionState = ref.watch(subscriptionNotifierProvider(userId));
    
    final price = widget.isYearly ? widget.plan.yearlyPrice : widget.plan.monthlyPrice;
    final period = widget.isYearly ? 'year' : 'month';

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order summary
                  _buildOrderSummary(price, period),
                  const SizedBox(height: 32),

                  // Payment methods
                  const Text(
                    'Payment Method',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...PaymentMethod.values.map((method) => _buildPaymentMethodCard(method)),
                  const SizedBox(height: 24),

                  // Security notice
                  _buildSecurityNotice(),
                  const SizedBox(height: 16),

                  // Terms and conditions
                  _buildTermsText(),
                ],
              ),
            ),
          ),

          // Bottom payment button
          _buildPaymentButton(context, ref, userId, price, subscriptionState),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(double price, String period) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: AppColors.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.plan.title} Plan',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${widget.isYearly ? 'Annual' : 'Monthly'} subscription',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          if (widget.isYearly) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.savings,
                    color: Colors.green.shade700,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'You save \$${((widget.plan.monthlyPrice * 12) - widget.plan.yearlyPrice).toStringAsFixed(2)} per year!',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${price.toStringAsFixed(2)}/$period',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod method) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => setState(() => selectedPaymentMethod = method),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selectedPaymentMethod == method
                  ? AppColors.primaryBlue
                  : Colors.grey.shade300,
              width: selectedPaymentMethod == method ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                method.icon,
                color: selectedPaymentMethod == method
                    ? AppColors.primaryBlue
                    : Colors.grey.shade600,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: selectedPaymentMethod == method
                            ? AppColors.primaryBlue
                            : Colors.black,
                      ),
                    ),
                    Text(
                      method.subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (selectedPaymentMethod == method)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.security,
            color: Colors.blue.shade700,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your payment information is secure and encrypted. We don\'t store your card details.',
              style: TextStyle(
                color: Colors.blue.shade800,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsText() {
    return Text(
      'By completing this purchase, you agree to our Terms of Service and acknowledge that your subscription will automatically renew unless cancelled.',
      style: TextStyle(
        color: Colors.grey.shade600,
        fontSize: 12,
        height: 1.4,
      ),
    );
  }

  Widget _buildPaymentButton(BuildContext context, WidgetRef ref, String userId, double price, SubscriptionState subscriptionState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (subscriptionState.error != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      subscriptionState.error!,
                      style: TextStyle(
                        color: Colors.red.shade800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedPaymentMethod != null && !isProcessing && !subscriptionState.isProcessingPayment
                  ? () => _processPayment(context, ref, userId)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isProcessing || subscriptionState.isProcessingPayment
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Complete Payment - \$${price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment(BuildContext context, WidgetRef ref, String userId) async {
    if (selectedPaymentMethod == null) return;

    setState(() => isProcessing = true);

    try {
      await Future.delayed(const Duration(seconds: 2));

      final success = await ref
          .read(subscriptionNotifierProvider(userId).notifier)
          .subscribeToPlan(widget.plan.plan, widget.isYearly);

      setState(() => isProcessing = false);

      if (success) {
        _showSuccessDialog(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Payment Successful!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Welcome to CommitBuddy Premium! You now have access to all premium features.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 