import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/app_colors.dart';
import '../../services/api_service.dart';
import '../../core/widgets/center_feedback_toast.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  final String packageName;
  final String totalAmount;
  final String customerAddress;
  final String deliveryTime;
  final int estimatedMinutes;
  final bool isSubscription;

  const OrderTrackingScreen({
    super.key,
    this.orderId = '',
    this.packageName = '',
    this.totalAmount = '',
    this.customerAddress = '',
    this.deliveryTime = '',
    this.estimatedMinutes = 25,
    this.isSubscription = false,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  // Current active stage index: 0 = Diterima, 1 = Diproses, 2 = Dikirim, 3 = Selesai
  int _currentStageIndex = 0;
  bool _isLoading = false;
  Map<String, dynamic>? _serverOrder;
  String _serverStatus = '';
  String _serverPaymentStatus = '';
  Timer? _countdownTimer;
  late int _remainingMinutes;

  final List<Map<String, dynamic>> _stages = [
    {
      'title': 'Pesanan Diterima',
      'subtitle':
          'Pembayaran QRIS lunas & order tercatat di sistem dapur NutriMeal',
      'icon': Icons.receipt_long_rounded,
      'time': '11:15 WIB',
    },
    {
      'title': 'Dapur Menyiapkan Makanan',
      'subtitle':
          'Bahan segar & organik dimasak higienis sesuai standar ahli gizi',
      'icon': Icons.soup_kitchen_rounded,
      'time': '11:25 WIB',
    },
    {
      'title': 'Kurir Sedang Mengantar',
      'subtitle':
          'Paket katering dalam perjalanan aman menuju alamat tujuan Anda',
      'icon': Icons.delivery_dining_rounded,
      'time': '11:40 WIB',
    },
    {
      'title': 'Pesanan Sampai di Lokasi',
      'subtitle':
          'Makanan sehat siap dinikmati dalam kondisi hangat dan higienis',
      'icon': Icons.check_circle_rounded,
      'time': '12:00 WIB',
    },
  ];

  @override
  void initState() {
    super.initState();
    _remainingMinutes = widget.estimatedMinutes;
    _fetchLiveOrderStatus();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (!mounted) return;
      if (_remainingMinutes > 1) {
        setState(() => _remainingMinutes--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _fetchLiveOrderStatus() async {
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    final argOrderId = routeArgs is Map
        ? (routeArgs['orderId'] ?? routeArgs['order_id'] ?? '').toString()
        : '';
    final lookupOrderId = widget.orderId.trim().isNotEmpty
        ? widget.orderId.trim()
        : argOrderId.trim();

    if (lookupOrderId.isEmpty) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final orders = await ApiService.instance.fetchOrders(
        search: lookupOrderId,
      );
      if (orders.isNotEmpty && mounted) {
        final matched = orders.firstWhere(
          (o) =>
              o['id']?.toString().toLowerCase() == lookupOrderId.toLowerCase(),
          orElse: () => orders.first,
        );
        setState(() {
          _serverOrder = matched;
          _serverStatus = (matched['status'] ?? '').toString();
          _serverPaymentStatus = (matched['payment_status'] ?? '').toString();
          final statusStr = _serverStatus.toLowerCase();
          if (statusStr.contains('menunggu') || statusStr.contains('batal')) {
            _currentStageIndex = 0;
          } else if (statusStr.contains('terima')) {
            _currentStageIndex = 0;
          } else if (statusStr.contains('proses') ||
              statusStr.contains('siap') ||
              statusStr.contains('masak')) {
            _currentStageIndex = 1;
          } else if (statusStr.contains('kirim') ||
              statusStr.contains('antar')) {
            _currentStageIndex = 2;
          } else if (statusStr.contains('selesai') ||
              statusStr.contains('tiba')) {
            _currentStageIndex = 3;
          }
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  String _formatServerRupiah(dynamic value) {
    final numVal = value is num
        ? value.round()
        : double.tryParse('$value')?.round() ?? 0;
    if (numVal <= 0) return '-';
    final str = numVal.toString();
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
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    final argMap = routeArgs is Map
        ? Map<String, dynamic>.from(routeArgs)
        : const <String, dynamic>{};

    final effectiveOrderId = widget.orderId.trim().isNotEmpty
        ? widget.orderId
        : (_serverOrder?['id']?.toString() ??
              argMap['orderId']?.toString() ??
              argMap['order_id']?.toString() ??
              '-');
    final effectivePackageName = widget.packageName.trim().isNotEmpty
        ? widget.packageName
        : (_serverOrder?['package_name']?.toString() ??
              argMap['packageName']?.toString() ??
              'Pesanan NutriMeal');
    final effectiveTotalAmount = widget.totalAmount.trim().isNotEmpty
        ? widget.totalAmount
        : (_serverOrder?['total_price'] != null
              ? _formatServerRupiah(_serverOrder!['total_price'])
              : (argMap['totalAmount']?.toString() ?? '-'));
    final effectiveAddress = widget.customerAddress.trim().isNotEmpty
        ? widget.customerAddress
        : (_serverOrder?['customer_address']?.toString() ??
              argMap['customerAddress']?.toString() ??
              '-');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textDark,
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tracking Pesanan',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF0F8A50),
                    ),
                  )
                : const Icon(Icons.refresh_rounded, color: Color(0xFF0F8A50)),
            tooltip: 'Perbarui Status',
            onPressed: _fetchLiveOrderStatus,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Hero Status Card (Live Delivery ETA)
              _buildHeroEtaCard(effectiveOrderId),
              const SizedBox(height: 18),

              // 1.5 Live Real-time Google Maps Tracking
              _buildLiveMapTrackingCard(effectiveAddress),
              const SizedBox(height: 18),

              // 2. Courier Profile Card (Contact & Details)
              _buildCourierCard(),
              const SizedBox(height: 18),

              // 3. Step-by-Step Order Timeline
              _buildTimelineCard(),
              const SizedBox(height: 18),

              // 4. Order & Destination Summary Card
              _buildOrderSummaryCard(
                effectivePackageName,
                effectiveTotalAmount,
                effectiveAddress,
              ),
              const SizedBox(height: 24),

              // 5. Action Buttons (Hubungi CS & Kembali)
              _buildActionButtons(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroEtaCard(String orderId) {
    final lowerStatus = _serverStatus.toLowerCase();
    final lowerPayStatus = _serverPaymentStatus.toLowerCase();
    final isCancelled =
        lowerStatus.contains('batal') ||
        lowerPayStatus.contains('batal') ||
        lowerPayStatus.contains('kedaluwarsa');
    final isWaitingPayment =
        !isCancelled &&
        (lowerStatus.contains('menunggu') ||
            lowerPayStatus.contains('menunggu'));

    final currentStage = _stages[_currentStageIndex];
    final headline = isCancelled
        ? 'Pesanan Dibatalkan / Kedaluwarsa'
        : isWaitingPayment
        ? 'Menunggu Pembayaran QRIS'
        : currentStage['title'].toString();
    final subtitle = isCancelled
        ? 'Pesanan ini tidak lagi aktif karena pembayaran dibatalkan atau melewati batas waktu.'
        : isWaitingPayment
        ? 'Selesaikan pembayaran QRIS terlebih dahulu agar pesanan diteruskan ke dapur NutriMeal.'
        : currentStage['subtitle'].toString();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCancelled
              ? [const Color(0xFFDC2626), const Color(0xFFB91C1C)]
              : isWaitingPayment
              ? [const Color(0xFFD97706), const Color(0xFFB45309)]
              : const [Color(0xFF0F8A50), Color(0xFF15803D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color:
                (isCancelled
                        ? const Color(0xFFDC2626)
                        : isWaitingPayment
                        ? const Color(0xFFD97706)
                        : const Color(0xFF0F8A50))
                    .withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.tag_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      orderId,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _fetchLiveOrderStatus,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.refresh_rounded,
                        color: Color(0xFF0F8A50),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Perbarui Status',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F8A50),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            headline,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              color: Colors.white.withValues(alpha: 0.92),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time_filled_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isCancelled
                        ? 'Status Pembayaran: ${_serverPaymentStatus.isNotEmpty ? _serverPaymentStatus : 'Dibatalkan'}'
                        : isWaitingPayment
                        ? 'Pembayaran belum dikonfirmasi oleh sistem QRIS'
                        : _currentStageIndex == 3
                        ? 'Pesanan Telah Tiba di Lokasi Anda'
                        : widget.isSubscription
                        ? 'Katering Siap Diantar${widget.deliveryTime.isNotEmpty ? ': ${widget.deliveryTime}' : ''}'
                        : 'Estimasi Sampai: $_remainingMinutes Menit${widget.deliveryTime.isNotEmpty ? ' (${widget.deliveryTime})' : ''}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
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

  Widget _buildLiveMapTrackingCard(String customerAddress) {
    // Koordinat Dapur Utama NutriMeal (Malang)
    const kitchenPoint = LatLng(-7.9785, 112.6310);
    // Koordinat Tujuan Pelanggan
    const destinationPoint = LatLng(-7.9826, 112.6308);

    // Hitung posisi kurir berdasarkan _currentStageIndex (0, 1, 2, 3)
    LatLng courierPoint;
    if (_currentStageIndex <= 1) {
      courierPoint = kitchenPoint;
    } else if (_currentStageIndex == 2) {
      // Posisi di tengah perjalanan (stage Diantar)
      courierPoint = const LatLng(-7.9805, 112.6309);
    } else {
      courierPoint = destinationPoint;
    }

    const centerPoint = LatLng(-7.9805, 112.6309);

    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Live Google Maps Roadmap Layer
          Positioned.fill(
            child: FlutterMap(
              options: const MapOptions(
                initialCenter: centerPoint,
                initialZoom: 15.5,
                interactionOptions: InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                  userAgentPackageName: 'com.nutrimeal.app',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: const [
                        kitchenPoint,
                        LatLng(-7.9805, 112.6309),
                        destinationPoint,
                      ],
                      color: const Color(0xFF0F8A50),
                      strokeWidth: 4.0,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    // Dapur NutriMeal Marker
                    Marker(
                      point: kitchenPoint,
                      width: 32,
                      height: 32,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF0F8A50),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.soup_kitchen_rounded,
                          color: Color(0xFF0F8A50),
                          size: 18,
                        ),
                      ),
                    ),

                    // Titik Tujuan Pelanggan Marker
                    Marker(
                      point: destinationPoint,
                      width: 32,
                      height: 32,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F8A50),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),

                    // Kurir Marker (Motor Bergerak)
                    Marker(
                      point: courierPoint,
                      width: 36,
                      height: 36,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF97316),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.delivery_dining_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Top Badge: "Live GPS Tracking Google Maps"
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF16A34A),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Live GPS Tracking Google Maps',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Route Pill: Estimasi Jarak & Titik Antar
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.route_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Rute: Dapur NutriMeal ➔ $customerAddress',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourierCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF86EFAC), width: 2),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Color(0xFF0F8A50),
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Budi Santoso',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Kurir',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF166534),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Honda Vario • N 4821 ABC',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFEAB308),
                      size: 14,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '4.9 (140+ Pengantaran)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Call / Chat Button
          InkWell(
            onTap: () {
              CenterFeedbackToast.showInfo(
                context,
                message:
                    'Menghubungkan ke Kurir Budi Santoso (+62 812-3456-7890)...',
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: const Icon(
                Icons.phone_in_talk_rounded,
                color: Color(0xFF0F8A50),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status Pengantaran',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Real-time Live',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _stages.length,
            itemBuilder: (context, index) {
              final stage = _stages[index];
              final lowerStatus = _serverStatus.toLowerCase();
              final lowerPayStatus = _serverPaymentStatus.toLowerCase();
              final isWaitingOrCancelled =
                  lowerStatus.contains('menunggu') ||
                  lowerStatus.contains('batal') ||
                  lowerPayStatus.contains('menunggu') ||
                  lowerPayStatus.contains('batal') ||
                  lowerPayStatus.contains('kedaluwarsa');
              final isDone =
                  !isWaitingOrCancelled && index <= _currentStageIndex;
              final isCurrent =
                  !isWaitingOrCancelled && index == _currentStageIndex;
              final isLast = index == _stages.length - 1;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline indicator (Dot and Line)
                    Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isDone
                                ? const Color(0xFF0F8A50)
                                : const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCurrent
                                  ? const Color(0xFF86EFAC)
                                  : isDone
                                  ? const Color(0xFF0F8A50)
                                  : const Color(0xFFCBD5E1),
                              width: isCurrent ? 3 : 1.5,
                            ),
                          ),
                          child: Icon(
                            stage['icon'] as IconData,
                            size: 16,
                            color: isDone
                                ? Colors.white
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2.5,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              color: index < _currentStageIndex
                                  ? const Color(0xFF0F8A50)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    // Stage details
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  stage['title'],
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
                                    fontWeight: isCurrent
                                        ? FontWeight.w900
                                        : FontWeight.w700,
                                    color: isDone
                                        ? AppColors.textDark
                                        : const Color(0xFF94A3B8),
                                  ),
                                ),
                                Text(
                                  stage['time'],
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isDone
                                        ? const Color(0xFF64748B)
                                        : const Color(0xFFCBD5E1),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              stage['subtitle'],
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                color: isDone
                                    ? const Color(0xFF64748B)
                                    : const Color(0xFF94A3B8),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard(
    String packageName,
    String totalAmount,
    String address,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rincian Pesanan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFF0F8A50),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alamat Tujuan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      address,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lunch_dining_rounded,
                  color: Color(0xFFD97706),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paket Katering',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      packageName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                totalAmount,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F8A50),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/chat-admin'),
            icon: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
            label: Text(
              'Hubungi CS / Admin NutriMeal',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
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
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/home', (route) => false),
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
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
