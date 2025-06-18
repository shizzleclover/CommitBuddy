import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../logic/profile_providers.dart';
import '../../auth/logic/auth_providers.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/achievements_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {

  @override
  void initState() {
    super.initState();
    // Load all profile data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final isLoading = profileState.isLoading;
    final profile = profileState.profile;
    final stats = profileState.stats;
    final achievements = profileState.achievements;
    final activity = profileState.activity;
    final achievementStats = profileState.achievementStats;
    final currentUser = AuthService.getCurrentUser();

    // Show error snackbar if there's an error
    ref.listen<ProfileState>(profileProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.destructive,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Profile',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showSettingsMenu,
            icon: const Icon(
              Icons.settings,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      body: isLoading && profile == null
          ? const Center(
              child: LoadingWidget(
                type: LoadingType.threeBounce,
                message: 'Loading profile...',
              ),
            )
          : profile == null
              ? _buildEmptyProfile()
              : RefreshIndicator(
                  onRefresh: () => ref.read(profileProvider.notifier).refresh(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        _buildProfileHeader(profile, currentUser),
                        const SizedBox(height: 24),
                        _buildStatsSection(stats),
                        const SizedBox(height: 24),
                        _buildAchievementsSection(achievements, achievementStats),
                        const SizedBox(height: 24),
                        _buildActivitySection(activity),
                        const SizedBox(height: 24),
                        _buildSettingsSection(),
                        const SizedBox(height: 100), // Bottom padding
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic>? profile, dynamic currentUser) {
    final displayName = profile?['display_name'] ?? currentUser?.userMetadata?['display_name'] ?? 'User';
    final username = profile?['username'] ?? currentUser?.email?.split('@')[0] ?? 'user';
    final email = profile?['email'] ?? currentUser?.email ?? '';
    final profileImageUrl = profile?['profile_image_url'];
    final joinDate = profile?['created_at'] != null 
        ? DateTime.parse(profile!['created_at']) 
        : DateTime.now();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
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
          // Profile Picture
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: profileImageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.network(
                      profileImageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            _getInitials(displayName),
                            style: AppTextStyles.headlineLarge.copyWith(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Text(
                      _getInitials(displayName),
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
          
          const SizedBox(height: 16),
          
          // Name and Username
          Text(
            displayName,
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '@$username',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Quick Stats
          Consumer(
            builder: (context, ref, child) {
              final stats = ref.watch(profileStatsProvider);
              
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickStat(
                    value: '${stats?['current_streak'] ?? 0}',
                    label: 'Day Streak',
                    color: AppColors.accentOrange,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppColors.lightGray,
                  ),
                  _buildQuickStat(
                    value: '${stats?['total_routines'] ?? 0}',
                    label: 'Routines',
                    color: AppColors.primaryBlue,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppColors.lightGray,
                  ),
                  _buildQuickStat(
                    value: '${stats?['buddies_count'] ?? 0}',
                    label: 'Buddies',
                    color: AppColors.sageGreen,
                  ),
                ],
              );
            },
          ),
          
          const SizedBox(height: 20),
          
          // Edit Profile Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _editProfile,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                side: const BorderSide(color: AppColors.primaryBlue),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Edit Profile'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat({
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headlineMedium.copyWith(
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
        ),
      ],
    );
  }

  Widget _buildStatsSection(Map<String, dynamic>? stats) {
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
          Text(
            'Your Progress',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.assignment_turned_in,
                  value: '${stats?['completed_sessions'] ?? 0}',
                  label: 'Sessions\nCompleted',
                  color: AppColors.accentGreen,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.timer,
                  value: '${((stats?['total_minutes'] ?? 0) / 60).round()}h',
                  label: 'Total Time\nInvested',
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.local_fire_department,
                  value: '${stats?['longest_streak'] ?? 0}',
                  label: 'Longest\nStreak',
                  color: AppColors.accentOrange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.trending_up,
                  value: '${_calculateSuccessRate(stats)}%',
                  label: 'Success\nRate',
                  color: AppColors.sageGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 12),
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
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(List<Map<String, dynamic>> achievements, Map<String, dynamic>? achievementStats) {
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
              Text(
                'Achievements',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              if (achievementStats != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${achievementStats['earned_achievements']}/${achievementStats['total_achievements']}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.accentGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (achievements.isEmpty)
            _buildEmptyAchievements()
          else
            ...achievements.map((achievement) => _buildAchievementTile(achievement)),
            
          if (achievements.isNotEmpty)
            const SizedBox(height: 12),
            
          // Refresh achievements button
          TextButton.icon(
            onPressed: () async {
              await ref.read(profileProvider.notifier).checkAchievements();
            },
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Check for new achievements'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyAchievements() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 48,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No achievements yet',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Complete routines to unlock achievements!',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementTile(Map<String, dynamic> achievement) {
    final isEarned = achievement['is_earned'] as bool;
    final currentProgress = achievement['current_progress'] ?? 0;
    final requirementValue = achievement['requirement_value'] ?? 1;
    final progressPercentage = requirementValue > 0 ? (currentProgress / requirementValue).clamp(0.0, 1.0) : 0.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEarned 
            ? AppColors.accentGreen.withOpacity(0.1)
            : AppColors.lightGray.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: isEarned 
            ? Border.all(color: AppColors.accentGreen.withOpacity(0.3))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isEarned 
                      ? AppColors.accentGreen.withOpacity(0.2)
                      : AppColors.lightGray.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    achievement['icon'] ?? '🏆',
                    style: TextStyle(
                      fontSize: 20,
                      color: isEarned ? null : AppColors.textSecondary,
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
                      achievement['title'] ?? 'Achievement',
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isEarned ? AppColors.textPrimary : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      achievement['description'] ?? '',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isEarned)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: AppColors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
          
          // Progress bar for unearned achievements
          if (!isEarned && progressPercentage > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progressPercentage,
                    backgroundColor: AppColors.lightGray.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$currentProgress/$requirementValue',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
          
          // Show earned date
          if (isEarned && achievement['earned_at'] != null) ...[
            const SizedBox(height: 8),
            Text(
              'Earned ${AchievementsService.formatTimeAgo(DateTime.parse(achievement['earned_at']))}',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.accentGreen,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActivitySection(List<Map<String, dynamic>> activity) {
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
          Text(
            'Recent Activity',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          if (activity.isEmpty)
            _buildEmptyActivity()
          else
            ...activity.take(6).map((activityItem) => _buildActivityItem(activityItem)),
            
          if (activity.length > 6) ...[
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () {
                  // TODO: Navigate to full activity screen
                },
                child: const Text('View all activity'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyActivity() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.timeline_outlined,
            size: 48,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No recent activity',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your activity will appear here as you use the app',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activityItem) {
    final iconColor = _parseColor(activityItem['color'] ?? '#3B82F6');
    final createdAt = DateTime.parse(activityItem['created_at']);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                activityItem['icon'] ?? '📝',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activityItem['title'] ?? 'Activity',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (activityItem['description'] != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    activityItem['description'],
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  AchievementsService.formatTimeAgo(createdAt),
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

  // Helper method to parse color strings
  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppColors.primaryBlue;
    }
  }

  Widget _buildSettingsSection() {
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
          Text(
            'Settings',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildSettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage your notification preferences',
            onTap: _openNotificationSettings,
          ),
          
          _buildSettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy',
            subtitle: 'Control your privacy settings',
            onTap: _openPrivacySettings,
          ),
          
          _buildSettingsTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            onTap: _openHelpAndSupport,
          ),
          
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'App version and information',
            onTap: _openAbout,
          ),
          
          const SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _logout,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: AppColors.textSecondary,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }

  Widget _buildEmptyProfile() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.lightGray.withOpacity(0.3),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.person_outline,
              size: 60,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Profile not found',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again or contact support',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => ref.read(profileProvider.notifier).refresh(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    List<String> nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  void _editProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: const Text('Profile editing functionality coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSettingsMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share, color: AppColors.primaryBlue),
              title: const Text('Share Profile'),
              onTap: () {
                Navigator.pop(context);
                _shareProfile();
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code, color: AppColors.sageGreen),
              title: const Text('QR Code'),
              onTap: () {
                Navigator.pop(context);
                _showQRCode();
              },
            ),
            ListTile(
              leading: const Icon(Icons.backup, color: AppColors.accentOrange),
              title: const Text('Backup Data'),
              onTap: () {
                Navigator.pop(context);
                _backupData();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _shareProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile sharing coming soon!'),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  void _showQRCode() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('QR code generation coming soon!'),
        backgroundColor: AppColors.sageGreen,
      ),
    );
  }

  void _backupData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data backup functionality coming soon!'),
        backgroundColor: AppColors.accentOrange,
      ),
    );
  }

  void _openNotificationSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification settings coming soon!'),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  void _openPrivacySettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Privacy settings coming soon!'),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  void _openHelpAndSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Help & support coming soon!'),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  void _openAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About CommitBuddy'),
        content: const Text('Version 1.0.0\n\nBuilding better habits through accountability.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  double _calculateSuccessRate(Map<String, dynamic>? stats) {
    if (stats == null) return 0.0;
    final completedSessions = stats['completed_sessions'] ?? 0;
    final totalRoutines = stats['total_routines'] ?? 0;
    if (totalRoutines == 0) return 0.0;
    return (completedSessions / (totalRoutines * 30)) * 100;
  }
} 