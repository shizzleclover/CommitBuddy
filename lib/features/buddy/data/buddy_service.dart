import '../../../data/models/buddy.dart';

class BuddyService {
  static final BuddyService _instance = BuddyService._internal();
  factory BuddyService() => _instance;
  BuddyService._internal();

  // Mock data for demonstration
  final List<Buddy> _buddies = [
    Buddy(
      id: '1',
      username: 'sarah_fitness',
      displayName: 'Sarah Johnson',
      email: 'sarah@example.com',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      status: BuddyStatus.accepted,
      accountabilityScore: 85,
      currentStreak: 12,
      longestStreak: 28,
    ),
    Buddy(
      id: '2',
      username: 'mike_morning',
      displayName: 'Mike Chen',
      email: 'mike@example.com',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      status: BuddyStatus.accepted,
      accountabilityScore: 72,
      currentStreak: 5,
      longestStreak: 15,
    ),
    Buddy(
      id: '3',
      username: 'alex_wellness',
      displayName: 'Alex Rivera',
      email: 'alex@example.com',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      status: BuddyStatus.accepted,
      accountabilityScore: 91,
      currentStreak: 7,
      longestStreak: 7,
    ),
  ];

  final List<BuddyInvitation> _invitations = [
    BuddyInvitation(
      id: '1',
      fromUserId: '4',
      toUserId: 'current_user',
      fromUsername: 'jenny_yoga',
      fromDisplayName: 'Jenny Williams',
      message: 'Hey! Let\'s keep each other accountable! 💪',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      status: InvitationStatus.pending,
    ),
    BuddyInvitation(
      id: '2',
      fromUserId: '5',
      toUserId: 'current_user',
      fromUsername: 'david_run',
      fromDisplayName: 'David Park',
      message: 'Saw your running routine - want to be accountability buddies?',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      status: InvitationStatus.pending,
    ),
  ];

  final List<ProofSubmission> _proofSubmissions = [
    ProofSubmission(
      id: '1',
      userId: '1',
      routineId: 'skincare-1',
      subtaskId: '4',
      routineName: 'Skincare Routine',
      subtaskName: 'Apply sunscreen',
      imageUrl: 'mock_image_1',
      notes: 'SPF 50 applied! Ready for the day ☀️',
      submittedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      reactions: [
        ProofReaction(
          id: '1',
          userId: '2',
          username: 'mike_morning',
          type: ReactionType.approve,
          createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
        ),
        ProofReaction(
          id: '2',
          userId: '3',
          username: 'alex_wellness',
          type: ReactionType.fire,
          createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
        ),
      ],
      comments: [
        ProofComment(
          id: '1',
          userId: '2',
          username: 'mike_morning',
          content: 'Great consistency! Keep it up! 🌟',
          createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
      ],
      status: ProofStatus.approved,
    ),
    ProofSubmission(
      id: '2',
      userId: '2',
      routineId: 'workout-1',
      subtaskId: '3',
      routineName: 'Morning Workout',
      subtaskName: 'Post-workout selfie',
      imageUrl: 'mock_image_2',
      notes: '30 minutes done! Feeling energized 💪',
      submittedAt: DateTime.now().subtract(const Duration(hours: 1)),
      reactions: [
        ProofReaction(
          id: '3',
          userId: '1',
          username: 'sarah_fitness',
          type: ReactionType.fire,
          createdAt: DateTime.now().subtract(const Duration(minutes: 50)),
        ),
        ProofReaction(
          id: '4',
          userId: '3',
          username: 'alex_wellness',
          type: ReactionType.approve,
          createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        ),
      ],
      status: ProofStatus.approved,
    ),
    ProofSubmission(
      id: '3',
      userId: '3',
      routineId: 'meditation-1',
      subtaskId: '2',
      routineName: 'Meditation',
      subtaskName: 'Meditation space setup',
      imageUrl: 'mock_image_3',
      notes: '10 minutes of mindfulness complete 🧘‍♀️',
      submittedAt: DateTime.now().subtract(const Duration(hours: 3)),
      reactions: [
        ProofReaction(
          id: '5',
          userId: '1',
          username: 'sarah_fitness',
          type: ReactionType.approve,
          createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
        ),
      ],
      status: ProofStatus.pending,
    ),
  ];

  // Get all buddies
  Future<List<Buddy>> getBuddies() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    return List.from(_buddies);
  }

  // Get pending invitations
  Future<List<BuddyInvitation>> getPendingInvitations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _invitations.where((inv) => inv.status == InvitationStatus.pending).toList();
  }

  // Send buddy invitation
  Future<bool> sendInvitation({
    required String toUsername,
    String? message,
  }) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network request
    
    // Mock validation
    if (toUsername.isEmpty || toUsername.length < 3) {
      throw Exception('Username must be at least 3 characters');
    }
    
    // Check if user exists (mock)
    if (toUsername.contains('notfound')) {
      throw Exception('User not found');
    }
    
    // Check if already buddies (mock)
    if (_buddies.any((buddy) => buddy.username == toUsername)) {
      throw Exception('Already buddies with this user');
    }
    
    return true; // Success
  }

  // Accept invitation
  Future<bool> acceptInvitation(String invitationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final invIndex = _invitations.indexWhere((inv) => inv.id == invitationId);
    if (invIndex != -1) {
      // Update invitation status
      _invitations[invIndex] = _invitations[invIndex].copyWith(
        status: InvitationStatus.accepted,
        respondedAt: DateTime.now(),
      );
      
      // Add as buddy
      final invitation = _invitations[invIndex];
      _buddies.add(Buddy(
        id: invitation.fromUserId,
        username: invitation.fromUsername,
        displayName: invitation.fromDisplayName,
        email: '${invitation.fromUsername}@example.com',
        profileImageUrl: invitation.fromProfileImageUrl,
        createdAt: DateTime.now(),
        status: BuddyStatus.accepted,
        accountabilityScore: 75,
        currentStreak: 0,
        longestStreak: 0,
      ));
      
      return true;
    }
    return false;
  }

  // Decline invitation
  Future<bool> declineInvitation(String invitationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final invIndex = _invitations.indexWhere((inv) => inv.id == invitationId);
    if (invIndex != -1) {
      _invitations[invIndex] = _invitations[invIndex].copyWith(
        status: InvitationStatus.declined,
        respondedAt: DateTime.now(),
      );
      return true;
    }
    return false;
  }

  // Get proof submissions for review
  Future<List<ProofSubmission>> getProofSubmissionsForReview() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_proofSubmissions);
  }

  // React to proof submission
  Future<bool> reactToProof({
    required String submissionId,
    required ReactionType reactionType,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final submissionIndex = _proofSubmissions.indexWhere((sub) => sub.id == submissionId);
    if (submissionIndex != -1) {
      final submission = _proofSubmissions[submissionIndex];
      
      // Remove existing reaction from current user if any
      final updatedReactions = submission.reactions
          .where((r) => r.userId != 'current_user')
          .toList();
      
      // Add new reaction
      updatedReactions.add(ProofReaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user',
        username: 'current_user',
        type: reactionType,
        createdAt: DateTime.now(),
      ));
      
      _proofSubmissions[submissionIndex] = submission.copyWith(
        reactions: updatedReactions,
      );
      
      return true;
    }
    return false;
  }

  // Add comment to proof
  Future<bool> commentOnProof({
    required String submissionId,
    required String comment,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final submissionIndex = _proofSubmissions.indexWhere((sub) => sub.id == submissionId);
    if (submissionIndex != -1) {
      final submission = _proofSubmissions[submissionIndex];
      
      final newComment = ProofComment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user',
        username: 'current_user',
        content: comment,
        createdAt: DateTime.now(),
      );
      
      _proofSubmissions[submissionIndex] = submission.copyWith(
        comments: [...submission.comments, newComment],
      );
      
      return true;
    }
    return false;
  }

  // Get buddy stats
  Future<BuddyStats> getBuddyStats(String buddyId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Mock stats calculation
    final buddy = _buddies.firstWhere((b) => b.id == buddyId);
    return BuddyStats(
      totalBuddies: _buddies.length,
      activeStreaks: _buddies.where((b) => b.currentStreak > 0).length,
      proofsGivenThisWeek: 15,
      proofsReceivedThisWeek: 12,
      averageAccountabilityScore: buddy.accountabilityScore.toDouble(),
      longestCombinedStreak: buddy.longestStreak,
      reviewsGiven: 15,
      reviewsReceived: 12,
      approvalRate: 0.85,
      lastActiveAt: DateTime.now().subtract(const Duration(hours: 2)),
    );
  }

  // Search users for invitations
  Future<List<Map<String, String>>> searchUsers(String query) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    // Mock search results
    if (query.length < 2) return [];
    
    final mockUsers = [
      {'username': 'jenny_yoga', 'displayName': 'Jenny Williams'},
      {'username': 'david_run', 'displayName': 'David Park'},
      {'username': 'lisa_meditate', 'displayName': 'Lisa Zhang'},
      {'username': 'tom_fitness', 'displayName': 'Tom Anderson'},
      {'username': 'emma_wellness', 'displayName': 'Emma Davis'},
    ];
    
    return mockUsers
        .where((user) => 
            user['username']!.toLowerCase().contains(query.toLowerCase()) ||
            user['displayName']!.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
} 