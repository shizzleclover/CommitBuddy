import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../core/services/accountability_service.dart';
import '../../subscriptions/data/accountability_model.dart';

class AccountabilitySettingsScreen extends ConsumerStatefulWidget {
  const AccountabilitySettingsScreen({super.key});

  @override
  ConsumerState<AccountabilitySettingsScreen> createState() => _AccountabilitySettingsScreenState();
}

class _AccountabilitySettingsScreenState extends ConsumerState<AccountabilitySettingsScreen> {
  AccountabilityCommitment? _commitment;
  AccountabilityStats? _stats;
  List<AccountabilityTransaction> _recentTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAccountabilityData();
  }

  Future<void> _loadAccountabilityData() async {
    setState(() => _isLoading = true);
    
    try {
      // This would normally get the current user ID from auth
      const userId = 'current_user_id'; // Replace with actual user ID
      
      final results = await Future.wait([
        AccountabilityService.getAccountabilityCommitment(userId),
        AccountabilityService.getAccountabilityStats(userId),
        AccountabilityService.getRecentTransactions(userId, limit: 5),
      ]);
      
      setState(() {
        _commitment = results[0] as AccountabilityCommitment?;
        _stats = results[1] as AccountabilityStats;
        _recentTransactions = results[2] as List<AccountabilityTransaction>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading accountability data: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Your Accountability Journey',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textSecondary,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryBlue,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadAccountabilityData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeMessage(),
                    const SizedBox(height: 24),
                    if (_commitment != null) ...[
                      _buildCurrentStatus(),
                      const SizedBox(height: 24),
                      _buildStatsOverview(),
                      const SizedBox(height: 24),
                      _buildRecentActivity(),
                      const SizedBox(height: 24),
                    ],
                    _buildHowItWorks(),
                    const SizedBox(height: 24),
                    _buildFAQ(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue.withOpacity(0.1),
            AppColors.sageGreen.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.2),
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
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.favorite,
                  color: AppColors.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'We Believe in You',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Your accountability system is designed with love and understanding. Every feature here exists to support your growth, not to punish your humanity.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '💫 Remember: Progress isn\'t about being perfect. It\'s about showing up consistently for yourself.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStatus() {
    if (_commitment == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Commitment Status',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatusCard(
                  title: 'Monthly Investment',
                  value: '\$${_commitment!.monthlyAmount.toStringAsFixed(0)}',
                  subtitle: 'Supporting your growth',
                  icon: Icons.handshake,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatusCard(
                  title: 'Current Balance',
                  value: '\$${_commitment!.currentBalance.toStringAsFixed(0)}',
                  subtitle: _commitment!.needsTopUp ? 'Consider adding funds' : 'Looking good!',
                  icon: Icons.account_balance_wallet,
                  color: _commitment!.needsTopUp ? AppColors.accentOrange : AppColors.sageGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _commitment!.isActive 
                  ? AppColors.sageGreen.withOpacity(0.1)
                  : AppColors.accentOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  _commitment!.isActive ? Icons.check_circle : Icons.pause_circle,
                  color: _commitment!.isActive ? AppColors.sageGreen : AppColors.accentOrange,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _commitment!.isActive 
                        ? 'Your accountability is active and supporting your journey'
                        : 'Accountability is paused - add funds to reactivate',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    if (_stats == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Growth Journey',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  label: 'Consecutive Days',
                  value: '${_stats!.consecutiveDays}',
                  icon: Icons.local_fire_department,
                  color: AppColors.accentOrange,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  label: 'Saved by Consistency',
                  value: '\$${_stats!.savingsFromAccountability.toStringAsFixed(0)}',
                  icon: Icons.savings,
                  color: AppColors.sageGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_stats!.punishmentRate > 0) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _stats!.isDoingWell 
                    ? AppColors.sageGreen.withOpacity(0.1)
                    : AppColors.accentOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _stats!.isDoingWell ? Icons.celebration : Icons.trending_up,
                    color: _stats!.isDoingWell ? AppColors.sageGreen : AppColors.accentOrange,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _stats!.isDoingWell
                          ? 'Amazing! You\'re doing great with consistency 🎉'
                          : 'Every step forward is progress. You\'ve got this! 💪',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (_recentTransactions.isEmpty)
            Text(
              'No recent activity. Start building your routines!',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          else
            ..._recentTransactions.map((transaction) => _buildTransactionItem(transaction)),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(AccountabilityTransaction transaction) {
    final isPositive = transaction.type == AccountabilityTransactionType.refund ||
                      transaction.type == AccountabilityTransactionType.deposit;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundGray,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isPositive 
                  ? AppColors.sageGreen.withOpacity(0.1)
                  : AppColors.accentOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              isPositive ? Icons.add : Icons.remove,
              color: isPositive ? AppColors.sageGreen : AppColors.accentOrange,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(transaction.createdAt),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isPositive ? '+' : '-'}\$${transaction.amount.toStringAsFixed(0)}',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: isPositive ? AppColors.sageGreen : AppColors.accentOrange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorks() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How Your Gentle Accountability Works',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildWorkStep(
            icon: Icons.favorite,
            title: 'Monthly Commitment',
            description: 'Your \$15/month investment shows you\'re serious about change. This funds the app and your accountability system.',
            color: AppColors.primaryBlue,
          ),
          const SizedBox(height: 12),
          _buildWorkStep(
            icon: Icons.track_changes,
            title: 'Gentle Reminders',
            description: 'If you miss a routine, a \$20 nudge is deducted from your balance. It\'s not punishment - it\'s a loving reminder to refocus.',
            color: AppColors.accentOrange,
          ),
          const SizedBox(height: 12),
          _buildWorkStep(
            icon: Icons.celebration,
            title: 'Celebrate Success',
            description: 'Consistent weeks earn you rewards. We want to celebrate your growth, not just highlight missed days.',
            color: AppColors.sageGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkStep({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
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

  Widget _buildFAQ() {
    final faqs = [
      {
        'question': 'Why the monthly commitment fee?',
        'answer': 'Research shows that when we invest in our goals, we\'re more likely to achieve them. Your \$15 investment demonstrates commitment to yourself and helps fund the features that support your journey.',
      },
      {
        'question': 'What happens when I miss a routine?',
        'answer': 'We deduct \$20 from your balance as a gentle reminder. This isn\'t about punishment - it\'s about creating meaningful consequences that help you stay focused on your goals.',
      },
      {
        'question': 'Can I get refunds for consistency?',
        'answer': 'Absolutely! Every 7 consecutive days without missing routines earns you a \$5 reward. We believe in celebrating your success, not just highlighting setbacks.',
      },
      {
        'question': 'What if my balance runs low?',
        'answer': 'We\'ll send gentle reminders to top up your account. If it gets too low, accountability pauses until you add funds. You\'re always in control.',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Frequently Asked Questions',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...faqs.map((faq) => _buildFAQItem(
            question: faq['question']!,
            answer: faq['answer']!,
          )),
        ],
      ),
    );
  }

  Widget _buildFAQItem({
    required String question,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
} 