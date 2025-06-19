import 'package:uuid/uuid.dart';

enum AccountabilityTransactionType {
  commitment,     // Initial commitment fee setup
  punishment,     // Deduction for missed routines
  refund,         // Refund for good behavior
  deposit,        // Adding money to accountability fund
}

enum AccountabilityTransactionStatus {
  pending,
  completed,
  failed,
  cancelled,
  processing,
}

class AccountabilityCommitment {
  final String id;
  final String userId;
  final double monthlyAmount;  // Monthly commitment amount
  final double currentBalance; // Current accountability balance
  final DateTime createdAt;
  final DateTime? nextPaymentDate;
  final bool isActive;
  final String? paymentMethodId;
  final int consecutiveMissedDays;
  final double totalPunishments;
  final double totalRefunds;
  final DateTime? lastChargeDate;
  final DateTime updatedAt;

  const AccountabilityCommitment({
    required this.id,
    required this.userId,
    required this.monthlyAmount,
    required this.currentBalance,
    required this.createdAt,
    this.nextPaymentDate,
    required this.isActive,
    this.paymentMethodId,
    this.consecutiveMissedDays = 0,
    this.totalPunishments = 0.0,
    this.totalRefunds = 0.0,
    this.lastChargeDate,
    required this.updatedAt,
  });

  // Computed properties
  bool get hasEnoughBalance => currentBalance >= 20.0;
  bool get needsTopUp => currentBalance < 40.0;
  double get punishmentRate => totalPunishments > 0 
      ? totalPunishments / (monthlyAmount + totalRefunds) 
      : 0.0;

  factory AccountabilityCommitment.fromJson(Map<String, dynamic> json) {
    return AccountabilityCommitment(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      monthlyAmount: (json['monthly_amount'] as num).toDouble(),
      currentBalance: (json['current_balance'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      nextPaymentDate: json['next_payment_date'] != null 
          ? DateTime.parse(json['next_payment_date'] as String) 
          : null,
      isActive: json['is_active'] as bool,
      paymentMethodId: json['payment_method_id'] as String?,
      consecutiveMissedDays: json['consecutive_missed_days'] as int? ?? 0,
      totalPunishments: (json['total_punishments'] as num?)?.toDouble() ?? 0.0,
      totalRefunds: (json['total_refunds'] as num?)?.toDouble() ?? 0.0,
      lastChargeDate: json['last_charge_date'] != null 
          ? DateTime.parse(json['last_charge_date'] as String) 
          : null,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'monthly_amount': monthlyAmount,
      'current_balance': currentBalance,
      'created_at': createdAt.toIso8601String(),
      'next_payment_date': nextPaymentDate?.toIso8601String(),
      'is_active': isActive,
      'payment_method_id': paymentMethodId,
      'consecutive_missed_days': consecutiveMissedDays,
      'total_punishments': totalPunishments,
      'total_refunds': totalRefunds,
      'last_charge_date': lastChargeDate?.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  AccountabilityCommitment copyWith({
    String? id,
    String? userId,
    double? monthlyAmount,
    double? currentBalance,
    DateTime? createdAt,
    DateTime? nextPaymentDate,
    bool? isActive,
    String? paymentMethodId,
    int? consecutiveMissedDays,
    double? totalPunishments,
    double? totalRefunds,
    DateTime? lastChargeDate,
    DateTime? updatedAt,
  }) {
    return AccountabilityCommitment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      monthlyAmount: monthlyAmount ?? this.monthlyAmount,
      currentBalance: currentBalance ?? this.currentBalance,
      createdAt: createdAt ?? this.createdAt,
      nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
      isActive: isActive ?? this.isActive,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      consecutiveMissedDays: consecutiveMissedDays ?? this.consecutiveMissedDays,
      totalPunishments: totalPunishments ?? this.totalPunishments,
      totalRefunds: totalRefunds ?? this.totalRefunds,
      lastChargeDate: lastChargeDate ?? this.lastChargeDate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class AccountabilityTransaction {
  final String id;
  final String userId;
  final AccountabilityTransactionType type;
  final double amount;
  final AccountabilityTransactionStatus status;
  final String description;
  final String? routineId;
  final String? routineName;
  final DateTime createdAt;
  final DateTime? processedAt;
  final Map<String, dynamic>? metadata;

  const AccountabilityTransaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.status,
    required this.description,
    this.routineId,
    this.routineName,
    required this.createdAt,
    this.processedAt,
    this.metadata,
  });

  factory AccountabilityTransaction.createPunishment({
    required String userId,
    required String routineId,
    required String routineName,
  }) {
    const uuid = Uuid();
    return AccountabilityTransaction(
      id: uuid.v4(),
      userId: userId,
      type: AccountabilityTransactionType.punishment,
      amount: 20.0,
      status: AccountabilityTransactionStatus.completed,
      description: 'Missed routine: $routineName',
      routineId: routineId,
      routineName: routineName,
      createdAt: DateTime.now(),
      processedAt: DateTime.now(),
    );
  }

  factory AccountabilityTransaction.createCommitment({
    required String userId,
    required double amount,
  }) {
    const uuid = Uuid();
    return AccountabilityTransaction(
      id: uuid.v4(),
      userId: userId,
      type: AccountabilityTransactionType.commitment,
      amount: amount,
      status: AccountabilityTransactionStatus.completed,
      description: 'Monthly accountability commitment',
      createdAt: DateTime.now(),
      processedAt: DateTime.now(),
    );
  }

  factory AccountabilityTransaction.fromJson(Map<String, dynamic> json) {
    return AccountabilityTransaction(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: AccountabilityTransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AccountabilityTransactionType.commitment,
      ),
      amount: (json['amount'] as num).toDouble(),
      status: AccountabilityTransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AccountabilityTransactionStatus.pending,
      ),
      description: json['description'] as String,
      routineId: json['routine_id'] as String?,
      routineName: json['routine_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      processedAt: json['processed_at'] != null 
          ? DateTime.parse(json['processed_at'] as String) 
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.name,
      'amount': amount,
      'status': status.name,
      'description': description,
      'routine_id': routineId,
      'routine_name': routineName,
      'created_at': createdAt.toIso8601String(),
      'processed_at': processedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }
}

class AccountabilityStats {
  final double totalCommitted;
  final double totalPunishments;
  final double totalRefunds;
  final int missedRoutines;
  final int consecutiveDays;
  final double currentBalance;
  final double savingsFromAccountability;

  const AccountabilityStats({
    required this.totalCommitted,
    required this.totalPunishments,
    required this.totalRefunds,
    required this.missedRoutines,
    required this.consecutiveDays,
    required this.currentBalance,
    required this.savingsFromAccountability,
  });

  double get punishmentRate => totalCommitted > 0 
      ? totalPunishments / totalCommitted 
      : 0.0;
  
  bool get isDoingWell => punishmentRate < 0.2; // Less than 20% punishment rate
} 