import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/emergency_switches.dart';

class EmergencySwitchesService {
  static final _supabase = Supabase.instance.client;
  static const _uuid = Uuid();

  // Get user's emergency switches stats
  static Future<EmergencySwitchStats> getEmergencySwitchStats() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      print('📊 Fetching emergency switch stats for user: ${user.id}');

      // Get current switches count from user profile
      final profileResponse = await _supabase
          .from('user_profiles')
          .select('emergency_switches_count')
          .eq('user_id', user.id)
          .single();

      final totalSwitches = profileResponse['emergency_switches_count'] as int? ?? 2;

      // Get usage history
      final usageResponse = await _supabase
          .from('emergency_switches_usage')
          .select('*')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final recentUsage = usageResponse
          .map((json) => EmergencySwitchUsage.fromJson(json))
          .toList();

      // Get purchase history
      final purchaseResponse = await _supabase
          .from('emergency_switches_purchases')
          .select('*')
          .eq('user_id', user.id)
          .order('purchased_at', ascending: false);

      final purchaseHistory = purchaseResponse
          .map((json) => EmergencySwitchPurchase.fromJson(json))
          .toList();

      final usedSwitches = recentUsage.length;
      final remainingSwitches = (totalSwitches - usedSwitches).clamp(0, totalSwitches);

      print('✅ Emergency switch stats fetched: $remainingSwitches/$totalSwitches remaining');

      return EmergencySwitchStats(
        totalSwitches: totalSwitches,
        usedSwitches: usedSwitches,
        remainingSwitches: remainingSwitches,
        recentUsage: recentUsage,
        purchaseHistory: purchaseHistory,
      );
    } catch (e) {
      print('❌ Error fetching emergency switch stats: $e');
      return const EmergencySwitchStats(
        totalSwitches: 2,
        usedSwitches: 0,
        remainingSwitches: 2,
        recentUsage: [],
        purchaseHistory: [],
      );
    }
  }

  // Use an emergency switch for a missed routine
  static Future<bool> useEmergencySwitch({
    required String routineId,
    required String routineName,
    String reason = 'emergency_excuse',
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      print('🚨 Using emergency switch for routine: $routineName');

      // Check if user has available switches
      final stats = await getEmergencySwitchStats();
      if (!stats.hasAvailableSwitches) {
        print('❌ No emergency switches available');
        return false;
      }

      // Check if already used switch for this routine today
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      final existingUsage = await _supabase
          .from('emergency_switches_usage')
          .select('id')
          .eq('user_id', user.id)
          .eq('routine_id', routineId)
          .eq('used_date', todayString)
          .maybeSingle();

      if (existingUsage != null) {
        print('ℹ️ Emergency switch already used for this routine today');
        return false;
      }

      // Record the switch usage
      final usageData = {
        'id': _uuid.v4(),
        'user_id': user.id,
        'routine_id': routineId,
        'routine_name': routineName,
        'used_date': todayString,
        'reason': reason,
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from('emergency_switches_usage')
          .insert(usageData);

      print('✅ Emergency switch used successfully');
      return true;
    } catch (e) {
      print('❌ Error using emergency switch: $e');
      return false;
    }
  }

  // Purchase emergency switches
  static Future<bool> purchaseEmergencySwitches({
    required String packageType,
    required String stripePaymentIntentId,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      print('💳 Processing emergency switches purchase: $packageType');

      // Get package details
      final package = EmergencySwitchPackage.packages
          .firstWhere((p) => p.id == packageType);

      // Record the purchase
      final purchaseData = {
        'id': _uuid.v4(),
        'user_id': user.id,
        'package_type': packageType,
        'switches_count': package.switchesCount,
        'amount_paid': package.price,
        'stripe_payment_intent_id': stripePaymentIntentId,
        'purchased_at': DateTime.now().toIso8601String(),
        'status': 'completed',
      };

      await _supabase
          .from('emergency_switches_purchases')
          .insert(purchaseData);

      // Update user's emergency switches count
      final currentStats = await getEmergencySwitchStats();
      final newTotal = currentStats.totalSwitches + package.switchesCount;

      await _supabase
          .from('user_profiles')
          .update({'emergency_switches_count': newTotal})
          .eq('user_id', user.id);

      print('✅ Emergency switches purchase completed: +${package.switchesCount} switches');
      return true;
    } catch (e) {
      print('❌ Error processing emergency switches purchase: $e');
      return false;
    }
  }

  // Check if routine can be excused for today
  static Future<bool> canUseEmergencySwitchForRoutine(String routineId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      // Check if user has available switches
      final stats = await getEmergencySwitchStats();
      if (!stats.hasAvailableSwitches) return false;

      // Check if already used for this routine today
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      final existingUsage = await _supabase
          .from('emergency_switches_usage')
          .select('id')
          .eq('user_id', user.id)
          .eq('routine_id', routineId)
          .eq('used_date', todayString)
          .maybeSingle();

      return existingUsage == null;
    } catch (e) {
      print('❌ Error checking emergency switch availability: $e');
      return false;
    }
  }

  // Get emergency switches usage for a specific date range
  static Future<List<EmergencySwitchUsage>> getUsageHistory({int days = 30}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      final startDate = DateTime.now().subtract(Duration(days: days));

      final response = await _supabase
          .from('emergency_switches_usage')
          .select('*')
          .eq('user_id', user.id)
          .gte('created_at', startDate.toIso8601String())
          .order('created_at', ascending: false);

      return response
          .map((json) => EmergencySwitchUsage.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error fetching usage history: $e');
      return [];
    }
  }

  // Reset emergency switches count (admin function)
  static Future<bool> resetEmergencySwitches({int count = 2}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      await _supabase
          .from('user_profiles')
          .update({'emergency_switches_count': count})
          .eq('user_id', user.id);

      print('✅ Emergency switches reset to $count');
      return true;
    } catch (e) {
      print('❌ Error resetting emergency switches: $e');
      return false;
    }
  }
} 