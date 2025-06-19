import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../features/subscriptions/data/accountability_model.dart';

class AccountabilityService {
  static final _supabase = Supabase.instance.client;
  static const _uuid = Uuid();

  // Check for missed routines and apply punishments
  static Future<void> checkMissedRoutines() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      print('🔍 Checking for missed routines for user: ${user.id}');

      // Get user's accountability commitment
      final commitment = await getAccountabilityCommitment(user.id);
      if (commitment == null || !commitment.isActive) {
        print('ℹ️ No active accountability commitment found');
        return;
      }

      // Get all active routines for yesterday
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final weekday = yesterday.weekday; // 1=Monday, 7=Sunday
      
      final routinesResponse = await _supabase
          .from('routines')
          .select('id, name, repeat_days')
          .eq('user_id', user.id)
          .eq('is_active', true);

      final routines = routinesResponse.where((routine) {
        final repeatDays = List<String>.from(routine['repeat_days'] ?? []);
        final weekdayNames = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
        final yesterdayName = weekdayNames[weekday - 1];
        return repeatDays.contains(yesterdayName);
      }).toList();

      if (routines.isEmpty) {
        print('ℹ️ No routines scheduled for yesterday');
        return;
      }

      // Check which routines were completed yesterday
      final yesterdayStart = DateTime(yesterday.year, yesterday.month, yesterday.day);
      final yesterdayEnd = yesterdayStart.add(const Duration(days: 1));

      final completionsResponse = await _supabase
          .from('routine_completions')
          .select('routine_id')
          .eq('user_id', user.id)
          .gte('completed_at', yesterdayStart.toIso8601String())
          .lt('completed_at', yesterdayEnd.toIso8601String());

      final completedRoutineIds = completionsResponse.map((c) => c['routine_id']).toSet();

      // Find missed routines
      final missedRoutines = routines.where((routine) => 
          !completedRoutineIds.contains(routine['id'])).toList();

      print('📊 Found ${missedRoutines.length} missed routines for yesterday');

      // Apply punishments for missed routines
      for (final routine in missedRoutines) {
        await _applyPunishment(
          userId: user.id,
          routineId: routine['id'],
          routineName: routine['name'],
          commitment: commitment,
        );
      }

    } catch (e) {
      print('❌ Error checking missed routines: $e');
    }
  }

  // Apply $20 punishment for a missed routine
  static Future<void> _applyPunishment({
    required String userId,
    required String routineId,
    required String routineName,
    required AccountabilityCommitment commitment,
  }) async {
    try {
      print('💸 Applying \$20 punishment for missed routine: $routineName');

      // Check if punishment already applied for this routine today
      final existingPunishment = await _supabase
          .from('accountability_transactions')
          .select('id')
          .eq('user_id', userId)
          .eq('routine_id', routineId)
          .eq('type', 'punishment')
          .gte('created_at', DateTime.now().subtract(const Duration(days: 1)).toIso8601String())
          .maybeSingle();

      if (existingPunishment != null) {
        print('ℹ️ Punishment already applied for this routine');
        return;
      }

      // Check if user has enough balance
      if (!commitment.hasEnoughBalance) {
        print('⚠️ Insufficient balance for punishment');
        await _handleInsufficientBalance(userId, commitment);
        return;
      }

      // Create punishment transaction
      final transaction = AccountabilityTransaction.createPunishment(
        userId: userId,
        routineId: routineId,
        routineName: routineName,
      );

      // Insert transaction
      await _supabase.from('accountability_transactions').insert(transaction.toJson());

      // Update commitment balance
      final newBalance = commitment.currentBalance - 20.0;
      final newConsecutiveMissedDays = commitment.consecutiveMissedDays + 1;
      final newTotalPunishments = commitment.totalPunishments + 20.0;

      await _supabase
          .from('accountability_commitments')
          .update({
            'current_balance': newBalance,
            'consecutive_missed_days': newConsecutiveMissedDays,
            'total_punishments': newTotalPunishments,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);

      print('✅ \$20 punishment applied successfully');

      // Check if balance is getting low
      if (newBalance < 40.0) {
        await _notifyLowBalance(userId, newBalance);
      }

    } catch (e) {
      print('❌ Error applying punishment: $e');
    }
  }

  // Handle insufficient balance
  static Future<void> _handleInsufficientBalance(String userId, AccountabilityCommitment commitment) async {
    try {
      // Pause accountability temporarily
      await _supabase
          .from('accountability_commitments')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);

      // Create notification for user to top up
      await _supabase.from('notifications').insert({
        'id': _uuid.v4(),
        'user_id': userId,
        'type': 'accountability_insufficient_balance',
        'title': 'Accountability Account Needs Top-Up',
        'message': 'Your accountability balance (\$${commitment.currentBalance.toStringAsFixed(2)}) is too low. Please add funds to continue accountability tracking.',
        'created_at': DateTime.now().toIso8601String(),
        'is_read': false,
      });

      print('⚠️ Accountability paused due to insufficient balance');
    } catch (e) {
      print('❌ Error handling insufficient balance: $e');
    }
  }

  // Notify user of low balance
  static Future<void> _notifyLowBalance(String userId, double balance) async {
    try {
      await _supabase.from('notifications').insert({
        'id': _uuid.v4(),
        'user_id': userId,
        'type': 'accountability_low_balance',
        'title': 'Low Accountability Balance',
        'message': 'Your accountability balance is low (\$${balance.toStringAsFixed(2)}). Consider adding funds to avoid disruption.',
        'created_at': DateTime.now().toIso8601String(),
        'is_read': false,
      });
    } catch (e) {
      print('❌ Error sending low balance notification: $e');
    }
  }

  // Get user's accountability commitment
  static Future<AccountabilityCommitment?> getAccountabilityCommitment(String userId) async {
    try {
      final response = await _supabase
          .from('accountability_commitments')
          .select('*')
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        return AccountabilityCommitment.fromJson(response);
      }
      return null;
    } catch (e) {
      print('❌ Error fetching accountability commitment: $e');
      return null;
    }
  }

  // Create new accountability commitment (the $15 monthly app subscription)
  static Future<AccountabilityCommitment> createAccountabilityCommitment({
    required String userId,
    required String paymentMethodId,
  }) async {
    try {
      print('🆕 Creating accountability commitment for user: $userId');

      const monthlyAmount = 15.0; // $15 monthly commitment fee (app subscription)
      
      final commitment = AccountabilityCommitment(
        id: _uuid.v4(),
        userId: userId,
        monthlyAmount: monthlyAmount,
        currentBalance: monthlyAmount, // Start with first month's commitment
        createdAt: DateTime.now(),
        nextPaymentDate: DateTime.now().add(const Duration(days: 30)),
        isActive: true,
        paymentMethodId: paymentMethodId,
        updatedAt: DateTime.now(),
      );

      await _supabase.from('accountability_commitments').insert(commitment.toJson());

      // Create initial commitment transaction
      final transaction = AccountabilityTransaction.createCommitment(
        userId: userId,
        amount: monthlyAmount,
      );

      await _supabase.from('accountability_transactions').insert(transaction.toJson());

      print('✅ Accountability commitment created successfully');
      return commitment;
    } catch (e) {
      print('❌ Error creating accountability commitment: $e');
      rethrow;
    }
  }

  // Add funds to accountability balance
  static Future<bool> addFunds({
    required String userId,
    required double amount,
  }) async {
    try {
      print('💰 Adding \$${amount.toStringAsFixed(2)} to accountability balance');

      final commitment = await getAccountabilityCommitment(userId);
      if (commitment == null) {
        throw Exception('No accountability commitment found');
      }

      // Create deposit transaction
      final transaction = AccountabilityTransaction(
        id: _uuid.v4(),
        userId: userId,
        type: AccountabilityTransactionType.deposit,
        amount: amount,
        status: AccountabilityTransactionStatus.completed,
        description: 'Accountability balance top-up',
        createdAt: DateTime.now(),
        processedAt: DateTime.now(),
      );

      await _supabase.from('accountability_transactions').insert(transaction.toJson());

      // Update commitment balance
      final newBalance = commitment.currentBalance + amount;
      await _supabase
          .from('accountability_commitments')
          .update({
            'current_balance': newBalance,
            'is_active': true, // Reactivate if it was paused
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);

      print('✅ Funds added successfully');
      return true;
    } catch (e) {
      print('❌ Error adding funds: $e');
      return false;
    }
  }

  // Get accountability stats
  static Future<AccountabilityStats> getAccountabilityStats(String userId) async {
    try {
      final commitment = await getAccountabilityCommitment(userId);
      if (commitment == null) {
        return const AccountabilityStats(
          totalCommitted: 0,
          totalPunishments: 0,
          totalRefunds: 0,
          missedRoutines: 0,
          consecutiveDays: 0,
          currentBalance: 0,
          savingsFromAccountability: 0,
        );
      }

      // Get all transactions
      final transactions = await _supabase
          .from('accountability_transactions')
          .select('*')
          .eq('user_id', userId);

      final commitmentTransactions = transactions.where((t) => t['type'] == 'commitment').toList();
      final punishmentTransactions = transactions.where((t) => t['type'] == 'punishment').toList();
      final refundTransactions = transactions.where((t) => t['type'] == 'refund').toList();

      final totalCommitted = commitmentTransactions.fold(0.0, (sum, t) => sum + (t['amount'] as num).toDouble());
      final totalPunishments = punishmentTransactions.fold(0.0, (sum, t) => sum + (t['amount'] as num).toDouble());
      final totalRefunds = refundTransactions.fold(0.0, (sum, t) => sum + (t['amount'] as num).toDouble());

      // Calculate consecutive successful days (days without punishments)
      final now = DateTime.now();
      int consecutiveDays = 0;
      for (int i = 1; i <= 30; i++) { // Check last 30 days
        final checkDate = now.subtract(Duration(days: i));
        final dayStart = DateTime(checkDate.year, checkDate.month, checkDate.day);
        final dayEnd = dayStart.add(const Duration(days: 1));

        final dayPunishments = punishmentTransactions.where((t) {
          final createdAt = DateTime.parse(t['created_at']);
          return createdAt.isAfter(dayStart) && createdAt.isBefore(dayEnd);
        }).toList();

        if (dayPunishments.isEmpty) {
          consecutiveDays++;
        } else {
          break;
        }
      }

      return AccountabilityStats(
        totalCommitted: totalCommitted,
        totalPunishments: totalPunishments,
        totalRefunds: totalRefunds,
        missedRoutines: punishmentTransactions.length,
        consecutiveDays: consecutiveDays,
        currentBalance: commitment.currentBalance,
        savingsFromAccountability: totalCommitted - totalPunishments,
      );
    } catch (e) {
      print('❌ Error fetching accountability stats: $e');
      return const AccountabilityStats(
        totalCommitted: 0,
        totalPunishments: 0,
        totalRefunds: 0,
        missedRoutines: 0,
        consecutiveDays: 0,
        currentBalance: 0,
        savingsFromAccountability: 0,
      );
    }
  }

  // Reward user for consistent behavior (potential refund)
  static Future<void> checkForRewards(String userId) async {
    try {
      final commitment = await getAccountabilityCommitment(userId);
      if (commitment == null) return;

      // Check if user has completed 7 days without any punishments
      if (commitment.consecutiveMissedDays == 0) {
        final stats = await getAccountabilityStats(userId);
        
        // If user has 7+ consecutive successful days, give a small refund
        if (stats.consecutiveDays >= 7 && stats.consecutiveDays % 7 == 0) {
          final refundAmount = 5.0; // $5 reward for every 7 consecutive days
          
          final transaction = AccountabilityTransaction(
            id: _uuid.v4(),
            userId: userId,
            type: AccountabilityTransactionType.refund,
            amount: refundAmount,
            status: AccountabilityTransactionStatus.completed,
            description: 'Consistency reward - ${stats.consecutiveDays} days streak',
            createdAt: DateTime.now(),
            processedAt: DateTime.now(),
          );

          await _supabase.from('accountability_transactions').insert(transaction.toJson());

          // Update commitment
          await _supabase
              .from('accountability_commitments')
              .update({
                'current_balance': commitment.currentBalance + refundAmount,
                'total_refunds': commitment.totalRefunds + refundAmount,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('user_id', userId);

          print('🎉 \$${refundAmount.toStringAsFixed(2)} reward given for ${stats.consecutiveDays} day streak');
        }
      }
    } catch (e) {
      print('❌ Error checking for rewards: $e');
    }
  }

  // Get recent transactions
  static Future<List<AccountabilityTransaction>> getRecentTransactions(String userId, {int limit = 10}) async {
    try {
      final response = await _supabase
          .from('accountability_transactions')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return response.map((data) => AccountabilityTransaction.fromJson(data)).toList();
    } catch (e) {
      print('❌ Error fetching recent transactions: $e');
      return [];
    }
  }
} 