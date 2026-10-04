import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../widgets/custom_button.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;

  const VerifyEmailScreen({
    super.key,
    this.email = 'aurelrelianrachmad@student.ub.ac.id',
  });

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  bool _isLoading = false;

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _handleConfirm() {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Harap masukkan 4 digit kode verifikasi',
            style: AppTextStyles.inputText.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Verifikasi Berhasil! Silakan buat password baru.',
            style: AppTextStyles.inputText.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      Navigator.popUntil(context, (route) => route.isFirst);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Advanced UI: CustomScrollView with Slivers
            CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 70),

                        // Center Mail Green Circle
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryGreen.withValues(alpha: 0.35),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.mail_outline_rounded,
                            size: 46,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Title
                        Text(
                          'Periksa Email Anda',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.loginTitle.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Subtitle
                        Text(
                          'kami mengirim kode verifikasi ke:',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.screenSubtitle,
                        ),
                        const SizedBox(height: 4),

                        // Target Email
                        Text(
                          widget.email.isNotEmpty
                              ? widget.email
                              : 'aurelrelianrachmad@student.ub.ac.id',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.inputText.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Advanced UI: GridView for 4 OTP Digit Boxes
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 260),
                          child: GridView.count(
                            crossAxisCount: 4,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: List.generate(4, (index) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: AppColors.otpBoxBg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _controllers[index].text.isNotEmpty
                                        ? AppColors.primaryGreen
                                        : AppColors.otpBoxBorder,
                                    width: 1.4,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: TextField(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  maxLength: 1,
                                  style: AppTextStyles.otpDigit,
                                  cursorColor: AppColors.primaryGreen,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: const InputDecoration(
                                    counterText: '',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                  ),
                                  onChanged: (value) {
                                    setState(() {});
                                    if (value.isNotEmpty) {
                                      if (index < 3) {
                                        _focusNodes[index + 1].requestFocus();
                                      } else {
                                        _focusNodes[index].unfocus();
                                        _handleConfirm();
                                      }
                                    } else {
                                      if (index > 0) {
                                        _focusNodes[index - 1].requestFocus();
                                      }
                                    }
                                  },
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Konfirmasi Button
                        _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryGreen,
                                ),
                              )
                            : CustomButton(
                                text: 'KONFIRMASI',
                                showArrow: false,
                                onPressed: _handleConfirm,
                              ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Top Circular Back Button
            Positioned(
              top: 12,
              left: 16,
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
          ],
        ),
      ),
    );
  }
}
