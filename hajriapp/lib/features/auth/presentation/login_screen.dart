import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/constants/app_colors.dart';

import '../providers/auth_providers.dart';
import 'package:hajriapp/l10n/app_localizations.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSignIn = useState(true);
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final nameController = useTextEditingController();
    final companyController = useTextEditingController();
    final phoneController = useTextEditingController();
    
    final isLoading = useState(false);
    final errorMessage = useState<String?>(null);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    void handleAuth() async {
      errorMessage.value = null;
      isLoading.value = true;
      final messenger = ScaffoldMessenger.of(context);
      final successText = AppLocalizations.of(context)!.saveSuccess;

      try {
        if (isSignIn.value) {
          await ref.read(authControllerProvider.notifier).signIn(
                emailController.text.trim(),
                passwordController.text.trim(),
              );
        } else {
          await ref.read(authControllerProvider.notifier).signUp(
                emailController.text.trim(),
                passwordController.text.trim(),
                nameController.text.trim(),
                companyController.text.trim(),
                phoneController.text.trim(),
              );
          messenger.showSnackBar(
            SnackBar(
              content: Text('$successText - Sign up complete!'),
              backgroundColor: AppColors.success,
            ),
          );
          isSignIn.value = true;
        }
      } catch (e) {
        errorMessage.value = e.toString().replaceAll('Exception: ', '');
      } finally {
        isLoading.value = false;
      }
    }

    void handleSandbox() async {
      errorMessage.value = null;
      isLoading.value = true;
      try {
        await ref.read(authControllerProvider.notifier).signInSandbox();
      } catch (e) {
        errorMessage.value = e.toString();
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF09090B), const Color(0xFF18181B)]
                : [const Color(0xFFFAFAFA), const Color(0xFFF4F4F5)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                  side: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1,
                  ),
                ),
                color: isDark ? AppColors.darkSurface : Colors.white,
                elevation: isDark ? 0 : 4,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // App logo icon
                      Center(
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withAlpha(76),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'H',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ).animate().scale(delay: 100.ms, duration: 300.ms),
                      const SizedBox(height: 16),
                      
                      // Heading
                      Text(
                        isSignIn.value 
                            ? 'Sign in to Rojgar' 
                            : 'Create Contractor Account',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isSignIn.value
                            ? 'Access your digital attendance cards'
                            : 'Manage your site labor force and wages',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),

                      if (errorMessage.value != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.errorBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.error.withAlpha(76)),
                          ),
                          child: Text(
                            errorMessage.value!,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Form Fields
                      if (!isSignIn.value) ...[
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person_outline),
                            hintText: 'Full Name',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: companyController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.business_outlined),
                            hintText: 'Company Name',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.phone_outlined),
                            hintText: 'Phone Number',
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.mail_outline),
                          hintText: 'Email Address',
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.lock_outline),
                          hintText: 'Password',
                        ),
                      ),
                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: isLoading.value ? null : handleAuth,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : Text(
                                isSignIn.value ? 'Sign In' : 'Register Contractor',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),

                      // Toggle Auth Mode
                      GestureDetector(
                        onTap: () {
                          isSignIn.value = !isSignIn.value;
                        },
                        child: Center(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                fontSize: 13,
                              ),
                              children: [
                                TextSpan(
                                  text: isSignIn.value
                                      ? "Don't have an account? "
                                      : "Already have an account? ",
                                ),
                                TextSpan(
                                  text: isSignIn.value ? "Sign Up" : "Sign In",
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Divider
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'OR SANDBOX',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Sandbox Mode Button
                      OutlinedButton(
                        onPressed: isLoading.value ? null : handleSandbox,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: BorderSide(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: Text(
                          'Explore with Sandbox Demo Mode',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0.0),
        ),
      ),
    );
  }
}
