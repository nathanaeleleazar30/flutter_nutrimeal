import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/menu_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../services/api_service.dart';
import '../../core/widgets/center_feedback_toast.dart';

class VoucherPromoScreen extends StatefulWidget {
  const VoucherPromoScreen({super.key});

  @override
  State<VoucherPromoScreen> createState() => _VoucherPromoScreenState();
}

class _VoucherPromoScreenState extends State<VoucherPromoScreen> {
  final TextEditingController _inputController = TextEditingController();
  bool _isLoading = true;
  List<Map<String, dynamic>> _vouchers = [];
  Map<String, dynamic>? _selectedVoucher;

  @override
  void initState() {
    super.initState();
    _loadVouchers();
  }

  Future<void> _loadVouchers() async {
    setState(() => _isLoading = true);
    try {
      final list = await ApiService.instance.fetchVouchers();
      final activeList = list
          .where((v) => v['is_active'] == 1 || v['is_active'] == true)
          .toList();
      if (mounted) {
        setState(() {
          _vouchers = activeList;
          _isLoading = false;
          if (_vouchers.isNotEmpty) {
            _selectedVoucher = _vouchers.first;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _applyCustomCode() async {
    final code = _inputController.text.trim();
    if (code.isEmpty) return;

    final voucher = await ApiService.instance.getVoucherByCode(code);
    if (!mounted) return;

    if (voucher != null) {
      setState(() {
        _selectedVoucher = voucher;
        if (!_vouchers.any((v) => v['code'] == voucher['code'])) {
          _vouchers.insert(0, voucher);
        }
      });
      CenterFeedbackToast.showSuccess(
        context,
        message: 'Kode voucher "${code.toUpperCase()}" berhasil diterapkan!',
      );
    } else {
      CenterFeedbackToast.showError(
        context,
        message: 'Kode voucher "$code" tidak ditemukan atau sudah tidak aktif.',
      );
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  String _formatCurrency(int val) {
    final s = val.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp$buf';
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
              child: RefreshIndicator(
                onRefresh: _loadVouchers,
                color: AppColors.primaryGreen,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search / Promo code input field
                      _buildInputCard(),
                      const SizedBox(height: 18),

                      Text(
                        'DAFTAR VOUCHER & PROMO NUTRI-DEAL',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF64748B),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),

                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        )
                      else if (_vouchers.isEmpty)
                        _buildEmptyVoucherState()
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _vouchers.length,
                          separatorBuilder: (_, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (ctx, idx) {
                            final v = _vouchers[idx];
                            final isSel =
                                _selectedVoucher?['code'] == v['code'];
                            return _buildDynamicVoucherCard(v, isSel);
                          },
                        ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Sticky Bar
            if (_selectedVoucher != null) _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyVoucherState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFFEF3C7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_offer_outlined,
              size: 36,
              color: Color(0xFFB45309),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Voucher Tersedia',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Saat ini belum ada promo aktif. Cek kembali nanti untuk diskon spesial katering!',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicVoucherCard(Map<String, dynamic> v, bool isSelected) {
    final type = (v['discount_type'] ?? 'nominal').toString().toLowerCase();
    final val = int.tryParse('${v['discount_value']}') ?? 0;
    final minSpend = int.tryParse('${v['min_spend']}') ?? 0;
    final title = v['title'] ?? 'Promo NutriMeal';
    final code = (v['code'] ?? '').toString().toUpperCase();
    final validUntil = v['valid_until'] != null
        ? v['valid_until'].toString()
        : '';

    String leftTitle = 'DISKON';
    String leftSubtitle = 'NUTRI-DEAL';
    Color leftColor = const Color(0xFF0F8A50);
    IconData leftIcon = Icons.local_offer_outlined;

    if (type == 'free_shipping') {
      leftTitle = 'ONGKIR';
      leftSubtitle = 'GRATIS';
      leftColor = const Color(0xFF0F8A50);
      leftIcon = Icons.local_shipping_outlined;
    } else if (type == 'percent') {
      leftTitle = '$val%';
      leftSubtitle = 'DISKON';
      leftColor = const Color(0xFF265764);
      leftIcon = Icons.percent_rounded;
    } else if (type == 'cashback') {
      leftTitle = 'CASHBACK';
      leftSubtitle = 'KOIN';
      leftColor = const Color(0xFFE48D1D);
      leftIcon = Icons.monetization_on_outlined;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() {
            _selectedVoucher = isSelected ? null : v;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFE2E8F0),
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isSelected ? 0.05 : 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left badge
                Container(
                  width: 82,
                  decoration: BoxDecoration(
                    color: leftColor,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(15),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 12,
                  ),
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

                // Right details
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
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
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'KODE: $code',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF166534),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
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
                            Container(
                              width: 20,
                              height: 20,
                              margin: const EdgeInsets.only(left: 6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? const Color(0xFF16A34A)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFFCBD5E1),
                                  width: 1.6,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 13,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          minSpend > 0
                              ? 'Min. Belanja ${_formatCurrency(minSpend)}'
                              : 'Tanpa minimum belanja',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (validUntil.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Berlaku s.d. $validUntil',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ],
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      decoration: const BoxDecoration(color: Color(0xFFC3E7C4)),
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
          const SizedBox(width: 36),
        ],
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.confirmation_number_outlined,
            color: Color(0xFF94A3B8),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _inputController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'Masukkan kode promo...',
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: const Color(0xFF94A3B8),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 6),
              ),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
              onSubmitted: (_) => _applyCustomCode(),
            ),
          ),
          GestureDetector(
            onTap: _applyCustomCode,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF0F5132),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Terapkan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final v = _selectedVoucher;
    final code = (v?['code'] ?? '').toString().toUpperCase();

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
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
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF16A34A),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Voucher Dipilih:',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              Text(
                code,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF16A34A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                if (v != null) {
                  final controller = context.read<NutriMealMenuController>();
                  final applied = controller.applyVoucherData(v);
                  if (applied) {
                    Navigator.pop(context);
                    CenterFeedbackToast.showSuccess(
                      context,
                      message:
                          'Voucher $code berhasil diterapkan ke keranjang!',
                    );
                  } else {
                    CenterFeedbackToast.showError(
                      context,
                      message:
                          'Subtotal belanja belum memenuhi syarat minimum voucher.',
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
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
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
