import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/emergency_switches.dart';
import '../../../core/services/emergency_switches_service.dart';

// Provider for emergency switches stats
final emergencySwitchStatsProvider = FutureProvider<EmergencySwitchStats>((ref) async {
  return await EmergencySwitchesService.getEmergencySwitchStats();
});

// Provider for emergency switches packages
final emergencySwitchPackagesProvider = Provider<List<EmergencySwitchPackage>>((ref) {
  return EmergencySwitchPackage.packages;
});

// Provider for checking if a routine can use emergency switch
final canUseEmergencySwitchProvider = FutureProvider.family<bool, String>((ref, routineId) async {
  return await EmergencySwitchesService.canUseEmergencySwitchForRoutine(routineId);
});

// Provider for usage history
final emergencySwitchUsageHistoryProvider = FutureProvider<List<EmergencySwitchUsage>>((ref) async {
  return await EmergencySwitchesService.getUsageHistory();
});

// State notifier for emergency switches operations
class EmergencySwitchesNotifier extends StateNotifier<AsyncValue<EmergencySwitchStats>> {
  EmergencySwitchesNotifier() : super(const AsyncValue.loading()) {
    loadStats();
  }

  Future<void> loadStats() async {
    try {
      state = const AsyncValue.loading();
      final stats = await EmergencySwitchesService.getEmergencySwitchStats();
      state = AsyncValue.data(stats);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<bool> useEmergencySwitch({
    required String routineId,
    required String routineName,
    String reason = 'emergency_excuse',
  }) async {
    try {
      final success = await EmergencySwitchesService.useEmergencySwitch(
        routineId: routineId,
        routineName: routineName,
        reason: reason,
      );

      if (success) {
        // Reload stats after using a switch
        await loadStats();
      }

      return success;
    } catch (e) {
      print('Error using emergency switch: $e');
      return false;
    }
  }

  Future<bool> purchaseEmergencySwitches({
    required String packageType,
    required String stripePaymentIntentId,
  }) async {
    try {
      final success = await EmergencySwitchesService.purchaseEmergencySwitches(
        packageType: packageType,
        stripePaymentIntentId: stripePaymentIntentId,
      );

      if (success) {
        // Reload stats after purchase
        await loadStats();
      }

      return success;
    } catch (e) {
      print('Error purchasing emergency switches: $e');
      return false;
    }
  }
}

// Provider for the emergency switches notifier
final emergencySwitchesNotifierProvider = StateNotifierProvider<EmergencySwitchesNotifier, AsyncValue<EmergencySwitchStats>>((ref) {
  return EmergencySwitchesNotifier();
}); 