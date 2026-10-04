import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class RegisterScreen extends StatefulWidget {
  final bool initialShowErrors;

  const RegisterScreen({
    super.key,
    this.initialShowErrors = false,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _konfirmasiPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialShowErrors) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AuthController>().setValidationErrorsManual(
          emailErr:
              'email tidak boleh kosong dan harus menggunakan @student.ub.ac.id',
          passwordErr:
              'Password minimal 8 karakter mengandung angka',
        );
      });
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _whatsappController.dispose();
    _passwordController.dispose();
    _konfirmasiPasswordController.dispose();
    super.dispose();
  }

  void _handleDaftar() async {
    final authController = context.read<AuthController>();
    final success = await authController.register(
      nama: _namaController.text,
      email: _emailController.text,
      whatsapp: _whatsappController.text,
      password: _passwordController.text,
      konfirmasiPassword: _konfirmasiPasswordController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pendaftaran berhasil! Silakan masuk.',
            style: AppTextStyles.inputText.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  void _handleGoogleRegister() {
    GoogleAccountSheet.show(context, onAccountSelected: () {
      final user = context.read<AuthController>().selectedGoogleAccount;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Berhasil mendaftar dengan ${user?.name}',
            style: AppTextStyles.inputText.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final Size screenSize = MediaQuery.of(context).size;
    final double topSectionHeight = screenSize.height * 0.26;

    return Scaffold(
      backgroundColor: AppColors.mintBackground,
      body: Stack(
        children: [
          // Background Doodle Pattern
          const Positioned.fill(
            child: FoodDoodleBackground(fillFull: true),
          ),

          // Main Layout using CustomScrollView
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                // Top Brand & Back Button Header
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: topSectionHeight,
                    child: Stack(
                      children: [
                        // Circular Back Button
                        Positioned(
                          top: 8,
                          left: 14,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => Navigator.pop(context),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD1D5DB),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.chevron_left_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Logo Center
                        const Center(
                          child: NutriMealLogo(
                            fontSize: 34,
                            hasShadow: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // White Bottom Form Card
                SliverToBoxAdapter(
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
                      children: [
                        // Exact Headline from Screenshot 2
                        Text(
                          'Mulai Perjalanan Sehatmu\nBersama NutriMeal',
                          style: AppTextStyles.loginTitle,
                        ),
                        const SizedBox(height: 22),

                        // Nama Lengkap
                        CustomTextField(
                          label: 'NAMA LENGKAP',
                          hintText: 'Masukkan Nama Lengkap',
                          controller: _namaController,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          errorText: authController.namaError,
                        ),
                        const SizedBox(height: 16),

                        // Email
                        CustomTextField(
                          label: 'EMAIL',
                          hintText: 'masukkan email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          errorText: authController.emailError,
                        ),
                        const SizedBox(height: 16),

                        // Nomor WhatsApp
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NOMOR WHATSAPP',
                              style: AppTextStyles.inputLabel,
                            ),
                            const SizedBox(height: 7),
                            Container(
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.inputBackground,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16, right: 8),
                                    child: Text(
                                      '+62  |',
                                      style: AppTextStyles.inputText.copyWith(
                                        color: AppColors.textDark,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: _whatsappController,
                                      keyboardType: TextInputType.phone,
                                      textInputAction: TextInputAction.next,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      style: AppTextStyles.inputText,
                                      cursorColor: AppColors.primaryGreen,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(vertical: 14),
                                        border: InputBorder.none,
                                        hintText: '',
                                        hintStyle: AppTextStyles.inputHint,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (authController.whatsappError != null) ...[
                              const SizedBox(height: 5),
                              Text(
                                authController.whatsappError!,
                                style: AppTextStyles.errorText,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Password
                        CustomTextField(
                          label: 'PASSWORD',
                          hintText: '••••••',
                          controller: _passwordController,
                          obscureText: true,
                          enablePasswordToggle: true,
                          textInputAction: TextInputAction.next,
                          errorText: authController.passwordError,
                        ),
                        const SizedBox(height: 16),

                        // Konfirmasi Password
                        CustomTextField(
                          label: 'KONFIRMASI PASSWORD',
                          hintText: '••••••',
                          controller: _konfirmasiPasswordController,
                          obscureText: true,
                          enablePasswordToggle: true,
                          textInputAction: TextInputAction.done,
                          errorText: authController.konfirmasiPasswordError,
                          onSubmitted: (_) => _handleDaftar(),
                        ),
                        const SizedBox(height: 24),

                        // Daftar Button
                        authController.isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryGreen,
                                ),
                              )
                            : CustomButton(
                                text: 'Daftar',
                                showArrow: true,
                                onPressed: _handleDaftar,
                              ),
                        const SizedBox(height: 16),

                        // Sudah mempunyai akun? Masuk
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text.rich(
                              TextSpan(
                                text: 'Sudah mempunyai akun? ',
                                style: AppTextStyles.footerRegular,
                                children: [
                                  TextSpan(
                                    text: 'Masuk',
                                    style: AppTextStyles.footerGreenLink,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Atau masuk dengan
                        Center(
                          child: Text(
                            'Atau masuk dengan',
                            style: AppTextStyles.socialDivider,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Google Sign In Button
                        Center(
                          child: GoogleSignInButton(
                            onTap: _handleGoogleRegister,
                          ),
                        ),

                        // Bottom space
                        SizedBox(
                          height: MediaQuery.of(context).padding.bottom + 28,
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
