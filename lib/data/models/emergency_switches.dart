class EmergencySwitchPackage {
  final String id;
  final String name;
  final String description;
  final int switchesCount;
  final double price;
  final double pricePerSwitch;
  final String popularityTag;
  final bool isPopular;

  const EmergencySwitchPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.switchesCount,
    required this.price,
    required this.pricePerSwitch,
    required this.popularityTag,
    this.isPopular = false,
  });

  static List<EmergencySwitchPackage> get packages => [
    EmergencySwitchPackage(
      id: 'basic',
      name: 'Basic Pack',
      description: 'Perfect for occasional needs',
      switchesCount: 5,
      price: 12.00,
      pricePerSwitch: 2.40,
      popularityTag: 'STARTER',
    ),
    EmergencySwitchPackage(
      id: 'value',
      name: 'Value Pack',
      description: 'Best value for regular users',
      switchesCount: 10,
      price: 20.00,
      pricePerSwitch: 2.00,
      popularityTag: 'MOST POPULAR',
      isPopular: true,
    ),
    EmergencySwitchPackage(
      id: 'premium',
      name: 'Premium Pack',
      description: 'Maximum protection for power users',
      switchesCount: 20,
      price: 35.00,
      pricePerSwitch: 1.75,
      popularityTag: 'BEST VALUE',
    ),
  ];

  double get savingsPercentage {
    const basePrice = 2.40; // Price from basic pack
    return ((basePrice - pricePerSwitch) / basePrice * 100);
  }
}

class EmergencySwitchPurchase {
  final String id;
  final String userId;
  final String packageType;
  final int switchesCount;
  final double amountPaid;
  final String? stripePaymentIntentId;
  final DateTime purchasedAt;
  final EmergencySwitchPurchaseStatus status;

  const EmergencySwitchPurchase({
    required this.id,
    required this.userId,
    required this.packageType,
    required this.switchesCount,
    required this.amountPaid,
    this.stripePaymentIntentId,
    required this.purchasedAt,
    required this.status,
  });

  factory EmergencySwitchPurchase.fromJson(Map<String, dynamic> json) {
    return EmergencySwitchPurchase(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      packageType: json['package_type'] as String,
      switchesCount: json['switches_count'] as int,
      amountPaid: (json['amount_paid'] as num).toDouble(),
      stripePaymentIntentId: json['stripe_payment_intent_id'] as String?,
      purchasedAt: DateTime.parse(json['purchased_at'] as String),
      status: EmergencySwitchPurchaseStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => EmergencySwitchPurchaseStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'package_type': packageType,
      'switches_count': switchesCount,
      'amount_paid': amountPaid,
      'stripe_payment_intent_id': stripePaymentIntentId,
      'purchased_at': purchasedAt.toIso8601String(),
      'status': status.name,
    };
  }
}

enum EmergencySwitchPurchaseStatus {
  pending,
  completed,
  failed,
}

class EmergencySwitchUsage {
  final String id;
  final String userId;
  final String routineId;
  final String routineName;
  final DateTime usedDate;
  final String reason;
  final DateTime createdAt;

  const EmergencySwitchUsage({
    required this.id,
    required this.userId,
    required this.routineId,
    required this.routineName,
    required this.usedDate,
    required this.reason,
    required this.createdAt,
  });

  factory EmergencySwitchUsage.fromJson(Map<String, dynamic> json) {
    return EmergencySwitchUsage(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      routineId: json['routine_id'] as String,
      routineName: json['routine_name'] as String,
      usedDate: DateTime.parse(json['used_date'] as String),
      reason: json['reason'] as String? ?? 'emergency_excuse',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'routine_id': routineId,
      'routine_name': routineName,
      'used_date': usedDate.toIso8601String().split('T')[0], // Date only
      'reason': reason,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class EmergencySwitchStats {
  final int totalSwitches;
  final int usedSwitches;
  final int remainingSwitches;
  final List<EmergencySwitchUsage> recentUsage;
  final List<EmergencySwitchPurchase> purchaseHistory;

  const EmergencySwitchStats({
    required this.totalSwitches,
    required this.usedSwitches,
    required this.remainingSwitches,
    required this.recentUsage,
    required this.purchaseHistory,
  });

  bool get hasAvailableSwitches => remainingSwitches > 0;
  
  double get usagePercentage => totalSwitches > 0 ? (usedSwitches / totalSwitches) : 0.0;
} 