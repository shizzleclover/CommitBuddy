import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/buddy.dart';
import 'cache_service.dart';

class BuddyService {
  static final _supabase = Supabase.instance.client;
  static const _uuid = Uuid();

  // Get all user buddies
  static Future<List<Buddy>> getBuddies({bool fromCache = true}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      print('👥 Fetching buddies for user: ${user.id}');

      // Try cache first
      if (fromCache) {
        final cachedBuddies = CacheService.getBuddies();
        if (cachedBuddies.isNotEmpty) {
          print('✅ Found ${cachedBuddies.length} cached buddies');
          return cachedBuddies.map((data) => _mapToBuddy(data)).toList();
        }
      }

      // Fetch from Supabase with fallback for relationship issues
      List<dynamic> response;
      try {
        response = await _supabase
            .from('buddies')
            .select('''
              id,
              created_at,
              user_profiles:buddy_id(
                id,
                username,
                display_name,
                email,
                bio,
                profile_image_url
              )
            ''')
            .eq('user_id', user.id)
            .eq('status', 'accepted');
      } catch (e) {
        print('⚠️ Buddy relationship query failed, using simple query: $e');
        // Fallback to basic buddy data without user profiles
        response = await _supabase
            .from('buddies')
            .select('id, created_at, buddy_id')
            .eq('user_id', user.id)
            .eq('status', 'accepted');
        
        // Return empty list if we can't get user profile data
        print('✅ Fetched ${response.length} buddies (without profile data)');
        return [];
      }

      final buddies = response.map((data) => _mapToBuddy(data)).toList();

      // Cache the buddies
      await CacheService.saveBuddies(response.map((e) => Map<String, dynamic>.from(e)).toList());
      
      print('✅ Fetched ${buddies.length} buddies from Supabase');
      return buddies;
    } catch (e) {
      print('❌ Error fetching buddies: $e');
      return [];
    }
  }

  // Get pending invitations
  static Future<List<BuddyInvitation>> getPendingInvitations() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      print('📨 Fetching pending invitations for user: ${user.id}');

      List<dynamic> response;
      try {
        response = await _supabase
            .from('buddy_invitations')
            .select('''
              id,
              message,
              created_at,
              user_profiles:from_user_id(
                id,
                username,
                display_name,
                profile_image_url
              )
            ''')
            .eq('to_user_id', user.id)
            .eq('status', 'pending')
            .order('created_at', ascending: false);
      } catch (e) {
        print('⚠️ Invitation relationship query failed, using simple query: $e');
        // Fallback to basic invitation data without user profiles
        response = await _supabase
            .from('buddy_invitations')
            .select('id, message, created_at, from_user_id')
            .eq('to_user_id', user.id)
            .eq('status', 'pending')
            .order('created_at', ascending: false);
        
        // Return empty list if we can't get user profile data
        print('✅ Fetched ${response.length} invitations (without profile data)');
        return [];
      }

      final invitations = response.map((data) => _mapToBuddyInvitation(data)).toList();
      
      print('✅ Found ${invitations.length} pending invitations');
      return invitations;
    } catch (e) {
      print('❌ Error fetching invitations: $e');
      return [];
    }
  }

  // Send buddy invitation
  static Future<bool> sendInvitation({
    required String toUsername,
    String? message,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      print('📤 Sending invitation to: $toUsername');

      // Validate input
      if (toUsername.isEmpty || toUsername.length < 3) {
        throw Exception('Username must be at least 3 characters');
      }

      // Find the target user
      final targetUser = await _supabase
          .from('user_profiles')
          .select('id')
          .eq('username', toUsername)
          .maybeSingle();

      if (targetUser == null) {
        throw Exception('User not found');
      }

      final targetUserId = targetUser['id'];

      // Check if already buddies
      final existingBuddy = await _supabase
          .from('buddies')
          .select('id')
          .eq('user_id', user.id)
          .eq('buddy_id', targetUserId)
          .maybeSingle();

      if (existingBuddy != null) {
        throw Exception('Already buddies with this user');
      }

      // Check for pending invitation
      final existingInvitation = await _supabase
          .from('buddy_invitations')
          .select('id')
          .eq('from_user_id', user.id)
          .eq('to_user_id', targetUserId)
          .eq('status', 'pending')
          .maybeSingle();

      if (existingInvitation != null) {
        throw Exception('Invitation already sent to this user');
      }

      // Create invitation
      final invitationData = {
        'id': _uuid.v4(),
        'from_user_id': user.id,
        'to_user_id': targetUserId,
        'message': message ?? 'Let\'s be accountability buddies! 💪',
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('buddy_invitations').insert(invitationData);
      
      print('✅ Invitation sent successfully');
      return true;
    } catch (e) {
      print('❌ Error sending invitation: $e');
      rethrow;
    }
  }

  // Accept invitation
  static Future<bool> acceptInvitation(String invitationId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      print('✅ Accepting invitation: $invitationId');

      // Get invitation details
      final invitation = await _supabase
          .from('buddy_invitations')
          .select('from_user_id, to_user_id')
          .eq('id', invitationId)
          .eq('to_user_id', user.id)
          .eq('status', 'pending')
          .single();

      final fromUserId = invitation['from_user_id'];
      final toUserId = invitation['to_user_id'];

      // Update invitation status
      await _supabase
          .from('buddy_invitations')
          .update({
            'status': 'accepted',
            'responded_at': DateTime.now().toIso8601String(),
          })
          .eq('id', invitationId);

      // Create mutual buddy relationships
      final now = DateTime.now().toIso8601String();
      
      await _supabase.from('buddies').insert([
        {
          'id': _uuid.v4(),
          'user_id': fromUserId,
          'buddy_id': toUserId,
          'status': 'accepted',
          'created_at': now,
        },
        {
          'id': _uuid.v4(),
          'user_id': toUserId,
          'buddy_id': fromUserId,
          'status': 'accepted',
          'created_at': now,
        },
      ]);

      // Clear cache
      await _clearBuddyCache();
      
      print('✅ Invitation accepted and buddy relationship created');
      return true;
    } catch (e) {
      print('❌ Error accepting invitation: $e');
      return false;
    }
  }

  // Decline invitation
  static Future<bool> declineInvitation(String invitationId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      print('❌ Declining invitation: $invitationId');

      await _supabase
          .from('buddy_invitations')
          .update({
            'status': 'declined',
            'responded_at': DateTime.now().toIso8601String(),
          })
          .eq('id', invitationId)
          .eq('to_user_id', user.id);
      
      print('✅ Invitation declined');
      return true;
    } catch (e) {
      print('❌ Error declining invitation: $e');
      return false;
    }
  }

  // Get proof submissions for review
  static Future<List<ProofSubmission>> getProofSubmissionsForReview() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      print('📋 Fetching proof submissions for review');

      // Get buddies first to know who to get proofs from
      final buddies = await getBuddies(fromCache: false);
      if (buddies.isEmpty) {
        print('ℹ️ No buddies found, no proofs to review');
        return [];
      }

      final buddyIds = buddies.map((b) => b.id).toList();

      // Get recent routine completions from buddies that require photo proof
      final response = await _supabase
          .from('routine_completions')
          .select('''
            id,
            user_id,
            routine_id,
            completed_at,
            mood_rating,
            satisfaction_rating,
            notes,
            routines!inner(
              name,
              emoji,
              category
            ),
            user_profiles!inner(
              username,
              display_name
            )
          ''')
          .inFilter('user_id', buddyIds)
          .gte('completed_at', DateTime.now().subtract(const Duration(days: 7)).toIso8601String())
          .order('completed_at', ascending: false)
          .limit(50);

      // Map to ProofSubmission objects
      final proofs = response.map((data) => _mapToProofSubmission(data)).toList();
      
      print('✅ Found ${proofs.length} proof submissions for review');
      return proofs;
    } catch (e) {
      print('❌ Error fetching proof submissions: $e');
      return [];
    }
  }

  // Get buddy stats
  static Future<BuddyStats> getBuddyStats(String buddyId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      print('📊 Fetching stats for buddy: $buddyId');

      // Get buddy data
      final buddy = await _supabase
          .from('user_profiles')
          .select('*')
          .eq('id', buddyId)
          .single();

      // Get buddy's routine completion stats
      final completionStats = await _supabase
          .from('routine_completions')
          .select('id')
          .eq('user_id', buddyId)
          .gte('completed_at', DateTime.now().subtract(const Duration(days: 30)).toIso8601String())
          .count();

      // Get current streak by calculating from routine_completions
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      
      // Get recent completions to calculate current streak
      final recentCompletions = await _supabase
          .from('routine_completions')
          .select('completed_at')
          .eq('user_id', buddyId)
          .gte('completed_at', todayStart.subtract(const Duration(days: 30)).toIso8601String())
          .order('completed_at', ascending: false);

      // Calculate current streak
      int currentStreak = 0;
      if (recentCompletions.isNotEmpty) {
        final completionDates = <String>{};
        for (final completion in recentCompletions) {
          final date = DateTime.parse(completion['completed_at']);
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          completionDates.add(dateKey);
        }

        // Count consecutive days from today backwards
        var checkDate = today;
        while (true) {
          final dateKey = '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';
          if (completionDates.contains(dateKey)) {
            currentStreak++;
            checkDate = checkDate.subtract(const Duration(days: 1));
          } else {
            break;
          }
        }
      }

      final stats = BuddyStats(
        totalBuddies: 1,
        activeStreaks: currentStreak > 0 ? 1 : 0,
        proofsGivenThisWeek: 0, // TODO: Implement proof interactions
        proofsReceivedThisWeek: 0,
        averageAccountabilityScore: 85.0, // Default score
        longestCombinedStreak: currentStreak,
        reviewsGiven: 0,
        reviewsReceived: 0,
        approvalRate: 0.85,
        lastActiveAt: DateTime.now().subtract(const Duration(hours: 2)),
      );

      print('✅ Buddy stats calculated');
      return stats;
    } catch (e) {
      print('❌ Error fetching buddy stats: $e');
      // Return default stats
      return const BuddyStats(
        totalBuddies: 0,
        activeStreaks: 0,
        proofsGivenThisWeek: 0,
        proofsReceivedThisWeek: 0,
        averageAccountabilityScore: 0.0,
        longestCombinedStreak: 0,
        reviewsGiven: 0,
        reviewsReceived: 0,
        approvalRate: 0.0,
      );
    }
  }

  // Search users for invitations
  static Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      print('🔍 Searching users with query: $query');

      if (query.length < 2) return [];

      final response = await _supabase
          .from('user_profiles')
          .select('id, username, display_name, profile_image_url')
          .neq('id', user.id) // Exclude current user
          .or('username.ilike.%$query%,display_name.ilike.%$query%')
          .limit(10);

      print('✅ Found ${response.length} users matching query');
      return response;
    } catch (e) {
      print('❌ Error searching users: $e');
      return [];
    }
  }

  // Helper method to map database data to Buddy
  static Buddy _mapToBuddy(Map<String, dynamic> data) {
    final profile = data['user_profiles'];
    
    return Buddy(
      id: profile['id'],
      username: profile['username'] ?? '',
      displayName: profile['display_name'] ?? '',
      email: profile['email'] ?? '',
      bio: profile['bio'],
      profileImageUrl: profile['profile_image_url'],
      createdAt: DateTime.parse(data['created_at']),
      status: BuddyStatus.accepted,
      accountabilityScore: 85, // Default score, TODO: Calculate actual score
      currentStreak: 0, // TODO: Calculate from routine completions
      longestStreak: 0, // TODO: Calculate from routine completions
    );
  }

  // Helper method to map database data to BuddyInvitation
  static BuddyInvitation _mapToBuddyInvitation(Map<String, dynamic> data) {
    final fromProfile = data['user_profiles'];
    
    return BuddyInvitation(
      id: data['id'],
      fromUserId: fromProfile['id'],
      toUserId: '', // Not needed for display
      fromUsername: fromProfile['username'] ?? '',
      fromDisplayName: fromProfile['display_name'] ?? '',
      fromProfileImageUrl: fromProfile['profile_image_url'],
      message: data['message'] ?? '',
      createdAt: DateTime.parse(data['created_at']),
      status: InvitationStatus.pending,
    );
  }

  // Helper method to map database data to ProofSubmission
  static ProofSubmission _mapToProofSubmission(Map<String, dynamic> data) {
    final routine = data['routines'];
    final userProfile = data['user_profiles'];
    
    return ProofSubmission(
      id: data['id'],
      userId: data['user_id'],
      routineId: data['routine_id'],
      subtaskId: '', // Not available in this context
      routineName: routine['name'] ?? '',
      subtaskName: 'Routine Completion',
      imageUrl: '', // TODO: Add image support
      notes: data['notes'],
      submittedAt: DateTime.parse(data['completed_at']),
      status: ProofStatus.pending,
    );
  }

  // Clear buddy cache
  static Future<void> _clearBuddyCache() async {
    try {
      await CacheService.saveBuddies([]);
      print('✅ Buddy cache cleared');
    } catch (e) {
      print('❌ Error clearing buddy cache: $e');
    }
  }
} 