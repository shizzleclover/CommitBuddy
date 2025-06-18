enum SubscriptionPlan {
  free,
  premium,
}

enum SubscriptionStatus {
  active,
  inactive,
  expired,
  pendingPayment,
  cancelled,
}

class Subscription {
  final String id;
  final String userId;
  final SubscriptionPlan plan;
  final SubscriptionStatus status;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? nextBillingDate;
  final double? price;
  final String? currency;
  final bool autoRenew;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Subscription({
    required this.id,
    required this.userId,
    required this.plan,
    required this.status,
    this.startDate,
    this.endDate,
    this.nextBillingDate,
    this.price,
    this.currency,
    required this.autoRenew,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPremium => plan == SubscriptionPlan.premium && status == SubscriptionStatus.active;
  bool get isFree => plan == SubscriptionPlan.free;
  bool get isActive => status == SubscriptionStatus.active;
  bool get isExpired => status == SubscriptionStatus.expired;
  bool get isPendingPayment => status == SubscriptionStatus.pendingPayment;

  String get planDisplayName {
    switch (plan) {
      case SubscriptionPlan.free:
        return 'Free';
      case SubscriptionPlan.premium:
        return 'Premium';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case SubscriptionStatus.active:
        return 'Active';
      case SubscriptionStatus.inactive:
        return 'Inactive';
      case SubscriptionStatus.expired:
        return 'Expired';
      case SubscriptionStatus.pendingPayment:
        return 'Pending Payment';
      case SubscriptionStatus.cancelled:
        return 'Cancelled';
    }
  }

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      plan: SubscriptionPlan.values.firstWhere(
        (e) => e.name == json['plan'],
        orElse: () => SubscriptionPlan.free,
      ),
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SubscriptionStatus.inactive,
      ),
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      nextBillingDate: json['next_billing_date'] != null ? DateTime.parse(json['next_billing_date']) : null,
      price: json['price']?.toDouble(),
      currency: json['currency'] as String?,
      autoRenew: json['auto_renew'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'plan': plan.name,
      'status': status.name,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'next_billing_date': nextBillingDate?.toIso8601String(),
      'price': price,
      'currency': currency,
      'auto_renew': autoRenew,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Subscription copyWith({
    String? id,
    String? userId,
    SubscriptionPlan? plan,
    SubscriptionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? nextBillingDate,
    double? price,
    String? currency,
    bool? autoRenew,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Subscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      plan: plan ?? this.plan,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      autoRenew: autoRenew ?? this.autoRenew,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PremiumFeature {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isAvailable;

  const PremiumFeature({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isAvailable,
  });
}

class SubscriptionPlanDetails {
  final SubscriptionPlan plan;
  final String title;
  final String description;
  final double monthlyPrice;
  final double yearlyPrice;
  final String currency;
  final List<PremiumFeature> features;
  final bool isPopular;

  const SubscriptionPlanDetails({
    required this.plan,
    required this.title,
    required this.description,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.currency,
    required this.features,
    this.isPopular = false,
  });

  static const List<SubscriptionPlanDetails> availablePlans = [
    SubscriptionPlanDetails(
      plan: SubscriptionPlan.free,
      title: 'Free',
      description: 'Get started with basic features',
      monthlyPrice: 0,
      yearlyPrice: 0,
      currency: 'USD',
      features: [
        PremiumFeature(
          id: 'basic_routines',
          title: 'Basic Routines',
          description: 'Create up to 3 routines',
          icon: '🏃‍♂️',
          isAvailable: true,
        ),
        PremiumFeature(
          id: 'basic_buddy',
          title: 'Basic Buddy',
          description: 'Connect with 1 buddy',
          icon: '👥',
          isAvailable: true,
        ),
      ],
      isPopular: false,
    ),
    SubscriptionPlanDetails(
      plan: SubscriptionPlan.premium,
      title: 'Premium',
      description: 'Unlock all features and unlimited access',
      monthlyPrice: 9.99,
      yearlyPrice: 99.99,
      currency: 'USD',
      features: [
        PremiumFeature(
          id: 'unlimited_routines',
          title: 'Unlimited Routines',
          description: 'Create unlimited routines',
          icon: '♾️',
          isAvailable: true,
        ),
        PremiumFeature(
          id: 'unlimited_buddies',
          title: 'Unlimited Buddies',
          description: 'Connect with unlimited buddies',
          icon: '👥',
          isAvailable: true,
        ),
        PremiumFeature(
          id: 'advanced_analytics',
          title: 'Advanced Analytics',
          description: 'Detailed progress tracking',
          icon: '📊',
          isAvailable: true,
        ),
        PremiumFeature(
          id: 'custom_themes',
          title: 'Custom Themes',
          description: 'Personalize your experience',
          icon: '🎨',
          isAvailable: true,
        ),
        PremiumFeature(
          id: 'priority_support',
          title: 'Priority Support',
          description: '24/7 priority customer support',
          icon: '🛠️',
          isAvailable: true,
        ),
      ],
      isPopular: true,
    ),
  ];
} 