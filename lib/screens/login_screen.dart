import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/food_doodle_background.dart';
import '../widgets/google_account_sheet.dart';
import '../widgets/google_sign_in_button.dart';
import '../widgets/nutri_meal_logo.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final authController = context.read<AuthController>();
    final email = _emailController.text;
    final password = _passwordController.text;

    final success = await authController.login(email, password);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Login berhasil! Selamat datang di NutriMeal.',
            style: AppTextStyles.inputText.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _handleGoogleLogin() {
    GoogleAccountSheet.show(context, onAccountSelected: () {
      final user = context.read<AuthController>().selectedGoogleAccount;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Berhasil masuk sebagai ${user?.name}',
            style: AppTextStyles.inputText.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    });
  }

  void _handleRegister() {
    context.read<AuthController>().clearErrors();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  void _handleForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final Size screenSize = MediaQuery.of(context).size;
    final double topSectionHeight = screenSize.height * 0.35;

    return Scaffold(
      backgroundColor: AppColors.mintBackground,
      body: Stack(
        children: [
          // Background Doodle Pattern
          const Positioned.fill(
            child: FoodDoodleBackground(fillFull: true),
          ),

          // Main Scrollable Area using CustomScrollView
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                // Top Brand Logo Area
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: topSectionHeight,
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 18),
                        child: NutriMealLogo(
                          fontSize: 34,
                          hasShadow: true,
                        ),
                      ),
                    ),
                  ),
                ),

                // White Bottom Card Container
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, -6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // Exact Headline from Screenshot
                        Text(
                          'Nikmati Lezatnya Hidangan,\nSehatnya Nutrisi',
                          style: AppTextStyles.loginTitle,
                        ),
                        const SizedBox(height: 24),

                        // Email Input
                        CustomTextField(
                          label: 'EMAIL',
                          hintText: 'Masukkan Email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          errorText: authController.emailError,
                        ),
                        const SizedBox(height: 16),

                        // Password Input
                        CustomTextField(
                          label: 'PASSWORD',
                          hintText: '••••••',
                          controller: _passwordController,
                          obscureText: true,
                          enablePasswordToggle: true,
                          textInputAction: TextInputAction.done,
                          errorText: authController.passwordError,
                          onSubmitted: (_) => _handleLogin(),
                        ),
                        const SizedBox(height: 12),

                        // Register Link
                        Center(
                          child: GestureDetector(
                            onTap: _handleRegister,
                            child: Text.rich(
                              TextSpan(
                                text: 'Belum punya akun? ',
                                style: AppTextStyles.footerRegular,
                                children: [
                                  TextSpan(
                                    text: 'Daftar disini',
                                    style: AppTextStyles.footerGreenLink,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Login Button
                        authController.isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryGreen,
                                ),
                              )
                            : CustomButton(
                                text: 'MASUK',
                                showArrow: true,
                                onPressed: _handleLogin,
                              ),
                        const SizedBox(height: 14),

                        // Forgot Password Link
                        Center(
                          child: GestureDetector(
                            onTap: _handleForgotPassword,
                            child: Text(
                              'Lupa Password?',
                              style: AppTextStyles.forgotPassword,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Divider Label
                        Center(
                          child: Text(
                            'Atau masuk dengan',
                            style: AppTextStyles.socialDivider,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Google Sign In
                        Center(
                          child: GoogleSignInButton(
                            onTap: _handleGoogleLogin,
                          ),
                        ),

                        // Bottom spacing for comfortable scroll/padding
                        SizedBox(
                          height: MediaQuery.of(context).padding.bottom + 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
