import 'subscription_model.dart';

abstract class SubscriptionRepository {
  Future<Subscription?> getCurrentSubscription(String userId);
  Future<List<SubscriptionPlanDetails>> getAvailablePlans();
  Future<bool> subscribeToPlan(String userId, SubscriptionPlan plan, bool isYearly);
  Future<bool> cancelSubscription(String subscriptionId);
  Future<bool> updateSubscription(String subscriptionId, {bool? autoRenew});
  Future<String> createPaymentSession(String userId, SubscriptionPlan plan, bool isYearly);
  Future<bool> verifyPayment(String sessionId);
}

class MockSubscriptionRepository implements SubscriptionRepository {
  static Subscription? _currentSubscription;
  
  @override
  Future<Subscription?> getCurrentSubscription(String userId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Return mock subscription or null for free users
    return _currentSubscription ?? Subscription(
      id: 'sub_free_$userId',
      userId: userId,
      plan: SubscriptionPlan.free,
      status: SubscriptionStatus.active,
      autoRenew: false,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<List<SubscriptionPlanDetails>> getAvailablePlans() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return SubscriptionPlanDetails.availablePlans;
  }

  @override
  Future<bool> subscribeToPlan(String userId, SubscriptionPlan plan, bool isYearly) async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (plan == SubscriptionPlan.premium) {
      final now = DateTime.now();
      _currentSubscription = Subscription(
        id: 'sub_premium_$userId',
        userId: userId,
        plan: plan,
        status: SubscriptionStatus.active,
        startDate: now,
        endDate: isYearly ? now.add(const Duration(days: 365)) : now.add(const Duration(days: 30)),
        nextBillingDate: isYearly ? now.add(const Duration(days: 365)) : now.add(const Duration(days: 30)),
        price: isYearly ? 99.99 : 9.99,
        currency: 'USD',
        autoRenew: true,
        createdAt: now,
        updatedAt: now,
      );
      return true;
    }
    return false;
  }

  @override
  Future<bool> cancelSubscription(String subscriptionId) async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (_currentSubscription?.id == subscriptionId) {
      _currentSubscription = _currentSubscription?.copyWith(
        status: SubscriptionStatus.cancelled,
        autoRenew: false,
        updatedAt: DateTime.now(),
      );
      return true;
    }
    return false;
  }

  @override
  Future<bool> updateSubscription(String subscriptionId, {bool? autoRenew}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (_currentSubscription?.id == subscriptionId) {
      _currentSubscription = _currentSubscription?.copyWith(
        autoRenew: autoRenew ?? _currentSubscription?.autoRenew,
        updatedAt: DateTime.now(),
      );
      return true;
    }
    return false;
  }

  @override
  Future<String> createPaymentSession(String userId, SubscriptionPlan plan, bool isYearly) async {
    await Future.delayed(const Duration(seconds: 1));
    // Return mock session ID
    return 'session_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<bool> verifyPayment(String sessionId) async {
    await Future.delayed(const Duration(seconds: 2));
    // Mock successful payment verification
    return sessionId.isNotEmpty;
  }
} 