import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/buddy_service.dart';
import '../../../data/models/buddy.dart';

// Buddy State
class BuddyState {
  final List<Buddy> buddies;
  final List<BuddyInvitation> invitations;
  final List<ProofSubmission> proofSubmissions;
  final bool isLoading;
  final String? error;

  const BuddyState({
    this.buddies = const [],
    this.invitations = const [],
    this.proofSubmissions = const [],
    this.isLoading = false,
    this.error,
  });

  BuddyState copyWith({
    List<Buddy>? buddies,
    List<BuddyInvitation>? invitations,
    List<ProofSubmission>? proofSubmissions,
    bool? isLoading,
    String? error,
  }) {
    return BuddyState(
      buddies: buddies ?? this.buddies,
      invitations: invitations ?? this.invitations,
      proofSubmissions: proofSubmissions ?? this.proofSubmissions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Buddy Notifier
class BuddyNotifier extends StateNotifier<BuddyState> {
  BuddyNotifier() : super(const BuddyState());

  // Load all buddy data
  Future<void> loadBuddyData({bool fromCache = true}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final results = await Future.wait([
        BuddyService.getBuddies(fromCache: fromCache),
        BuddyService.getPendingInvitations(),
        BuddyService.getProofSubmissionsForReview(),
      ]);
      
      state = state.copyWith(
        buddies: results[0] as List<Buddy>,
        invitations: results[1] as List<BuddyInvitation>,
        proofSubmissions: results[2] as List<ProofSubmission>,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Load buddies only
  Future<void> loadBuddies({bool fromCache = true}) async {
    try {
      final buddies = await BuddyService.getBuddies(fromCache: fromCache);
      state = state.copyWith(buddies: buddies);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Load invitations only
  Future<void> loadInvitations() async {
    try {
      final invitations = await BuddyService.getPendingInvitations();
      state = state.copyWith(invitations: invitations);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Load proof submissions
  Future<void> loadProofSubmissions() async {
    try {
      final proofs = await BuddyService.getProofSubmissionsForReview();
      state = state.copyWith(proofSubmissions: proofs);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Send buddy invitation
  Future<bool> sendInvitation({
    required String toUsername,
    String? message,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final success = await BuddyService.sendInvitation(
        toUsername: toUsername,
        message: message,
      );
      
      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Accept invitation
  Future<bool> acceptInvitation(String invitationId) async {
    try {
      final success = await BuddyService.acceptInvitation(invitationId);
      
      if (success) {
        // Remove from invitations and refresh buddies
        state = state.copyWith(
          invitations: state.invitations.where((inv) => inv.id != invitationId).toList(),
        );
        await loadBuddies(fromCache: false);
      }
      
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Decline invitation
  Future<bool> declineInvitation(String invitationId) async {
    try {
      final success = await BuddyService.declineInvitation(invitationId);
      
      if (success) {
        // Remove from invitations
        state = state.copyWith(
          invitations: state.invitations.where((inv) => inv.id != invitationId).toList(),
        );
      }
      
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Search users
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      return await BuddyService.searchUsers(query);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return [];
    }
  }

  // Get buddy stats
  Future<BuddyStats?> getBuddyStats(String buddyId) async {
    try {
      return await BuddyService.getBuddyStats(buddyId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Refresh all buddy data
  Future<void> refresh() async {
    await loadBuddyData(fromCache: false);
  }

  // Refresh all buddy data (alias for compatibility)
  Future<void> refreshAll() async {
    await loadBuddyData(fromCache: false);
  }

  // Get buddy by ID
  Buddy? getBuddyById(String id) {
    try {
      return state.buddies.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }
}

// Buddy Search State
class BuddySearchState {
  final List<Map<String, dynamic>> searchResults;
  final bool isSearching;
  final String? searchError;

  const BuddySearchState({
    this.searchResults = const [],
    this.isSearching = false,
    this.searchError,
  });

  BuddySearchState copyWith({
    List<Map<String, dynamic>>? searchResults,
    bool? isSearching,
    String? searchError,
  }) {
    return BuddySearchState(
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      searchError: searchError,
    );
  }
}

// Buddy Search Notifier
class BuddySearchNotifier extends StateNotifier<BuddySearchState> {
  BuddySearchNotifier() : super(const BuddySearchState());

  // Search users
  Future<void> searchUsers(String query) async {
    if (query.length < 2) {
      state = state.copyWith(searchResults: [], searchError: null);
      return;
    }

    state = state.copyWith(isSearching: true, searchError: null);
    
    try {
      final results = await BuddyService.searchUsers(query);
      state = state.copyWith(
        searchResults: results,
        isSearching: false,
      );
    } catch (e) {
      state = state.copyWith(
        isSearching: false,
        searchError: e.toString(),
      );
    }
  }

  // Clear search
  void clearSearch() {
    state = state.copyWith(
      searchResults: [],
      searchError: null,
    );
  }

  // Clear error
  void clearError() {
    state = state.copyWith(searchError: null);
  }
}

// Providers
final buddyProvider = StateNotifierProvider<BuddyNotifier, BuddyState>((ref) {
  return BuddyNotifier();
});

final buddySearchProvider = StateNotifierProvider<BuddySearchNotifier, BuddySearchState>((ref) {
  return BuddySearchNotifier();
});

// Convenient getters
final allBuddiesProvider = Provider<List<Buddy>>((ref) {
  return ref.watch(buddyProvider).buddies;
});

final pendingInvitationsProvider = Provider<List<BuddyInvitation>>((ref) {
  return ref.watch(buddyProvider).invitations;
});

final proofSubmissionsProvider = Provider<List<ProofSubmission>>((ref) {
  return ref.watch(buddyProvider).proofSubmissions;
});

final buddyLoadingProvider = Provider<bool>((ref) {
  return ref.watch(buddyProvider).isLoading;
});

final buddyErrorProvider = Provider<String?>((ref) {
  return ref.watch(buddyProvider).error;
});

final searchResultsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(buddySearchProvider).searchResults;
});

final isSearchingProvider = Provider<bool>((ref) {
  return ref.watch(buddySearchProvider).isSearching;
});

// FutureProvider for initial buddy load
final buddyInitProvider = FutureProvider<List<Buddy>>((ref) async {
  return await BuddyService.getBuddies();
});

// Provider for buddy stats
final buddyStatsProvider = Provider<Map<String, int>>((ref) {
  final buddies = ref.watch(allBuddiesProvider);
  final invitations = ref.watch(pendingInvitationsProvider);
  final proofs = ref.watch(proofSubmissionsProvider);
  
  return {
    'total_buddies': buddies.length,
    'pending_invitations': invitations.length,
    'proofs_to_review': proofs.length,
    'active_buddies': buddies.where((b) => b.status == BuddyStatus.accepted).length,
  };
}); 