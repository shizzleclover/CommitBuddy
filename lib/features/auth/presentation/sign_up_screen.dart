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

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return AppTexts.pleaseEnterName;
    }
    if (value.length < 2) {
      return AppTexts.nameTooShort;
    }
    return null;
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
    if (value.length < 8) {
      return AppTexts.passwordTooShort;
    }
    return null;
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    // Clear any previous auth errors
    ref.read(authProvider.notifier).clearError();

    final success = await ref.read(authProvider.notifier).signUpWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      displayName: _nameController.text.trim(),
      username: _nameController.text.trim().toLowerCase().replaceAll(' ', '_'),
    );

    if (success && mounted) {
      final authState = ref.read(authProvider);
      
      if (authState.isAuthenticated && authState.user != null) {
        // User is immediately signed in (email confirmation disabled)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully! Welcome to CommitBuddy!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Navigate to home
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          AppRouter.pushNamedAndClearStack(context, AppRouter.home);
        }
      } else {
        // User created but needs email confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created! Please check your email to verify your account before signing in.'),
            backgroundColor: AppColors.info,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 5),
          ),
        );
        
        // Navigate to login screen
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          AppRouter.pushReplacementNamed(context, AppRouter.login);
        }
      }
    }
  }

  Future<void> _handleGoogleSignUp() async {
    // Clear any previous auth errors
    ref.read(authProvider.notifier).clearError();

    final success = await ref.read(authProvider.notifier).signInWithGoogle();

    if (success && mounted) {
      AppRouter.pushNamedAndClearStack(context, AppRouter.home);
    }
  }

  void _navigateToLogin() {
    AppRouter.pushReplacementNamed(context, AppRouter.login);
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
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
          ),
          onPressed: () => AppRouter.pop(context),
        ),
        title: Text(
          AppTexts.signUp,
          style: AppTextStyles.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Illustration placeholder
                Container(
                  width: double.infinity,
                  height: 200,
                  margin: const EdgeInsets.only(bottom: 32),
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
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
                          Icons.people_outline,
                          size: 48,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppTexts.illustrationPlaceholder,
                          style: AppTextStyles.placeholderText,
                        ),
                      ],
                    ),
                  ),
                ),

                // Name Field
                CustomTextField(
                  labelText: AppTexts.name,
                  hintText: AppTexts.enterUsername,
                  controller: _nameController,
                  validator: _validateName,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 20),

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
                const SizedBox(height: 32),

                // Sign Up Button
                CustomButton(
                  text: AppTexts.signUp,
                  onPressed: isLoading ? null : _handleSignUp,
                  isLoading: isLoading,
                ),
                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.borderColor)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppColors.borderColor)),
                  ],
                ),
                const SizedBox(height: 24),

                // Google Sign Up Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isLoading ? null : _handleGoogleSignUp,
                    icon: isLoading
                        ? const SpinKitThreeBounce(
                            color: AppColors.textPrimary,
                            size: 20,
                          )
                        : PhosphorIcon(
                            PhosphorIcons.googleLogo(),
                            color: AppColors.textPrimary,
                            size: 20,
                          ),
                    label: Text(
                      'Continue with Google',
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Debug Button (Temporary)
                if (true) // Set to false to hide in production
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ElevatedButton(
                      onPressed: () async {
                        print('🧪 Debug: Testing direct signup...');
                        try {
                          final response = await ref.read(authProvider.notifier).signUpWithEmail(
                            email: 'test@example.com',
                            password: 'testpassword123',
                            displayName: 'Test User',
                            username: 'testuser',
                          );
                          print('🧪 Debug: Signup result = $response');
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Debug: Signup result = $response'),
                              backgroundColor: response ? AppColors.success : AppColors.destructive,
                            ),
                          );
                        } catch (e) {
                          print('🧪 Debug: Signup error = $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Debug: Error = $e'),
                              backgroundColor: AppColors.destructive,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('🧪 Debug Test Signup'),
                    ),
                  ),

                // Login Link
                Center(
                  child: GestureDetector(
                    onTap: _navigateToLogin,
                    child: RichText(
                      text: TextSpan(
                        text: AppTexts.alreadyHaveAccount,
                        style: AppTextStyles.bodyMedium,
                        children: [
                          TextSpan(
                            text: AppTexts.logInLink,
                            style: AppTextStyles.linkText,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 