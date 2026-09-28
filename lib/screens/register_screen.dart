import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/food_doodle_background.dart';
import '../widgets/google_sign_in_button.dart';
import '../widgets/nutri_meal_logo.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

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

  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _whatsappController.dispose();
    _passwordController.dispose();
    _konfirmasiPasswordController.dispose();
    super.dispose();
  }

  void _handleDaftar() {
    final nama = _namaController.text.trim();
    final email = _emailController.text.trim();
    final whatsapp = _whatsappController.text.trim();
    final password = _passwordController.text;
    final konfirmasi = _konfirmasiPasswordController.text;

    if (nama.isEmpty ||
        email.isEmpty ||
        whatsapp.isEmpty ||
        password.isEmpty ||
        konfirmasi.isEmpty) {
      _showSnackBar('Harap isi semua kolom terlebih dahulu.',
          AppColors.textDark);
      return;
    }

    if (password != konfirmasi) {
      _showSnackBar('Password dan konfirmasi password tidak cocok.',
          Colors.redAccent);
      return;
    }

    if (password.length < 6) {
      _showSnackBar('Password minimal 6 karakter.', Colors.redAccent);
      return;
    }

    setState(() => _isLoading = true);

    // Simulasi proses daftar
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar('Pendaftaran berhasil! Silakan masuk.', AppColors.primaryGreen);
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) Navigator.pop(context);
      });
    });
  }

  void _handleGoogleRegister() {
    _showSnackBar('Daftar dengan Akun Google...', AppColors.textDark);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.inputText.copyWith(color: Colors.white),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double topSectionHeight = screenSize.height * 0.28;

    return Scaffold(
      backgroundColor: AppColors.mintBackground,
      body: Stack(
        children: [
          // Background Doodle Pattern
          const Positioned.fill(
            child: FoodDoodleBackground(fillFull: true),
          ),

          // Main Layout
          SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Top Brand + Back Button
                          SizedBox(
                            height: topSectionHeight,
                            child: Stack(
                              children: [
                                // Back button
                                Positioned(
                                  top: 8,
                                  left: 12,
                                  child: IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.85),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.08),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        size: 18,
                                        color: AppColors.primaryGreen,
                                      ),
                                    ),
                                  ),
                                ),
                                // Logo center
                                const Center(
                                  child: NutriMealLogo(
                                    fontSize: 34,
                                    hasShadow: true,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // White Bottom Card
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
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 20,
                                    offset: const Offset(0, -6),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Headline
                                  Text(
                                    'Bergabung Bersama',
                                    style: AppTextStyles.loginTitle,
                                  ),
                                  const SizedBox(height: 24),

                                  // Nama Lengkap
                                  CustomTextField(
                                    label: 'NAMA LENGKAP',
                                    hintText: 'Masukan nama lengkap',
                                    controller: _namaController,
                                    keyboardType: TextInputType.name,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 16),

                                  // Email
                                  CustomTextField(
                                    label: 'EMAIL',
                                    hintText: 'masukkan email',
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 16),

                                  // Nomor WhatsApp
                                  Text(
                                    'NOMOR WHATSAPP',
                                    style: AppTextStyles.inputLabel,
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: AppColors.inputBackground,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Row(
                                      children: [
                                        // Prefix +62
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryGreen
                                                .withValues(alpha: 0.1),
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(14),
                                              bottomLeft: Radius.circular(14),
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            '+62',
                                            style: AppTextStyles.inputText
                                                .copyWith(
                                              color: AppColors.primaryGreen,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        // Input nomor
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12),
                                            child: TextField(
                                              controller: _whatsappController,
                                              keyboardType: TextInputType.phone,
                                              textInputAction:
                                                  TextInputAction.next,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                              ],
                                              style: AppTextStyles.inputText,
                                              cursorColor:
                                                  AppColors.primaryGreen,
                                              decoration: InputDecoration(
                                                isDense: true,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 14),
                                                border: InputBorder.none,
                                                hintText: '8xx-xxxx-xxxx',
                                                hintStyle:
                                                    AppTextStyles.inputHint,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Password
                                  CustomTextField(
                                    label: 'PASSWORD',
                                    hintText: '****',
                                    controller: _passwordController,
                                    obscureText: true,
                                    enablePasswordToggle: true,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 16),

                                  // Konfirmasi Password
                                  CustomTextField(
                                    label: 'KONFIRMASI PASSWORD',
                                    hintText: '****',
                                    controller: _konfirmasiPasswordController,
                                    obscureText: true,
                                    enablePasswordToggle: true,
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) => _handleDaftar(),
                                  ),
                                  const SizedBox(height: 24),

                                  // Daftar Button
                                  _isLoading
                                      ? Center(
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

                                  // Sudah punya akun
                                  Center(
                                    child: GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: Text.rich(
                                        TextSpan(
                                          text: 'Sudah mempunyai akun?  ',
                                          style: AppTextStyles.footerRegular,
                                          children: [
                                            TextSpan(
                                              text: 'Masuk',
                                              style:
                                                  AppTextStyles.footerGreenLink,
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

                                  // Google
                                  Center(
                                    child: GoogleSignInButton(
                                      onTap: _handleGoogleRegister,
                                    ),
                                  ),

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
