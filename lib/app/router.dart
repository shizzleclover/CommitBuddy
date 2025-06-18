import 'package:flutter/material.dart';
import '../features/auth/presentation/sign_up_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/onboarding/presentation/splash_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/home/presentation/main_app_wrapper.dart';
import '../features/routine/presentation/create_routine_screen.dart';
import '../features/routine/presentation/routine_runner_screen.dart';
import '../features/buddy/presentation/buddy_screen.dart';
import '../features/buddy/presentation/invite_buddy_screen.dart';
import '../features/buddy/presentation/buddy_profile_screen.dart';
import '../features/subscriptions/presentation/subscription_screen.dart';
import '../features/subscriptions/presentation/upgrade_to_premium_screen.dart';
import '../features/subscriptions/presentation/payment_screen.dart';
import '../features/subscriptions/data/subscription_model.dart';
import '../data/models/routine.dart';
import '../data/models/buddy.dart';

class AppRouter {
  // Route names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signUp = '/signup';
  static const String home = '/home';
  static const String createRoutine = '/create-routine';
  static const String routineRunner = '/routine-runner';
  static const String buddyScreen = '/buddy';
  static const String inviteBuddy = '/invite-buddy';
  static const String buddyProfile = '/buddy-profile';
  static const String subscription = '/subscription';
  static const String upgradeToPremium = '/upgrade-to-premium';
  static const String payment = '/payment';

  // Generate routes
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signUp:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const MainAppWrapper());
      case createRoutine:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => CreateRoutineScreen(
            editingRoutine: args?['editingRoutine'] as CreatedRoutine?,
          ),
        );
      case routineRunner:
        final routine = settings.arguments as CreatedRoutine;
        return MaterialPageRoute(
          builder: (_) => RoutineRunnerScreen(routine: routine),
        );
      case buddyScreen:
        return MaterialPageRoute(builder: (_) => const BuddyScreen());
      case inviteBuddy:
        return MaterialPageRoute(builder: (_) => const InviteBuddyScreen());
      case buddyProfile:
        final buddy = settings.arguments as Buddy;
        return MaterialPageRoute(
          builder: (_) => BuddyProfileScreen(buddy: buddy),
        );
      case subscription:
        return MaterialPageRoute(builder: (_) => const SubscriptionScreen());
      case upgradeToPremium:
        return MaterialPageRoute(builder: (_) => const UpgradeToPremiumScreen());
      case payment:
        final args = settings.arguments as Map<String, dynamic>;
        final plan = args['plan'] as SubscriptionPlanDetails;
        final isYearly = args['isYearly'] as bool;
        return MaterialPageRoute(
          builder: (_) => PaymentScreen(plan: plan, isYearly: isYearly),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Route not found'),
            ),
          ),
        );
    }
  }

  // Navigation helpers
  static void pushNamed(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  static void pushReplacementNamed(BuildContext context, String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }

  static void pushNamedAndClearStack(BuildContext context, String routeName) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
    );
  }

  static void pop(BuildContext context) {
    Navigator.pop(context);
  }
} 