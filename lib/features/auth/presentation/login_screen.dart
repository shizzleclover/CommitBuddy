import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_texts.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../app/router.dart';
import '../logic/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppTexts.pleaseEnterEmail;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return AppTexts.invalidEmail;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppTexts.pleaseEnterPassword;
    }
    return null;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    // Clear any previous auth errors
    ref.read(authProvider.notifier).clearError();

    final success = await ref.read(authProvider.notifier).signInWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      AppRouter.pushNamedAndClearStack(context, AppRouter.home);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    // Clear any previous auth errors
    ref.read(authProvider.notifier).clearError();

    final success = await ref.read(authProvider.notifier).signInWithGoogle();

    if (success && mounted) {
      AppRouter.pushNamedAndClearStack(context, AppRouter.home);
    }
  }

  void _handleForgotPassword() {
    // TODO: Navigate to forgot password screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Forgot password feature coming soon!'),
      ),
    );
  }

  void _navigateToSignUp() {
    AppRouter.pushNamed(context, AppRouter.signUp);
  }

  void _handleExploreFirst() {
    // Navigate to home in guest mode
    AppRouter.pushNamedAndClearStack(context, AppRouter.home);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final error = authState.error;

    // Show error snackbar if there's an error
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.destructive,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundSage,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      AppTexts.appName,
                      style: AppTextStyles.appTitle,
                    ),
                    const SizedBox(height: 32),

                    // Illustration placeholder
                    Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.mediumGray,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              size: 48,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppTexts.checklistIllustration,
                              style: AppTextStyles.placeholderText,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Blue Banner
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  AppTexts.buildDiscipline,
                  style: AppTextStyles.bannerText,
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 8),

              // Tagline
              Text(
                AppTexts.disciplineIsFreedom,
                style: AppTextStyles.taglineText,
              ),

              const SizedBox(height: 32),

              // Form Container
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email Field
                      CustomTextField(
                        labelText: AppTexts.email,
                        hintText: AppTexts.enterEmail,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      CustomTextField(
                        labelText: AppTexts.password,
                        hintText: AppTexts.enterPassword,
                        controller: _passwordController,
                        obscureText: true,
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: 8),

                      // Helper text
                      Text(
                        AppTexts.privacyMessage,
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: 24),

                      // Forgot Password Link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: isLoading ? null : _handleForgotPassword,
                          child: Text(
                            'Forgot Password?',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Login Button
                      CustomButton(
                        text: AppTexts.logIn,
                        onPressed: isLoading ? null : _handleLogin,
                        isLoading: isLoading,
                        child: isLoading 
                          ? const SpinKitThreeBounce(
                              color: AppColors.white,
                              size: 20,
                            )
                          : null,
                      ),
                      const SizedBox(height: 16),

                      // Divider
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'or',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Google Sign In Button
                      Container(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: isLoading ? null : _handleGoogleSignIn,
                          icon: isLoading 
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: SpinKitRing(
                                  color: AppColors.primaryBlue,
                                  size: 20,
                                  lineWidth: 2,
                                ),
                              )
                            : Icon(
                                PhosphorIcons.googleLogo(),
                                size: 20,
                              ),
                          label: Text(
                            'Continue with Google',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.white,
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(
                              color: AppColors.borderColor,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Explore First Button
                      CustomButton(
                        text: AppTexts.exploreFirst,
                        type: ButtonType.text,
                        textColor: AppColors.textSecondary,
                        onPressed: isLoading ? null : _handleExploreFirst,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Sign Up Link
              GestureDetector(
                onTap: _navigateToSignUp,
                child: RichText(
                  text: TextSpan(
                    text: AppTexts.dontHaveAccount,
                    style: AppTextStyles.bodyMedium,
                    children: [
                      TextSpan(
                        text: AppTexts.signUpLink,
                        style: AppTextStyles.linkText,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
} 