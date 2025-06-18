enum BuddyStatus {
  pending,
  accepted,
  declined,
  blocked,
  inactive,
}

enum InvitationStatus {
  pending,
  accepted,
  declined,
  expired,
}

enum ReactionType {
  approve,
  reject,
  fire,
  comment,
}

enum ProofStatus {
  pending,
  approved,
  rejected,
  flagged,
  disputed;

  @override
  String toString() {
    switch (this) {
      case ProofStatus.pending:
        return 'pending';
      case ProofStatus.approved:
        return 'approved';
      case ProofStatus.rejected:
        return 'rejected';
      case ProofStatus.flagged:
        return 'flagged';
      case ProofStatus.disputed:
        return 'disputed';
    }
  }

  String toUpperCase() {
    return toString().toUpperCase();
  }
}

class Buddy {
  final String id;
  final String username;
  final String displayName;
  final String email;
  final String? bio;
  final String? profileImageUrl;
  final DateTime createdAt;
  final BuddyStatus status;
  final int accountabilityScore;
  final int currentStreak;
  final int longestStreak;
  final int totalProofsGiven;
  final int totalProofsReceived;
  final DateTime? lastActiveAt;

  const Buddy({
    required this.id,
    required this.username,
    required this.displayName,
    required this.email,
    this.bio,
    this.profileImageUrl,
    required this.createdAt,
    required this.status,
    required this.accountabilityScore,
    required this.currentStreak,
    required this.longestStreak,
    this.totalProofsGiven = 0,
    this.totalProofsReceived = 0,
    this.lastActiveAt,
  });

  // Helper getters
  String get initials {
    List<String> nameParts = displayName.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';
  }

  String? get avatarUrl => profileImageUrl;

  Buddy copyWith({
    String? id,
    String? username,
    String? displayName,
    String? email,
    String? bio,
    String? profileImageUrl,
    DateTime? createdAt,
    BuddyStatus? status,
    int? accountabilityScore,
    int? currentStreak,
    int? longestStreak,
    int? totalProofsGiven,
    int? totalProofsReceived,
    DateTime? lastActiveAt,
  }) {
    return Buddy(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      accountabilityScore: accountabilityScore ?? this.accountabilityScore,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalProofsGiven: totalProofsGiven ?? this.totalProofsGiven,
      totalProofsReceived: totalProofsReceived ?? this.totalProofsReceived,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }
}

class BuddyInvitation {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String fromUsername;
  final String fromDisplayName;
  final String? fromProfileImageUrl;
  final String message;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final InvitationStatus status;

  const BuddyInvitation({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.fromUsername,
    required this.fromDisplayName,
    this.fromProfileImageUrl,
    required this.message,
    required this.createdAt,
    this.respondedAt,
    required this.status,
  });

  // Helper getters
  String? get senderAvatarUrl => fromProfileImageUrl;
  String get senderDisplayName => fromDisplayName;

  BuddyInvitation copyWith({
    String? id,
    String? fromUserId,
    String? toUserId,
    String? fromUsername,
    String? fromDisplayName,
    String? fromProfileImageUrl,
    String? message,
    DateTime? createdAt,
    DateTime? respondedAt,
    InvitationStatus? status,
  }) {
    return BuddyInvitation(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      fromUsername: fromUsername ?? this.fromUsername,
      fromDisplayName: fromDisplayName ?? this.fromDisplayName,
      fromProfileImageUrl: fromProfileImageUrl ?? this.fromProfileImageUrl,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
      status: status ?? this.status,
    );
  }
}

class ProofReaction {
  final String id;
  final String userId;
  final String username;
  final ReactionType type;
  final DateTime createdAt;

  const ProofReaction({
    required this.id,
    required this.userId,
    required this.username,
    required this.type,
    required this.createdAt,
  });

  ProofReaction copyWith({
    String? id,
    String? userId,
    String? username,
    ReactionType? type,
    DateTime? createdAt,
  }) {
    return ProofReaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ProofComment {
  final String id;
  final String userId;
  final String username;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ProofComment({
    required this.id,
    required this.userId,
    required this.username,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  ProofComment copyWith({
    String? id,
    String? userId,
    String? username,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProofComment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ProofSubmission {
  final String id;
  final String userId;
  final String routineId;
  final String subtaskId;
  final String routineName;
  final String subtaskName;
  final String imageUrl;
  final String? notes;
  final DateTime submittedAt;
  final List<ProofReaction> reactions;
  final List<ProofComment> comments;
  final ProofStatus status;
  final String? reviewedBy;
  final DateTime? reviewedAt;

  const ProofSubmission({
    required this.id,
    required this.userId,
    required this.routineId,
    required this.subtaskId,
    required this.routineName,
    required this.subtaskName,
    required this.imageUrl,
    this.notes,
    required this.submittedAt,
    this.reactions = const [],
    this.comments = const [],
    required this.status,
    this.reviewedBy,
    this.reviewedAt,
  });

  // Helper getters for reaction counts
  int get approvalCount => reactions.where((r) => r.type == ReactionType.approve).length;
  int get rejectCount => reactions.where((r) => r.type == ReactionType.reject).length;
  int get fireCount => reactions.where((r) => r.type == ReactionType.fire).length;

  // Helper getters for screen compatibility
  String? get userAvatarUrl => null; // Will be populated from user profile when needed
  String get userName => 'User'; // Will be populated from user profile when needed

  ProofSubmission copyWith({
    String? id,
    String? userId,
    String? routineId,
    String? subtaskId,
    String? routineName,
    String? subtaskName,
    String? imageUrl,
    String? notes,
    DateTime? submittedAt,
    List<ProofReaction>? reactions,
    List<ProofComment>? comments,
    ProofStatus? status,
    String? reviewedBy,
    DateTime? reviewedAt,
  }) {
    return ProofSubmission(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      routineId: routineId ?? this.routineId,
      subtaskId: subtaskId ?? this.subtaskId,
      routineName: routineName ?? this.routineName,
      subtaskName: subtaskName ?? this.subtaskName,
      imageUrl: imageUrl ?? this.imageUrl,
      notes: notes ?? this.notes,
      submittedAt: submittedAt ?? this.submittedAt,
      reactions: reactions ?? this.reactions,
      comments: comments ?? this.comments,
      status: status ?? this.status,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }
}

class BuddyStats {
  final int totalBuddies;
  final int activeStreaks;
  final int proofsGivenThisWeek;
  final int proofsReceivedThisWeek;
  final double averageAccountabilityScore;
  final int longestCombinedStreak;
  final DateTime? lastProofActivity;
  final int reviewsGiven;
  final int reviewsReceived;
  final double approvalRate;
  final DateTime? lastActiveAt;

  const BuddyStats({
    required this.totalBuddies,
    required this.activeStreaks,
    required this.proofsGivenThisWeek,
    required this.proofsReceivedThisWeek,
    required this.averageAccountabilityScore,
    required this.longestCombinedStreak,
    this.lastProofActivity,
    this.reviewsGiven = 0,
    this.reviewsReceived = 0,
    this.approvalRate = 0.0,
    this.lastActiveAt,
  });

  // Helper getters
  double get accountabilityScore => averageAccountabilityScore;
  
  String get accountabilityLevel {
    if (accountabilityScore >= 90) return 'Elite Buddy';
    if (accountabilityScore >= 80) return 'Great Buddy';
    if (accountabilityScore >= 70) return 'Good Buddy';
    if (accountabilityScore >= 50) return 'New Buddy';
    return 'Learning Buddy';
  }

  BuddyStats copyWith({
    int? totalBuddies,
    int? activeStreaks,
    int? proofsGivenThisWeek,
    int? proofsReceivedThisWeek,
    double? averageAccountabilityScore,
    int? longestCombinedStreak,
    DateTime? lastProofActivity,
    int? reviewsGiven,
    int? reviewsReceived,
    double? approvalRate,
    DateTime? lastActiveAt,
  }) {
    return BuddyStats(
      totalBuddies: totalBuddies ?? this.totalBuddies,
      activeStreaks: activeStreaks ?? this.activeStreaks,
      proofsGivenThisWeek: proofsGivenThisWeek ?? this.proofsGivenThisWeek,
      proofsReceivedThisWeek: proofsReceivedThisWeek ?? this.proofsReceivedThisWeek,
      averageAccountabilityScore: averageAccountabilityScore ?? this.averageAccountabilityScore,
      longestCombinedStreak: longestCombinedStreak ?? this.longestCombinedStreak,
      lastProofActivity: lastProofActivity ?? this.lastProofActivity,
      reviewsGiven: reviewsGiven ?? this.reviewsGiven,
      reviewsReceived: reviewsReceived ?? this.reviewsReceived,
      approvalRate: approvalRate ?? this.approvalRate,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }
}

class BuddySearchResult {
  final String id;
  final String username;
  final String displayName;
  final String? profileImageUrl;
  final String? bio;
  final int accountabilityScore;
  final bool isAlreadyBuddy;
  final bool hasInvitationPending;

  const BuddySearchResult({
    required this.id,
    required this.username,
    required this.displayName,
    this.profileImageUrl,
    this.bio,
    required this.accountabilityScore,
    required this.isAlreadyBuddy,
    required this.hasInvitationPending,
  });

  BuddySearchResult copyWith({
    String? id,
    String? username,
    String? displayName,
    String? profileImageUrl,
    String? bio,
    int? accountabilityScore,
    bool? isAlreadyBuddy,
    bool? hasInvitationPending,
  }) {
    return BuddySearchResult(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      accountabilityScore: accountabilityScore ?? this.accountabilityScore,
      isAlreadyBuddy: isAlreadyBuddy ?? this.isAlreadyBuddy,
      hasInvitationPending: hasInvitationPending ?? this.hasInvitationPending,
    );
  }
} 