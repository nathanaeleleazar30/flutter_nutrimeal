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

  String? _namaError;
  String? _emailError;
  String? _whatsappError;
  String? _passwordError;
  String? _konfirmasiError;
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

  // ── Validasi ──────────────────────────────────────────
  bool _validateNama(String value) {
    if (value.trim().isEmpty) {
      setState(() => _namaError = 'Nama lengkap tidak boleh kosong.');
      return false;
    }
    if (value.trim().length < 3) {
      setState(() => _namaError = 'Nama minimal 3 karakter.');
      return false;
    }
    setState(() => _namaError = null);
    return true;
  }

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

  bool _validateWhatsapp(String value) {
    if (value.trim().isEmpty) {
      setState(() => _whatsappError = 'Nomor WhatsApp tidak boleh kosong.');
      return false;
    }
    if (value.trim().length < 8) {
      setState(
          () => _whatsappError = 'Nomor WhatsApp minimal 8 digit.');
      return false;
    }
    setState(() => _whatsappError = null);
    return true;
  }

  bool _validatePassword(String value) {
    final hasNumber = RegExp(r'\d').hasMatch(value);
    if (value.isEmpty) {
      setState(() => _passwordError = 'Password tidak boleh kosong.');
      return false;
    }
    if (value.length < 8 || !hasNumber) {
      setState(() => _passwordError =
          'Password minimal 8 karakter dan mengandung angka.');
      return false;
    }
    setState(() => _passwordError = null);
    return true;
  }

  bool _validateKonfirmasi(String value) {
    if (value.isEmpty) {
      setState(
          () => _konfirmasiError = 'Konfirmasi password tidak boleh kosong.');
      return false;
    }
    if (value != _passwordController.text) {
      setState(
          () => _konfirmasiError = 'Password dan konfirmasi tidak cocok.');
      return false;
    }
    setState(() => _konfirmasiError = null);
    return true;
  }

  // ── Handler ───────────────────────────────────────────
  void _handleDaftar() {
    final namaOk = _validateNama(_namaController.text);
    final emailOk = _validateEmail(_emailController.text);
    final waOk = _validateWhatsapp(_whatsappController.text);
    final passOk = _validatePassword(_passwordController.text);
    final konfirmOk = _validateKonfirmasi(_konfirmasiPasswordController.text);

    if (!namaOk || !emailOk || !waOk || !passOk || !konfirmOk) return;

    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar(
          'Pendaftaran berhasil! Silakan masuk.', AppColors.primaryGreen);
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) Navigator.pop(context);
      });
    });
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
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
                                        color: Colors.white
                                            .withValues(alpha: 0.85),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.08),
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
                                // Logo
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
                                children: [
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
                                    errorText: _namaError,
                                    onChanged: (val) {
                                      if (_namaError != null)
                                        _validateNama(val);
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Email
                                  CustomTextField(
                                    label: 'EMAIL',
                                    hintText: 'masukkan email',
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

                                  // Nomor WhatsApp
                                  Text(
                                    'NOMOR WHATSAPP',
                                    style: AppTextStyles.inputLabel,
                                  ),
                                  const SizedBox(height: 8),
                                  AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 200),
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: _whatsappError != null
                                          ? const Color(0xFFFFF5F5)
                                          : AppColors.inputBackground,
                                      borderRadius:
                                          BorderRadius.circular(14),
                                      border: _whatsappError != null
                                          ? Border.all(
                                              color:
                                                  const Color(0xFFEF4444),
                                              width: 1.5)
                                          : Border.all(
                                              color: Colors.transparent,
                                              width: 1.5),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14),
                                          decoration: BoxDecoration(
                                            color: (_whatsappError != null
                                                    ? const Color(0xFFEF4444)
                                                    : AppColors.primaryGreen)
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(14),
                                              bottomLeft:
                                                  Radius.circular(14),
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            '+62',
                                            style: AppTextStyles.inputText
                                                .copyWith(
                                              color: _whatsappError != null
                                                  ? const Color(0xFFEF4444)
                                                  : AppColors.primaryGreen,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 12),
                                            child: TextField(
                                              controller:
                                                  _whatsappController,
                                              keyboardType:
                                                  TextInputType.phone,
                                              textInputAction:
                                                  TextInputAction.next,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                              ],
                                              style:
                                                  AppTextStyles.inputText,
                                              cursorColor:
                                                  _whatsappError != null
                                                      ? const Color(
                                                          0xFFEF4444)
                                                      : AppColors
                                                          .primaryGreen,
                                              onChanged: (val) {
                                                if (_whatsappError != null)
                                                  _validateWhatsapp(val);
                                              },
                                              decoration: InputDecoration(
                                                isDense: true,
                                                contentPadding:
                                                    const EdgeInsets
                                                        .symmetric(
                                                        vertical: 14),
                                                border: InputBorder.none,
                                                hintText: '8XX-XXXX-XXXX',
                                                hintStyle: AppTextStyles
                                                    .inputHint
                                                    .copyWith(
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_whatsappError != null) ...[
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(
                                            Icons.error_outline_rounded,
                                            size: 13,
                                            color: Color(0xFFEF4444)),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            _whatsappError!,
                                            style: AppTextStyles.inputHint
                                                .copyWith(
                                              color:
                                                  const Color(0xFFEF4444),
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 16),

                                  // Password
                                  CustomTextField(
                                    label: 'PASSWORD',
                                    hintText: '****',
                                    controller: _passwordController,
                                    obscureText: true,
                                    enablePasswordToggle: true,
                                    textInputAction: TextInputAction.next,
                                    errorText: _passwordError,
                                    onChanged: (val) {
                                      if (_passwordError != null)
                                        _validatePassword(val);
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Konfirmasi Password
                                  CustomTextField(
                                    label: 'KONFIRMASI PASSWORD',
                                    hintText: '****',
                                    controller:
                                        _konfirmasiPasswordController,
                                    obscureText: true,
                                    enablePasswordToggle: true,
                                    textInputAction: TextInputAction.done,
                                    errorText: _konfirmasiError,
                                    onChanged: (val) {
                                      if (_konfirmasiError != null)
                                        _validateKonfirmasi(val);
                                    },
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
                                          style:
                                              AppTextStyles.footerRegular,
                                          children: [
                                            TextSpan(
                                              text: 'Masuk',
                                              style: AppTextStyles
                                                  .footerGreenLink,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

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
