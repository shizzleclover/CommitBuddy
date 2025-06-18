import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/buddy.dart';

class ProofReviewScreen extends StatefulWidget {
  final List<ProofSubmission> proofSubmissions;
  final Function(String, ReactionType) onReaction;
  final Function(String, String) onComment;
  final VoidCallback onRefresh;

  const ProofReviewScreen({
    super.key,
    required this.proofSubmissions,
    required this.onReaction,
    required this.onComment,
    required this.onRefresh,
  });

  @override
  State<ProofReviewScreen> createState() => _ProofReviewScreenState();
}

class _ProofReviewScreenState extends State<ProofReviewScreen> {
  final TextEditingController _commentController = TextEditingController();
  String? _activeCommentSubmissionId;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.proofSubmissions.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async => widget.onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.proofSubmissions.length,
        itemBuilder: (context, index) {
          final submission = widget.proofSubmissions[index];
          return _buildProofCard(submission);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
                Icons.photo_camera_outlined,
                size: 60,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Proof to Review',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your buddies haven\'t submitted any proof yet. Encourage them to stay consistent!',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProofCard(ProofSubmission submission) {
    final isCommentActive = _activeCommentSubmissionId == submission.id;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
          // Header
          _buildProofHeader(submission),
          
          // Image
          _buildProofImage(submission),
          
          // Notes
          if (submission.notes != null) _buildProofNotes(submission),
          
          // Reactions
          _buildReactionBar(submission),
          
          // Comments Section
          if (submission.comments.isNotEmpty) _buildCommentsSection(submission),
          
          // Comment Input
          if (isCommentActive) _buildCommentInput(submission),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProofHeader(ProofSubmission submission) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // User Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.person,
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
                  'User submitted proof',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${submission.routineName} • ${submission.subtaskName}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTime(submission.submittedAt),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(submission.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getStatusText(submission.status),
              style: AppTextStyles.labelSmall.copyWith(
                color: _getStatusColor(submission.status),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProofImage(ProofSubmission submission) {
    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.lightGray.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_camera,
            size: 48,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'Proof Image',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            '(Mock - Real camera integration pending)',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProofNotes(ProofSubmission submission) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.backgroundGray,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          submission.notes!,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildReactionBar(ProofSubmission submission) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Reaction Stats
          if (submission.reactions.isNotEmpty) ...[
            Row(
              children: [
                if (submission.approvalCount > 0) ...[
                  _buildReactionCount('✅', submission.approvalCount),
                  const SizedBox(width: 8),
                ],
                if (submission.rejectCount > 0) ...[
                  _buildReactionCount('❌', submission.rejectCount),
                  const SizedBox(width: 8),
                ],
                if (submission.fireCount > 0) ...[
                  _buildReactionCount('🔥', submission.fireCount),
                  const SizedBox(width: 8),
                ],
                const Spacer(),
                if (submission.comments.isNotEmpty)
                  Text(
                    '${submission.comments.length} comments',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          
          // Reaction Buttons
          Row(
            children: [
              Expanded(
                child: _buildReactionButton(
                  icon: '✅',
                  label: 'Approve',
                  onPressed: () => widget.onReaction(submission.id, ReactionType.approve),
                  isSelected: _hasUserReacted(submission, ReactionType.approve),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildReactionButton(
                  icon: '❌',
                  label: 'Reject',
                  onPressed: () => widget.onReaction(submission.id, ReactionType.reject),
                  isSelected: _hasUserReacted(submission, ReactionType.reject),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildReactionButton(
                  icon: '🔥',
                  label: 'Fire',
                  onPressed: () => widget.onReaction(submission.id, ReactionType.fire),
                  isSelected: _hasUserReacted(submission, ReactionType.fire),
                ),
              ),
              const SizedBox(width: 8),
              _buildCommentButton(submission),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReactionCount(String emoji, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.lightGray.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            count.toString(),
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionButton({
    required String icon,
    required String label,
    required VoidCallback onPressed,
    required bool isSelected,
  }) {
    return Material(
      color: isSelected 
          ? AppColors.primaryBlue.withOpacity(0.1)
          : AppColors.lightGray.withOpacity(0.3),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentButton(ProofSubmission submission) {
    final isActive = _activeCommentSubmissionId == submission.id;
    
    return Material(
      color: isActive 
          ? AppColors.primaryBlue.withOpacity(0.1)
          : AppColors.lightGray.withOpacity(0.3),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () => _toggleCommentInput(submission.id),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(
            Icons.chat_bubble_outline,
            color: isActive ? AppColors.primaryBlue : AppColors.textSecondary,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildCommentsSection(ProofSubmission submission) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comments',
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ...submission.comments.map((comment) => _buildCommentTile(comment)),
        ],
      ),
    );
  }

  Widget _buildCommentTile(ProofComment comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.lightGray.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.person,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '@${comment.username}',
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(comment.createdAt),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  comment.content,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(ProofSubmission submission) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.7),
                ),
                filled: true,
                fillColor: AppColors.backgroundGray,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () => _submitComment(submission.id),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.send,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasUserReacted(ProofSubmission submission, ReactionType type) {
    return submission.reactions.any(
      (reaction) => reaction.userId == 'current_user' && reaction.type == type,
    );
  }

  Color _getStatusColor(ProofStatus status) {
    switch (status) {
      case ProofStatus.pending:
        return AppColors.accentOrange;
      case ProofStatus.approved:
        return AppColors.accentGreen;
      case ProofStatus.rejected:
        return AppColors.error;
      case ProofStatus.disputed:
        return AppColors.primaryBlue;
      case ProofStatus.flagged:
        return AppColors.error;
    }
  }

  String _getStatusText(ProofStatus status) {
    switch (status) {
      case ProofStatus.pending:
        return 'Pending';
      case ProofStatus.approved:
        return 'Approved';
      case ProofStatus.rejected:
        return 'Rejected';
      case ProofStatus.disputed:
        return 'Disputed';
      case ProofStatus.flagged:
        return 'Flagged';
    }
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

  void _toggleCommentInput(String submissionId) {
    setState(() {
      if (_activeCommentSubmissionId == submissionId) {
        _activeCommentSubmissionId = null;
        _commentController.clear();
      } else {
        _activeCommentSubmissionId = submissionId;
      }
    });
  }

  void _submitComment(String submissionId) {
    final comment = _commentController.text.trim();
    if (comment.isNotEmpty) {
      widget.onComment(submissionId, comment);
      _commentController.clear();
      setState(() {
        _activeCommentSubmissionId = null;
      });
    }
  }
} 