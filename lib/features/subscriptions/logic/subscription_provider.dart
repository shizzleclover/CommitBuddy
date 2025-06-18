import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/subscription_model.dart';
import '../data/subscription_repository.dart';

// Repository provider
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return MockSubscriptionRepository();
});

// Current subscription provider
final currentSubscriptionProvider = FutureProvider.family<Subscription?, String>((ref, userId) async {
  final repository = ref.read(subscriptionRepositoryProvider);
  return await repository.getCurrentSubscription(userId);
});

// Available plans provider
final availablePlansProvider = FutureProvider<List<SubscriptionPlanDetails>>((ref) async {
  final repository = ref.read(subscriptionRepositoryProvider);
  return await repository.getAvailablePlans();
});

// Subscription state notifier
class SubscriptionState {
  final Subscription? currentSubscription;
  final List<SubscriptionPlanDetails> availablePlans;
  final bool isLoading;
  final String? error;
  final bool isProcessingPayment;

  const SubscriptionState({
    this.currentSubscription,
    this.availablePlans = const [],
    this.isLoading = false,
    this.error,
    this.isProcessingPayment = false,
  });

  SubscriptionState copyWith({
    Subscription? currentSubscription,
    List<SubscriptionPlanDetails>? availablePlans,
    bool? isLoading,
    String? error,
    bool? isProcessingPayment,
  }) {
    return SubscriptionState(
      currentSubscription: currentSubscription ?? this.currentSubscription,
      availablePlans: availablePlans ?? this.availablePlans,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isProcessingPayment: isProcessingPayment ?? this.isProcessingPayment,
    );
  }
}

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final SubscriptionRepository _repository;
  final String _userId;

  SubscriptionNotifier(this._repository, this._userId) : super(const SubscriptionState()) {
    _loadSubscriptionData();
  }

  Future<void> _loadSubscriptionData() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final subscription = await _repository.getCurrentSubscription(_userId);
      final plans = await _repository.getAvailablePlans();
      
      state = state.copyWith(
        currentSubscription: subscription,
        availablePlans: plans,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> subscribeToPlan(SubscriptionPlan plan, bool isYearly) async {
    state = state.copyWith(isProcessingPayment: true, error: null);
    
    try {
      final success = await _repository.subscribeToPlan(_userId, plan, isYearly);
      
      if (success) {
        // Reload subscription data
        await _loadSubscriptionData();
      }
      
      state = state.copyWith(isProcessingPayment: false);
      return success;
    } catch (e) {
      state = state.copyWith(
        isProcessingPayment: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> cancelSubscription() async {
    if (state.currentSubscription == null) return false;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final success = await _repository.cancelSubscription(state.currentSubscription!.id);
      
      if (success) {
        await _loadSubscriptionData();
      }
      
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

  Future<bool> updateAutoRenew(bool autoRenew) async {
    if (state.currentSubscription == null) return false;
    
    try {
      final success = await _repository.updateSubscription(
        state.currentSubscription!.id,
        autoRenew: autoRenew,
      );
      
      if (success) {
        await _loadSubscriptionData();
      }
      
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> refresh() async {
    await _loadSubscriptionData();
  }
}

// Subscription notifier provider
final subscriptionNotifierProvider = StateNotifierProvider.family<SubscriptionNotifier, SubscriptionState, String>((ref, userId) {
  final repository = ref.read(subscriptionRepositoryProvider);
  return SubscriptionNotifier(repository, userId);
});

// Convenience providers
final isPremiumUserProvider = Provider.family<bool, String>((ref, userId) {
  final subscriptionState = ref.watch(subscriptionNotifierProvider(userId));
  return subscriptionState.currentSubscription?.isPremium ?? false;
});

final subscriptionStatusProvider = Provider.family<SubscriptionStatus?, String>((ref, userId) {
  final subscriptionState = ref.watch(subscriptionNotifierProvider(userId));
  return subscriptionState.currentSubscription?.status;
}); 