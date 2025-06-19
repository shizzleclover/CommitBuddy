import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../data/models/buddy.dart';
import '../logic/buddy_providers.dart';
import 'invite_buddy_screen.dart';
import 'proof_review_screen.dart';
import 'buddy_profile_screen.dart';
import 'streak_analytics_screen.dart';
import '../../profile/presentation/profile_screen.dart';

class BuddyScreen extends ConsumerStatefulWidget {
  const BuddyScreen({super.key});

  @override
  ConsumerState<BuddyScreen> createState() => _BuddyScreenState();
}

class _BuddyScreenState extends ConsumerState<BuddyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Load buddy data on screen init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(buddyProvider.notifier).loadBuddies();
      ref.read(buddyProvider.notifier).loadInvitations();
      ref.read(buddyProvider.notifier).loadProofSubmissions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buddyState = ref.watch(buddyProvider);
    final isLoading = ref.watch(buddyLoadingProvider);

    // Listen for errors
    ref.listen(buddyProvider, (previous, next) {
      if (next.error != null) {
        _showErrorSnackBar(next.error!);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Accountability Buddies',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _navigateToInviteBuddy,
            icon: const Icon(
              Icons.person_add,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primaryBlue,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Buddies'),
                  if (buddyState.buddies.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${buddyState.buddies.length}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Invites'),
                  if (buddyState.invitations.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accentOrange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${buddyState.invitations.length}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Reviews'),
                  if (buddyState.proofSubmissions.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accentGreen,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${buddyState.proofSubmissions.length}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const LoadingWidget(message: 'Loading buddy data...')
          : RefreshIndicator(
              onRefresh: () async {
                await ref.read(buddyProvider.notifier).refreshAll();
              },
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBuddiesTab(buddyState.buddies),
                  _buildInvitationsTab(buddyState.invitations),
                  _buildReviewsTab(buddyState.proofSubmissions),
                ],
              ),
            ),
      floatingActionButton: Stack(
        children: [
          // Background overlay when menu is open
          if (_isMenuOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleMenu,
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            ),
          
          // Menu options
          if (_isMenuOpen) ...[
            Positioned(
              bottom: 80,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildMenuOption(
                    icon: Icons.person,
                    label: 'Profile',
                    color: AppColors.sageGreen,
                    onTap: _navigateToProfile,
                  ),
                  const SizedBox(height: 12),
                  _buildMenuOption(
                    icon: Icons.analytics_outlined,
                    label: 'Analytics',
                    color: AppColors.primaryBlue,
                    onTap: _navigateToAnalytics,
                  ),
                ],
              ),
            ),
          ],
          
          // Main FAB
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              heroTag: "main_fab",
              onPressed: _toggleMenu,
              backgroundColor: _isMenuOpen ? AppColors.error : AppColors.primaryBlue,
              foregroundColor: AppColors.white,
              child: AnimatedRotation(
                turns: _isMenuOpen ? 0.125 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(_isMenuOpen ? Icons.close : Icons.menu),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuddiesTab(List<Buddy> buddies) {
    if (buddies.isEmpty) {
      return _buildEmptyBuddiesState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: buddies.length,
      itemBuilder: (context, index) {
        final buddy = buddies[index];
        return _buildBuddyCard(buddy);
      },
    );
  }

  Widget _buildInvitationsTab(List<BuddyInvitation> invitations) {
    if (invitations.isEmpty) {
      return _buildEmptyInvitationsState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: invitations.length,
      itemBuilder: (context, index) {
        final invitation = invitations[index];
        return _buildInvitationCard(invitation);
      },
    );
  }

  Widget _buildReviewsTab(List<ProofSubmission> submissions) {
    if (submissions.isEmpty) {
      return _buildEmptyReviewsState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: submissions.length,
      itemBuilder: (context, index) {
        final submission = submissions[index];
        return _buildProofSubmissionCard(submission);
      },
    );
  }

  Widget _buildEmptyBuddiesState() {
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
              Icons.people_outline,
              size: 60,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No buddies yet',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Invite friends to be your accountability buddies',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 160,
            height: 44,
            child: ElevatedButton(
              onPressed: _navigateToInviteBuddy,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.white,
                elevation: 2,
                shadowColor: AppColors.primaryBlue.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                'Invite Buddy',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyInvitationsState() {
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
              Icons.mail_outline,
              size: 60,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No pending invitations',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ll see buddy invitations here',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyReviewsState() {
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
              Icons.verified_outlined,
              size: 60,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No proofs to review',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your buddies\' proof submissions will appear here',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuddyCard(Buddy buddy) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.lightGray.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
            backgroundImage: buddy.avatarUrl != null 
                ? NetworkImage(buddy.avatarUrl!) 
                : null,
            child: buddy.avatarUrl == null 
                ? Text(
                    buddy.initials,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  buddy.displayName,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '@${buddy.username}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${buddy.accountabilityScore}%',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.accentGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Score',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationCard(BuddyInvitation invitation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.lightGray.withOpacity(0.3),
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
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                backgroundImage: invitation.senderAvatarUrl != null 
                    ? NetworkImage(invitation.senderAvatarUrl!) 
                    : null,
                child: invitation.senderAvatarUrl == null 
                    ? Text(
                        invitation.senderDisplayName.substring(0, 1).toUpperCase(),
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invitation.senderDisplayName,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'wants to be your buddy',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (invitation.message != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundGray,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                invitation.message!,
                style: AppTextStyles.bodyMedium,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _declineInvitation(invitation),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error),
                  ),
                  child: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _acceptInvitation(invitation),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    foregroundColor: AppColors.white,
                  ),
                  child: const Text('Accept'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProofSubmissionCard(ProofSubmission submission) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.lightGray.withOpacity(0.3),
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
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                backgroundImage: submission.userAvatarUrl != null 
                    ? NetworkImage(submission.userAvatarUrl!) 
                    : null,
                child: submission.userAvatarUrl == null 
                    ? Text(
                        submission.userName.substring(0, 1).toUpperCase(),
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      submission.userName,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      submission.routineName,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(submission.status.toString().split('.').last).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  submission.status.toString().split('.').last.toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: _getStatusColor(submission.status.toString().split('.').last),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (submission.notes != null) ...[
            const SizedBox(height: 12),
            Text(
              submission.notes!,
              style: AppTextStyles.bodyMedium,
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _reviewProof(submission),
                  child: const Text('Review'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.accentOrange;
      case 'approved':
        return AppColors.accentGreen;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.accentGreen,
      ),
    );
  }

  void _navigateToInviteBuddy() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const InviteBuddyScreen(),
      ),
    ).then((_) {
      // Refresh data when returning from invite screen
      ref.read(buddyProvider.notifier).loadInvitations();
    });
  }

  void _navigateToAnalytics() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const StreakAnalyticsScreen(),
      ),
    );
  }

  void _navigateToProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      ),
    );
  }

  Future<void> _acceptInvitation(BuddyInvitation invitation) async {
    try {
      await ref.read(buddyProvider.notifier).acceptInvitation(invitation.id);
      _showSuccessSnackBar('Buddy invitation accepted!');
    } catch (e) {
      _showErrorSnackBar('Failed to accept invitation');
    }
  }

  Future<void> _declineInvitation(BuddyInvitation invitation) async {
    try {
      await ref.read(buddyProvider.notifier).declineInvitation(invitation.id);
      _showSuccessSnackBar('Invitation declined');
    } catch (e) {
      _showErrorSnackBar('Failed to decline invitation');
    }
  }

  void _reviewProof(ProofSubmission submission) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProofReviewScreen(
          proofSubmissions: [submission],
          onReaction: (submissionId, reaction) {
            // Handle reaction
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Reaction: $reaction')),
            );
          },
          onComment: (submissionId, comment) {
            // Handle comment
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Comment added: $comment')),
            );
          },
          onRefresh: () {
            ref.read(buddyProvider.notifier).loadProofSubmissions();
          },
        ),
      ),
    ).then((_) {
      // Refresh proof submissions when returning from review screen
      ref.read(buddyProvider.notifier).loadProofSubmissions();
    });
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        _toggleMenu();
        onTap();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton.small(
            onPressed: null,
            backgroundColor: color,
            foregroundColor: AppColors.white,
            heroTag: label,
            child: Icon(icon),
          ),
        ],
      ),
    );
  }
} 