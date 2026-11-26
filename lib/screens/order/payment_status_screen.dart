import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/menu_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_config.dart';
import '../../core/widgets/center_feedback_toast.dart';
import '../../data/models/qris_payment.dart';

class PaymentStatusScreen extends StatefulWidget {
  final QrisPayment? payment;
  final String orderId;
  final String totalAmount;
  final String packageName;
  final String paymentMethod;
  final String firstMealName;
  final String firstMealImage;
  final String deliveryTime;
  final int estimatedMinutes;
  final bool isSubscription;
  final String customerAddress;

  const PaymentStatusScreen({
    super.key,
    this.payment,
    this.orderId = '',
    this.totalAmount = '',
    this.packageName = '',
    this.paymentMethod = 'QRIS',
    this.firstMealName = '',
    this.firstMealImage = '',
    this.deliveryTime = '',
    this.estimatedMinutes = 30,
    this.isSubscription = false,
    this.customerAddress = '',
  });

  @override
  State<PaymentStatusScreen> createState() => _PaymentStatusScreenState();
}

class _PaymentStatusScreenState extends State<PaymentStatusScreen> {
  bool _hasShownPopup = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _hasShownPopup) return;
      final routeArgs = ModalRoute.of(context)?.settings.arguments;
      final argPayment =
          widget.payment ?? (routeArgs is QrisPayment ? routeArgs : null);
      final argMap = routeArgs is Map
          ? Map<String, dynamic>.from(routeArgs)
          : const <String, dynamic>{};
      final hasOrderId =
          widget.orderId.trim().isNotEmpty ||
          (argPayment?.orderId ?? argMap['orderId']?.toString() ?? '')
              .trim()
              .isNotEmpty;
      if (!hasOrderId) return;
      _hasShownPopup = true;
      _showNotificationPopup(context);
    });
  }

  void _showNotificationPopup(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_active_rounded,
                color: Color(0xFF0F8A50),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Pembayaran Berhasil!',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Pesanan Anda sedang diproses. Anda dapat melihat status dan detail pesanan di menu Notifikasi.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: const Color(0xFF475569),
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Nanti',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              Navigator.of(context).pushNamed('/notifikasi');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F8A50),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Lihat di Notifikasi',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatRupiah(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return 'Rp$buffer';
  }

  @override
  Widget build(BuildContext context) {
    final payment = widget.payment;
    final orderId = widget.orderId;
    final totalAmount = widget.totalAmount;
    final packageName = widget.packageName;
    final firstMealName = widget.firstMealName;
    final firstMealImage = widget.firstMealImage;
    final deliveryTime = widget.deliveryTime;
    final isSubscription = widget.isSubscription;
    final customerAddress = widget.customerAddress;

    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    final argPayment = payment ?? (routeArgs is QrisPayment ? routeArgs : null);
    final argMap = routeArgs is Map
        ? Map<String, dynamic>.from(routeArgs)
        : const <String, dynamic>{};

    final resolvedOrderId = orderId.trim().isNotEmpty
        ? orderId.trim()
        : (argPayment?.orderId ?? argMap['orderId']?.toString() ?? '').trim();
    final resolvedAmount = totalAmount.trim().isNotEmpty
        ? totalAmount.trim()
        : (argPayment != null
              ? _formatRupiah(argPayment.amount)
              : (argMap['totalAmount']?.toString() ?? '').trim());
    final resolvedPackage = packageName.trim().isNotEmpty
        ? packageName.trim()
        : (argPayment?.packageName ??
              argMap['packageName']?.toString() ??
              'Pesanan NutriMeal');
    final resolvedFirstMeal = firstMealName.trim().isNotEmpty
        ? firstMealName.trim()
        : (argPayment?.firstMealName ??
              argMap['firstMealName']?.toString() ??
              resolvedPackage);
    final resolvedFirstMealImage = firstMealImage.trim().isNotEmpty
        ? firstMealImage.trim()
        : (argPayment?.firstMealImage ??
              argMap['firstMealImage']?.toString() ??
              '');
    final resolvedDeliveryTime = deliveryTime.trim().isNotEmpty
        ? deliveryTime.trim()
        : (argPayment?.deliveryTime ??
              argMap['deliveryTime']?.toString() ??
              '11:30 - 13:00 WIB');
    final resolvedIsSubscription =
        isSubscription ||
        (argPayment?.isSubscription ?? (argMap['isSubscription'] == true));
    final resolvedAddress = customerAddress.trim().isNotEmpty
        ? customerAddress.trim()
        : (argPayment?.customerAddress ??
              argMap['customerAddress']?.toString() ??
              '');

    if (resolvedOrderId.isEmpty || resolvedAmount.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.receipt_long_rounded,
                        size: 54,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Data Pembayaran Tidak Tersedia',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Silakan selesaikan pembayaran QRIS terlebih dahulu atau cek pesanan aktif Anda.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).pushNamedAndRemoveUntil('/home', (route) => false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F8A50),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'Kembali ke Beranda',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Top App Bar
            _buildHeader(context),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  children: [
                    // Big Green Checkmark Icon with soft outer halo
                    Container(
                      width: 82,
                      height: 82,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDCFCE7),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        width: 62,
                        height: 62,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0F8A50),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      'Pembayaran Berhasil!',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      'Pesanan katering sehatmu sedang dijadwalkan\nke dapur NutriMeal.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Amount
                    Text(
                      resolvedAmount,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F8A50),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Order Info Card
                    _buildOrderInfoCard(
                      context,
                      resolvedOrderId: resolvedOrderId,
                      resolvedPackage: resolvedPackage,
                    ),
                    const SizedBox(height: 16),

                    // Upcoming Meal Card
                    _buildUpcomingMealCard(
                      resolvedFirstMeal: resolvedFirstMeal,
                      resolvedFirstMealImage: resolvedFirstMealImage,
                      resolvedDeliveryTime: resolvedDeliveryTime,
                      resolvedIsSubscription: resolvedIsSubscription,
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Buttons
            _buildBottomButtons(
              context,
              resolvedOrderId: resolvedOrderId,
              resolvedPackage: resolvedPackage,
              resolvedAmount: resolvedAmount,
              resolvedAddress: resolvedAddress,
              resolvedDeliveryTime: resolvedDeliveryTime,
              resolvedIsSubscription: resolvedIsSubscription,
            ),
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
      decoration: const BoxDecoration(color: Color(0xFFC3E7C4)),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/home', (route) => false);
            },
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
              'Status Pembayaran',
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

  Widget _buildOrderInfoCard(
    BuildContext context, {
    required String resolvedOrderId,
    required String resolvedPackage,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          // Row 1: No. ID Pesanan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'No. ID Pesanan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
              Row(
                children: [
                  Text(
                    '#$resolvedOrderId',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(text: '#$resolvedOrderId'),
                      );
                      CenterFeedbackToast.showSuccess(
                        context,
                        message: 'ID Pesanan disalin ke clipboard',
                      );
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.copy_rounded,
                          size: 12,
                          color: Color(0xFF16A34A),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'Salin',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 2: Paket / Menu Pesanan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Paket / Menu',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  resolvedPackage,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 3: Metode
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Metode',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
              Text(
                widget.paymentMethod,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingMealCard({
    required String resolvedFirstMeal,
    required String resolvedFirstMealImage,
    required String resolvedDeliveryTime,
    required bool resolvedIsSubscription,
  }) {
    final effectiveImageUrl = resolvedFirstMealImage.isNotEmpty
        ? ApiConfig.resolveImageUrl(resolvedFirstMealImage)
        : '';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Food Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: effectiveImageUrl.isNotEmpty
                ? Image.network(
                    effectiveImageUrl,
                    width: 58,
                    height: 58,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 58,
                      height: 58,
                      color: const Color(0xFFDCFCE7),
                      child: const Icon(
                        Icons.restaurant_rounded,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  )
                : Container(
                    width: 58,
                    height: 58,
                    color: const Color(0xFFDCFCE7),
                    child: const Icon(
                      Icons.restaurant_rounded,
                      color: Color(0xFF16A34A),
                    ),
                  ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_filled_rounded,
                      size: 13,
                      color: Color(0xFF16A34A),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        resolvedDeliveryTime,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF16A34A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  resolvedFirstMeal,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  resolvedIsSubscription
                      ? 'Pengiriman katering • Estimasi tiba ${widget.estimatedMinutes} menit'
                      : 'Sedang disiapkan di dapur • Estimasi tiba ${widget.estimatedMinutes} menit',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(
    BuildContext context, {
    required String resolvedOrderId,
    required String resolvedPackage,
    required String resolvedAmount,
    required String resolvedAddress,
    required String resolvedDeliveryTime,
    required bool resolvedIsSubscription,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
        children: [
          // Button 1 (Primary Action): Lihat di Notifikasi / Lihat Jadwal Katering
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                final controller = context.read<NutriMealMenuController>();
                controller.clearCart();
                controller.clearSubscriptionPackage();
                controller.setActivePendingPayment(null);

                if (resolvedIsSubscription) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/langganan-saya',
                    (route) => false,
                  );
                } else {
                  Navigator.of(context).pushNamed('/notifikasi');
                }
              },
              icon: Icon(
                resolvedIsSubscription
                    ? Icons.calendar_month_rounded
                    : Icons.notifications_active_rounded,
                color: Colors.white,
                size: 20,
              ),
              label: Text(
                resolvedIsSubscription
                    ? 'Lihat Jadwal Katering Saya'
                    : 'Lihat di Notifikasi',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F8A50),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Button 2: Kembali ke Beranda
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                final controller = context.read<NutriMealMenuController>();
                controller.clearCart();
                controller.clearSubscriptionPackage();
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/home', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF1F5F9),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(
                'Kembali ke Beranda',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
