import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/buddy.dart';
import '../../../core/services/buddy_service.dart';

class BuddyProfileScreen extends StatefulWidget {
  final Buddy buddy;

  const BuddyProfileScreen({
    super.key,
    required this.buddy,
  });

  @override
  State<BuddyProfileScreen> createState() => _BuddyProfileScreenState();
}

class _BuddyProfileScreenState extends State<BuddyProfileScreen> {
  BuddyStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await BuddyService.getBuddyStats(widget.buddy.id);
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
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
          'Buddy Profile',
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
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 16),
                  _buildStatsGrid(),
                  const SizedBox(height: 16),
                  _buildAccountabilitySection(),
                  const SizedBox(height: 16),
                  _buildActivitySection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.white,
      ),
      child: Column(
        children: [
          // Profile Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: widget.buddy.profileImageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      color: AppColors.lightGray,
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      widget.buddy.initials,
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
          
          const SizedBox(height: 16),
          
          // Name and Username
          Text(
            widget.buddy.displayName,
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '@${widget.buddy.username}',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Accountability Level Badge
          if (_stats != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getAccountabilityColor(_stats!.accountabilityScore).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getAccountabilityColor(_stats!.accountabilityScore),
                ),
              ),
              child: Text(
                _stats!.accountabilityLevel,
                style: AppTextStyles.labelLarge.copyWith(
                  color: _getAccountabilityColor(_stats!.accountabilityScore),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    if (_stats == null) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'Current Streak',
              value: '${widget.buddy.currentStreak}',
              subtitle: 'days',
              icon: Icons.local_fire_department,
              color: AppColors.accentOrange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: 'Longest Streak',
              value: '${widget.buddy.longestStreak}',
              subtitle: 'days',
              icon: Icons.emoji_events,
              color: AppColors.accentGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
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
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountabilitySection() {
    if (_stats == null) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
          Row(
            children: [
              Icon(
                Icons.star,
                color: AppColors.accentGreen,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Accountability Score',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Score Progress Bar
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.lightGray.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _stats!.accountabilityScore / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getAccountabilityColor(_stats!.accountabilityScore),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${_stats!.accountabilityScore.toInt()}%',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getAccountabilityColor(_stats!.accountabilityScore),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Review Stats
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  label: 'Reviews Given',
                  value: '${_stats!.reviewsGiven}',
                ),
              ),
              Expanded(
                child: _buildMiniStat(
                  label: 'Reviews Received',
                  value: '${_stats!.reviewsReceived}',
                ),
              ),
              Expanded(
                child: _buildMiniStat(
                  label: 'Approval Rate',
                  value: '${(_stats!.approvalRate * 100).toInt()}%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildActivitySection() {
    if (_stats == null) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
          Row(
            children: [
              Icon(
                Icons.timeline,
                color: AppColors.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Recent Activity',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildActivityItem(
            icon: Icons.check_circle,
            color: AppColors.accentGreen,
            title: 'Reviewed 3 proof submissions',
            time: '2 hours ago',
          ),
          
          _buildActivityItem(
            icon: Icons.local_fire_department,
            color: AppColors.accentOrange,
            title: 'Maintained 12-day streak',
            time: '1 day ago',
          ),
          
          _buildActivityItem(
            icon: Icons.people,
            color: AppColors.primaryBlue,
            title: 'Became accountability buddies',
            time: '${DateTime.now().difference(widget.buddy.createdAt).inDays} days ago',
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Last active: ${_stats!.lastActiveAt != null ? _formatTime(_stats!.lastActiveAt!) : 'Unknown'}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color color,
    required String title,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  time,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getAccountabilityColor(double score) {
    if (score >= 80) return AppColors.accentGreen;
    if (score >= 60) return AppColors.primaryBlue;
    if (score >= 40) return AppColors.accentOrange;
    return AppColors.error;
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
} 