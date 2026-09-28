import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/food_doodle_background.dart';
import '../widgets/google_sign_in_button.dart';
import '../widgets/nutri_meal_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Validasi ──────────────────────────────────────────
  bool _validateEmail(String value) {
    final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
    if (value.trim().isEmpty) {
      setState(() => _emailError = 'Email tidak boleh kosong.');
      return false;
    }
    if (!emailRegex.hasMatch(value.trim())) {
      setState(() =>
          _emailError = 'Format email tidak valid (contoh : nama@gmail.com)');
      return false;
    }
    setState(() => _emailError = null);
    return true;
  }

  bool _validatePassword(String value) {
    if (value.isEmpty) {
      setState(() => _passwordError = 'Password tidak boleh kosong.');
      return false;
    }
    if (value.length < 6) {
      setState(() => _passwordError = 'Password minimal 6 karakter.');
      return false;
    }
    setState(() => _passwordError = null);
    return true;
  }

  // ── Handler ───────────────────────────────────────────
  void _handleLogin() {
    final emailOk = _validateEmail(_emailController.text);
    final passOk = _validatePassword(_passwordController.text);
    if (!emailOk || !passOk) return;

    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Login berhasil! Selamat datang di Nutri Meal.',
            style: AppTextStyles.inputText.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    });
  }



  void _handleRegister() {
    Navigator.pushNamed(context, '/register');
  }

  void _handleForgotPassword() {
    // Feedback dihapus sesuai permintaan
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double topSectionHeight = screenSize.height * 0.36;

    return Scaffold(
      backgroundColor: AppColors.mintBackground,
      body: Stack(
        children: [
          // Background Doodle Pattern
          const Positioned.fill(
            child: FoodDoodleBackground(fillFull: true),
          ),

          // Main Layout Content
          SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Top Brand Logo Area
                          SizedBox(
                            height: topSectionHeight,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: const NutriMealLogo(
                                  fontSize: 34,
                                  hasShadow: true,
                                ),
                              ),
                            ),
                          ),

                          // White Bottom Card Container
                          Expanded(
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
                                    color:
                                        Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 20,
                                    offset: const Offset(0, -6),
                                  ),
                                ],
                              ),
                              padding:
                                  const EdgeInsets.fromLTRB(28, 28, 28, 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  // Headline
                                  Text(
                                    'Kemewahan Rasa Dalam\nSetiap Asupan Nutrisi',
                                    style: AppTextStyles.loginTitle,
                                  ),
                                  const SizedBox(height: 24),

                                  // Email Input
                                  CustomTextField(
                                    label: 'EMAIL',
                                    hintText: 'Masukan email',
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    errorText: _emailError,
                                    onChanged: (val) {
                                      if (_emailError != null)
                                        _validateEmail(val);
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Password Input
                                  CustomTextField(
                                    label: 'PASSWORD',
                                    hintText: '****',
                                    controller: _passwordController,
                                    obscureText: true,
                                    enablePasswordToggle: true,
                                    textInputAction: TextInputAction.done,
                                    errorText: _passwordError,
                                    onChanged: (val) {
                                      if (_passwordError != null)
                                        _validatePassword(val);
                                    },
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
                                              style: AppTextStyles
                                                  .footerGreenLink,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Login Button
                                  _isLoading
                                      ? Center(
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

                                  // Google Sign In (Display only)
                                  const Center(
                                    child: GoogleSignInButton(),
                                  ),

                                  // Bottom spacing
                                  SizedBox(
                                    height:
                                        MediaQuery.of(context).padding.bottom +
                                            24,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
