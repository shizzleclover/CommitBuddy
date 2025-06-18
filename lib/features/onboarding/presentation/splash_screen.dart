import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_texts.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/cache_service.dart';
import '../../../app/router.dart';
import '../../auth/logic/auth_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkAuthAndNavigate();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Minimum splash screen duration
    await Future.delayed(const Duration(milliseconds: 2000));
    
    if (!mounted) return;

    try {
      // Check if user is authenticated
      final authState = ref.read(authProvider);
      final isFirstLaunch = CacheService.isFirstLaunch();
      final isOnboardingCompleted = CacheService.isOnboardingCompleted();

      if (authState.isAuthenticated && authState.user != null) {
        // User is logged in, go to home
        if (mounted) {
          AppRouter.pushReplacementNamed(context, AppRouter.home);
        }
      } else if (isFirstLaunch || !isOnboardingCompleted) {
        // First time user, show onboarding
        if (mounted) {
          AppRouter.pushReplacementNamed(context, AppRouter.onboarding);
        }
      } else {
        // Returning user but not logged in, go to login
        if (mounted) {
          AppRouter.pushReplacementNamed(context, AppRouter.login);
        }
      }
    } catch (e) {
      // On error, default to onboarding
      if (mounted) {
        AppRouter.pushReplacementNamed(context, AppRouter.onboarding);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryBlue,
              AppColors.darkBlue,
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo with scale and slide animation
                            Transform.translate(
                              offset: Offset(0, _slideAnimation.value),
                              child: ScaleTransition(
                                scale: _scaleAnimation,
                                child: Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(35),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 30,
                                        offset: const Offset(0, 15),
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.handshake_outlined,
                                    size: 70,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            
                            // App Name with slide animation
                            Transform.translate(
                              offset: Offset(0, _slideAnimation.value * 0.8),
                              child: Text(
                                AppTexts.appName,
                                style: AppTextStyles.displayMedium.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // Tagline with slide animation
                            Transform.translate(
                              offset: Offset(0, _slideAnimation.value * 0.6),
                              child: Text(
                                AppTexts.appTagline,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.white.withOpacity(0.9),
                                  fontStyle: FontStyle.italic,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Loading section at bottom
                    Padding(
                      padding: const EdgeInsets.only(bottom: 60),
                      child: Column(
                        children: [
                          // Loading spinner with SpinKit
                          const SpinKitThreeBounce(
                            color: AppColors.white,
                            size: 30,
                          ),
                          const SizedBox(height: 20),
                          
                          // Loading text
                          Text(
                            authState.isLoading 
                                ? 'Signing you in...' 
                                : 'Initializing...',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
} 