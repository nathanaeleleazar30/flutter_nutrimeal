import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/menu_controller.dart';
import '../../core/constants/app_colors.dart';

class VoucherPromoScreen extends StatefulWidget {
  const VoucherPromoScreen({super.key});

  @override
  State<VoucherPromoScreen> createState() => _VoucherPromoScreenState();
}

class _VoucherPromoScreenState extends State<VoucherPromoScreen> {
  final TextEditingController _inputController = TextEditingController();
  bool _freeShippingSelected = true;
  int _selectedDiscountIndex = 1; // 0: 10%, 1: 15k (terpilih di screenshot), 2: 30%, 3: Cashback 20%

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Header with soft mint background
            _buildHeader(context),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search / Promo code input field
                    _buildInputCard(),
                    const SizedBox(height: 18),

                    // Section: VOUCHER GRATIS ONGKIR
                    Text(
                      'VOUCHER GRATIS ONGKIR',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Free Shipping Voucher Card
                    _buildVoucherCard(
                      leftColor: const Color(0xFF0F8A50),
                      leftIcon: Icons.local_shipping_outlined,
                      leftTitle: 'Pengiriman',
                      leftSubtitle: 'Pengiriman',
                      title: 'Gratis Ongkir s.d. Rp15.000',
                      subtitle: 'Min. Belanja Rp75.000',
                      progressVal: 0.65,
                      expiryText: 'Segera habis • sisa 8 jam',
                      isSelected: _freeShippingSelected,
                      onTap: () {
                        setState(() {
                          _freeShippingSelected = !_freeShippingSelected;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Section: DISKON KATERING & MENU SEHAT
                    Text(
                      'DISKON KATERING & MENU SEHAT',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Diskon 10%
                    _buildVoucherCard(
                      leftColor: const Color(0xFF0F8A50),
                      leftIcon: Icons.local_offer_outlined,
                      leftTitle: 'POTONGAN',
                      leftSubtitle: 'NUTRI-DEAL',
                      title: 'Diskon 10% s.d. Rp. 30.000',
                      subtitle: 'Min. Belanja Rp100.000',
                      progressVal: 0.8,
                      expiryText: 'Segera habis • sisa 8 jam',
                      isSelected: _selectedDiscountIndex == 0,
                      onTap: () {
                        setState(() {
                          _selectedDiscountIndex = 0;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // Diskon Rp15.000 (Checked in screenshot)
                    _buildVoucherCard(
                      leftColor: const Color(0xFF0F8A50),
                      leftIcon: Icons.local_offer_outlined,
                      leftTitle: 'POTONGAN',
                      leftSubtitle: 'NUTRI-DEAL',
                      badgeTop: 'Terbatas',
                      badgeTopColor: const Color(0xFFF59E0B),
                      title: 'Diskon Rp15.000',
                      subtitle: 'Min. Belanja Rp75.000',
                      badgeMid: 'NutriPay / Saldo',
                      badgeMidColor: const Color(0xFFDCFCE7),
                      badgeMidTextColor: const Color(0xFF166534),
                      progressVal: 0.75,
                      expiryText: 'Segera habis • sisa 8 jam',
                      isSelected: _selectedDiscountIndex == 1,
                      onTap: () {
                        setState(() {
                          _selectedDiscountIndex = 1;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // Diskon 30% Katering Sehat
                    _buildVoucherCard(
                      leftColor: const Color(0xFF265764),
                      leftIcon: Icons.local_offer_outlined,
                      leftTitle: 'PAKET DIET',
                      leftSubtitle: 'MINGGUAN',
                      title: 'Diskon 30% Katering Sehat',
                      detailText: 'Maks. diskon Rp40.000',
                      subtitle: 'Min. Belanja Rp120.000',
                      validityText: 'Berlaku s.d. 04 Nov 2024',
                      isSelected: _selectedDiscountIndex == 2,
                      onTap: () {
                        setState(() {
                          _selectedDiscountIndex = 2;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // Cashback 20% Koin Sehat
                    _buildVoucherCard(
                      leftColor: const Color(0xFFE48D1D),
                      leftIcon: Icons.local_offer_outlined,
                      leftTitle: 'CASHBACK',
                      leftSubtitle: 'KOIN NUTRI',
                      title: 'Cashback 20% Koin Sehat',
                      detailText: 'Maks. Cashback 10.000 Koin',
                      subtitle: 'Min. Belanja Rp50.000',
                      validityText: 'Berlaku hari ini',
                      isSelected: _selectedDiscountIndex == 3,
                      onTap: () {
                        setState(() {
                          _selectedDiscountIndex = 3;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Sticky Bar (Image 5 bottom)
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFC3E7C4),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 15,
                color: AppColors.textDark,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Voucher & Promo',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
          ),
          const SizedBox(width: 36), // Balanced spacer
        ],
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.confirmation_number_outlined, color: Color(0xFF94A3B8), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _inputController,
              style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppColors.textDark),
              decoration: InputDecoration(
                hintText: 'Masukkan Kode Voucher Katering',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF94A3B8)),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          SizedBox(
            height: 32,
            child: ElevatedButton(
              onPressed: () {
                if (_inputController.text.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Kode voucher "${_inputController.text}" berhasil dipasang!'),
                      backgroundColor: const Color(0xFF16A34A),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                'Pakai',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherCard({
    required Color leftColor,
    required IconData leftIcon,
    required String leftTitle,
    required String leftSubtitle,
    String? badgeTop,
    Color? badgeTopColor,
    required String title,
    String? detailText,
    required String subtitle,
    String? badgeMid,
    Color? badgeMidColor,
    Color? badgeMidTextColor,
    double? progressVal,
    String? expiryText,
    String? validityText,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF22C55E) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left stub
              Container(
                width: 86,
                color: leftColor,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(leftIcon, color: Colors.white, size: 18),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      leftTitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      leftSubtitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),

              // Right content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (badgeTop != null) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      badgeTop,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w800,
                                        color: badgeTopColor ?? const Color(0xFFB45309),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                ],
                                Text(
                                  title,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Radio / Checkbox Indicator
                          Container(
                            width: 20,
                            height: 20,
                            margin: const EdgeInsets.only(left: 6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? const Color(0xFF16A34A) : Colors.transparent,
                              border: Border.all(
                                color: isSelected ? const Color(0xFF16A34A) : const Color(0xFFCBD5E1),
                                width: 1.6,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check_rounded, color: Colors.white, size: 13)
                                : null,
                          ),
                        ],
                      ),
                      if (detailText != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          detailText,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      if (badgeMid != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeMidColor ?? const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badgeMid,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: badgeMidTextColor ?? const Color(0xFF166534),
                            ),
                          ),
                        ),
                      ],
                      if (progressVal != null) ...[
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progressVal,
                            backgroundColor: const Color(0xFFF1F5F9),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
                            minHeight: 3.5,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (expiryText != null)
                            Text(
                              expiryText,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                color: const Color(0xFFEF4444),
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          else if (validityText != null)
                            Text(
                              validityText,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                color: const Color(0xFF64748B),
                              ),
                            )
                          else
                            const SizedBox(),
                          Text(
                            'S&K',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              color: const Color(0xFF16A34A),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
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
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '2 Voucher Dipilih Otomatis:',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Hemat ',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    TextSpan(
                      text: '-Rp30.000',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Gratis Ongkir & Potongan Menu -Rp15.000',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFEF4444),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                final controller = context.read<NutriMealMenuController>();
                controller.applyVoucher('NUTRIHEMAT');
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Gunakan Voucher NutriMeal',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
