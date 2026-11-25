import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/menu_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/center_feedback_toast.dart';
import '../../data/models/qris_payment.dart';
import '../../services/notification_service.dart';
import '../../services/payment_service.dart';
import 'payment_status_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final Map<String, dynamic>? subscriptionPackage;
  final QrisPayment? existingPayment;
  final PaymentService? paymentService;

  const CheckoutScreen({
    super.key,
    this.subscriptionPackage,
    this.existingPayment,
    this.paymentService,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen>
    with WidgetsBindingObserver {
  late final PaymentService _paymentService;

  Map<String, dynamic>? _resolvedSubscriptionPackage;
  QrisPayment? _activePayment;
  QrisPayment? _conflictingPendingPayment;

  bool _initialized = false;
  bool _isPreparingQris = false;
  bool _needsProfileCompletion = false;
  bool _isEmptyCartError = false;
  bool _isCheckingStatus = false;
  bool _isCancelling = false;
  bool _isExpiredUi = false;
  bool _hasCompletedNavigation = false;

  String? _prepareError;
  Timer? _countdownTimer;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _paymentService = widget.paymentService ?? PaymentService();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (widget.existingPayment != null) {
      _activePayment = widget.existingPayment;
    } else if (args is QrisPayment) {
      _activePayment = args;
    }

    if (widget.subscriptionPackage != null) {
      _resolvedSubscriptionPackage = widget.subscriptionPackage;
    } else if (args is Map<String, dynamic>) {
      _resolvedSubscriptionPackage = args;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _bootstrapFlow();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _activePayment != null &&
        _activePayment!.isPending) {
      _syncPaymentStatusNow(userInitiated: false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopTimers();
    super.dispose();
  }

  void _stopTimers() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _pollTimer?.cancel();
    _pollTimer = null;
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

  String _formatCountdown(Duration duration) {
    final safe = duration.isNegative ? Duration.zero : duration;
    final minutes = safe.inMinutes.toString().padLeft(2, '0');
    final seconds = (safe.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  bool get _isSubscriptionOrder => _resolvedSubscriptionPackage != null;

  String? get _effectivePackageId =>
      _resolvedSubscriptionPackage?['id']?.toString();

  ({String name, String phone, String address}) _resolveDeliveryData(
    AuthController auth,
    NutriMealMenuController menu,
  ) {
    final savedAddress = menu.deliveryAddress;
    final resolvedAddress = menu.hasValidDeliveryAddress
        ? savedAddress.fullAddress.trim()
        : (auth.customerAddress?.trim() ?? '');
    final resolvedPhone = savedAddress.phoneNumber.trim().isNotEmpty
        ? savedAddress.phoneNumber.trim()
        : (auth.customerPhone?.trim() ?? '');
    final resolvedName =
        (savedAddress.recipientName.trim().isNotEmpty &&
            savedAddress.recipientName != 'Customer')
        ? savedAddress.recipientName.trim()
        : (auth.currentUserName?.trim().isNotEmpty == true
              ? auth.currentUserName!.trim()
              : 'Pelanggan NutriMeal');
    return (name: resolvedName, phone: resolvedPhone, address: resolvedAddress);
  }

  Future<void> _bootstrapFlow() async {
    final auth = context.read<AuthController>();
    final menu = context.read<NutriMealMenuController>();

    if (_activePayment != null) {
      menu.setActivePendingPayment(_activePayment);
      if (_activePayment!.isPaid) {
        await _handlePaymentSucceeded(_activePayment!);
        return;
      }
      if (_activePayment!.isExpiredStatus ||
          _activePayment!.isCancelled ||
          _activePayment!.isFailed) {
        setState(() {
          _isExpiredUi = true;
        });
        menu.setActivePendingPayment(null);
        return;
      }
      if (_activePayment!.isTimedOut()) {
        await _syncPaymentStatusNow(userInitiated: false);
      } else {
        _startTimers();
      }
      return;
    }

    final token = auth.authToken;
    if (token == null || token.trim().isEmpty) {
      return;
    }

    if (!_isSubscriptionOrder && menu.cartItems.isEmpty) {
      setState(() {
        _isEmptyCartError = true;
        _isPreparingQris = false;
      });
      return;
    }

    final delivery = _resolveDeliveryData(auth, menu);
    if (delivery.address.isEmpty ||
        delivery.address.contains('Belum ada alamat') ||
        delivery.phone.isEmpty) {
      setState(() {
        _needsProfileCompletion = true;
        _isPreparingQris = false;
      });
      return;
    }

    setState(() {
      _needsProfileCompletion = false;
      _isEmptyCartError = false;
      _conflictingPendingPayment = null;
      _isPreparingQris = true;
      _prepareError = null;
    });

    // 1. Cek apakah sudah ada transaksi QRIS pending milik akun ini
    try {
      final existing = await _paymentService.getActivePayment(authToken: token);
      if (!mounted) return;
      if (existing != null && existing.isPending) {
        final currentSig = menu.computeCartSignature(
          packageId: _effectivePackageId,
        );
        final sigDiffers =
            existing.cartSignature != null &&
            existing.cartSignature!.isNotEmpty &&
            existing.cartSignature != currentSig;

        if (sigDiffers) {
          menu.setActivePendingPayment(existing);
          setState(() {
            _isPreparingQris = false;
            _conflictingPendingPayment = existing;
          });
          return;
        }

        menu.setActivePendingPayment(existing);
        setState(() {
          _activePayment = existing;
          _isPreparingQris = false;
          _isExpiredUi = existing.isTimedOut();
        });
        if (_isExpiredUi) {
          await _syncPaymentStatusNow(userInitiated: false);
        } else {
          _startTimers();
        }
        return;
      }
    } on PaymentApiException catch (e) {
      if (!mounted) return;
      if (e.isUnauthorized) {
        setState(() {
          _isPreparingQris = false;
          _prepareError = e.message;
        });
        return;
      }
    } catch (_) {
      // Lanjutkan ke pembuatan QRIS dengan idempotency key
    }

    // 2. Langsung buat QRIS dinamis tanpa tombol tambahan
    await _createQrisAutomatically();
  }

  Future<void> _createQrisAutomatically({bool forceNewKey = false}) async {
    if (_isPreparingQris && _prepareError == null && _activePayment != null) {
      return;
    }
    final auth = context.read<AuthController>();
    final menu = context.read<NutriMealMenuController>();
    final token = auth.authToken;

    if (token == null || token.trim().isEmpty) {
      setState(() {
        _isPreparingQris = false;
        _prepareError = 'Sesi login berakhir. Silakan login kembali.';
      });
      return;
    }

    final delivery = _resolveDeliveryData(auth, menu);
    if (delivery.address.isEmpty ||
        delivery.address.contains('Belum ada alamat') ||
        delivery.phone.isEmpty) {
      setState(() {
        _isPreparingQris = false;
        _needsProfileCompletion = true;
      });
      return;
    }

    if (!_isSubscriptionOrder && menu.cartItems.isEmpty) {
      setState(() {
        _isPreparingQris = false;
        _isEmptyCartError = true;
      });
      return;
    }

    setState(() {
      _isPreparingQris = true;
      _prepareError = null;
      _needsProfileCompletion = false;
      _isEmptyCartError = false;
      _conflictingPendingPayment = null;
    });

    final packageId = _effectivePackageId;
    final customerKey =
        auth.customerId ?? auth.currentUserEmail ?? 'customer-session';
    final itemsPayload = _isSubscriptionOrder
        ? null
        : menu.cartItems
              .map(
                (c) => <String, dynamic>{
                  'meal_id': c.item.id,
                  'qty': c.quantity,
                },
              )
              .toList();
    final cartSig = menu.computeCartSignature(packageId: packageId);

    String idempotencyKey = forceNewKey
        ? await menu.rotateIdempotencyKey(
            customerId: customerKey,
            packageId: packageId,
            phone: delivery.phone,
            address: delivery.address,
          )
        : await menu.getOrCreateIdempotencyKey(
            customerId: customerKey,
            packageId: packageId,
            phone: delivery.phone,
            address: delivery.address,
          );

    const maxAttempts = 3;
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      if (!mounted) return;
      try {
        final shortDay = menu.cateringDays.isNotEmpty
            ? menu
                  .cateringDays[menu.selectedCateringDayIndex.clamp(
                    0,
                    menu.cateringDays.length - 1,
                  )]
                  .dayShort
            : 'SEN';
        const dayMap = {
          'SEN': 'Senin',
          'SEL': 'Selasa',
          'RAB': 'Rabu',
          'KAM': 'Kamis',
          'JUM': 'Jumat',
        };

        final payment = await _paymentService.createQris(
          authToken: token,
          idempotencyKey: idempotencyKey,
          items: itemsPayload,
          packageId: packageId,
          voucherCode: _isSubscriptionOrder ? null : menu.voucherCode,
          customerName: delivery.name,
          customerPhone: delivery.phone,
          customerAddress: delivery.address,
          addressDetail: menu.deliveryAddress.deliveryNote.trim().isNotEmpty
              ? menu.deliveryAddress.deliveryNote.trim()
              : null,
          deliverySchedule: _isSubscriptionOrder
              ? 'Mulai Senin, 11:30 WIB'
              : '11:30 - 13:00 WIB',
          deliveryBatch: 'Pagi/Siang',
          day: dayMap[shortDay] ?? 'Senin',
          cartSignature: cartSig,
        );

        if (!mounted) return;
        menu.setActivePendingPayment(payment);
        setState(() {
          _activePayment = payment;
          _isPreparingQris = false;
          _isExpiredUi = false;
          _prepareError = null;
        });

        if (payment.isPaid) {
          await _handlePaymentSucceeded(payment);
        } else {
          _startTimers();
        }
        return;
      } on PaymentApiException catch (e) {
        if (!mounted) return;

        if (e.isProcessing && attempt < maxAttempts) {
          await Future<void>.delayed(const Duration(milliseconds: 1200));
          continue;
        }

        if ((e.isClosed || e.isIdempotencyMismatch) && attempt < maxAttempts) {
          idempotencyKey = await menu.rotateIdempotencyKey(
            customerId: customerKey,
            packageId: packageId,
            phone: delivery.phone,
            address: delivery.address,
          );
          continue;
        }

        if (e.isConflict && e.payment != null) {
          final conflictPayment = e.payment!;
          if (conflictPayment.isPaid) {
            setState(() => _isPreparingQris = false);
            await _handlePaymentSucceeded(conflictPayment);
            return;
          }
          if (conflictPayment.isPending) {
            menu.setActivePendingPayment(conflictPayment);
            setState(() {
              _activePayment = conflictPayment;
              _isPreparingQris = false;
              _isExpiredUi = conflictPayment.isTimedOut();
            });
            _startTimers();
            return;
          }
        }

        setState(() {
          _isPreparingQris = false;
          _prepareError = e.message;
        });
        return;
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isPreparingQris = false;
          _prepareError = 'Gagal menyiapkan QRIS: $e';
        });
        return;
      }
    }
  }

  void _startTimers() {
    _stopTimers();
    if (!mounted ||
        _activePayment == null ||
        !_activePayment!.isPending ||
        _isExpiredUi) {
      return;
    }

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _handleCountdownTick();
    });
    _scheduleNextPoll();
  }

  void _handleCountdownTick() {
    if (!mounted || _activePayment == null || _isExpiredUi) {
      _countdownTimer?.cancel();
      return;
    }
    final remaining = _activePayment!.remainingTime();
    if (remaining <= Duration.zero) {
      _countdownTimer?.cancel();
      setState(() => _isExpiredUi = true);
      _syncPaymentStatusNow(userInitiated: false);
    } else {
      setState(() {});
    }
  }

  void _scheduleNextPoll() {
    _pollTimer?.cancel();
    if (!mounted ||
        _activePayment == null ||
        !_activePayment!.isPending ||
        _isExpiredUi ||
        _hasCompletedNavigation) {
      return;
    }
    _pollTimer = Timer(const Duration(seconds: 4), () async {
      await _syncPaymentStatusNow(userInitiated: false);
      _scheduleNextPoll();
    });
  }

  Future<void> _syncPaymentStatusNow({required bool userInitiated}) async {
    if (_isCheckingStatus || _activePayment == null || !mounted) return;
    final token = context.read<AuthController>().authToken;
    if (token == null || token.trim().isEmpty) return;

    setState(() => _isCheckingStatus = true);
    try {
      final updated = await _paymentService.getPaymentStatus(
        authToken: token,
        paymentId: _activePayment!.paymentId,
      );
      if (!mounted) return;

      final menu = context.read<NutriMealMenuController>();
      setState(() {
        _activePayment = updated;
        _isCheckingStatus = false;
      });

      if (updated.isPaid) {
        await _handlePaymentSucceeded(updated);
      } else if (updated.isExpiredStatus ||
          updated.isCancelled ||
          updated.isFailed ||
          updated.isTimedOut()) {
        _stopTimers();
        menu.setActivePendingPayment(null);
        await menu.clearCheckoutIdempotencyKey();
        if (!mounted) return;
        setState(() {
          _isExpiredUi = true;
        });
        if (userInitiated) {
          CenterFeedbackToast.showError(
            context,
            message: updated.isCancelled
                ? 'Pembayaran QRIS telah dibatalkan.'
                : 'Waktu pembayaran QRIS habis. Silakan buat kode QRIS baru.',
          );
        }
      } else {
        menu.setActivePendingPayment(updated);
        if (userInitiated) {
          CenterFeedbackToast.showInfo(
            context,
            message: 'Pembayaran belum diterima',
          );
        }
      }
    } on PaymentApiException catch (e) {
      if (!mounted) return;
      setState(() => _isCheckingStatus = false);
      if (userInitiated) {
        CenterFeedbackToast.showError(context, message: e.message);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isCheckingStatus = false);
      if (userInitiated) {
        CenterFeedbackToast.showError(
          context,
          message:
              'Gagal memeriksa status karena gangguan koneksi. Silakan coba lagi.',
        );
      }
    }
  }

  Future<void> _handlePaymentSucceeded(QrisPayment paidPayment) async {
    if (_hasCompletedNavigation || !mounted) return;
    _hasCompletedNavigation = true;
    _stopTimers();

    final auth = context.read<AuthController>();
    final menu = context.read<NutriMealMenuController>();
    menu.clearCart();
    menu.clearSubscriptionPackage();
    menu.setActivePendingPayment(null);
    await menu.clearCheckoutIdempotencyKey();

    try {
      if (paidPayment.isSubscription) {
        await NotificationService.instance.addSubscriptionNotification(
          orderId: paidPayment.orderId,
          packageName: paidPayment.packageName ?? 'Paket Langganan NutriMeal',
          schedule: paidPayment.deliveryTime ?? 'Mulai Senin, 11:30 WIB',
          customerId: auth.customerId,
        );
      } else {
        await NotificationService.instance.addOrderNotification(
          title: 'Pembayaran QRIS Lunas! (#${paidPayment.orderId})',
          body:
              'Pembayaran sebesar ${_formatRupiah(paidPayment.amount)} berhasil diverifikasi. Dapur segera menyiapkan pesananmu.',
          type: 'order',
          orderId: paidPayment.orderId,
          packageName: paidPayment.packageName ?? 'Pesanan NutriMeal',
          customerId: auth.customerId,
        );
      }
    } catch (_) {}

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentStatusScreen(
          payment: paidPayment,
          orderId: paidPayment.orderId,
          totalAmount: _formatRupiah(paidPayment.amount),
          packageName: paidPayment.packageName ?? 'Pesanan NutriMeal',
          paymentMethod: 'QRIS',
          firstMealName:
              paidPayment.firstMealName ??
              paidPayment.packageName ??
              'Menu Sehat NutriMeal',
          firstMealImage: paidPayment.firstMealImage ?? '',
          deliveryTime: paidPayment.deliveryTime ?? '11:30 - 13:00 WIB',
          isSubscription: paidPayment.isSubscription,
          customerAddress: paidPayment.customerAddress ?? '',
        ),
      ),
    );
  }

  Future<void> _confirmAndCancelPayment() async {
    if (_activePayment == null || _isCancelling) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Batalkan Pembayaran QRIS?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        content: Text(
          'Kode QRIS saat ini akan dibatalkan dan tidak bisa dipakai lagi. Menu di keranjang belanja Anda tetap tersimpan.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: const Color(0xFF475569),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(
              'Lanjutkan Pembayaran',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F8A50),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Ya, batalkan',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _executeCancelPayment(returnToPreviousScreen: true);
    }
  }

  Future<void> _executeCancelPayment({
    required bool returnToPreviousScreen,
    QrisPayment? targetPayment,
  }) async {
    final paymentToCancel = targetPayment ?? _activePayment;
    if (paymentToCancel == null || _isCancelling) return;
    final token = context.read<AuthController>().authToken;
    if (token == null || token.trim().isEmpty) return;

    setState(() => _isCancelling = true);
    try {
      await _paymentService.cancelPayment(
        authToken: token,
        paymentId: paymentToCancel.paymentId,
      );
      if (!mounted) return;
      _stopTimers();
      final menu = context.read<NutriMealMenuController>();
      menu.setActivePendingPayment(null);
      await menu.clearCheckoutIdempotencyKey();
      if (!mounted) return;
      setState(() {
        _activePayment = null;
        _conflictingPendingPayment = null;
        _isCancelling = false;
        _isExpiredUi = false;
      });
      CenterFeedbackToast.showInfo(
        context,
        message: 'Pembayaran QRIS dibatalkan. Keranjang Anda tetap aman.',
      );
      if (returnToPreviousScreen) {
        Navigator.pop(context);
      } else {
        await _createQrisAutomatically(forceNewKey: true);
      }
    } on PaymentApiException catch (e) {
      if (!mounted) return;
      setState(() => _isCancelling = false);
      if (e.isConflict && e.payment != null && e.payment!.isPaid) {
        await _handlePaymentSucceeded(e.payment!);
        return;
      }
      CenterFeedbackToast.showError(context, message: e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCancelling = false);
      CenterFeedbackToast.showError(
        context,
        message: 'Gagal membatalkan QRIS: $e',
      );
    }
  }

  Future<void> _handleBackAttempt() async {
    if (_activePayment == null || !_activePayment!.isPending || _isExpiredUi) {
      Navigator.pop(context);
      return;
    }

    final choice = await showDialog<String>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Pembayaran QRIS Masih Aktif',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        content: Text(
          'Anda masih memiliki kode QRIS dengan status Menunggu Pembayaran. Pilih tindakan:',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: const Color(0xFF475569),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, 'stay'),
            child: Text(
              'Lanjutkan Pembayaran',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F8A50),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, 'later'),
            child: Text(
              'Bayar nanti',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, 'cancel'),
            child: Text(
              'Batalkan QRIS',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: const Color(0xFFDC2626),
              ),
            ),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (choice == 'later') {
      context.read<NutriMealMenuController>().setActivePendingPayment(
        _activePayment,
      );
      Navigator.pop(context);
    } else if (choice == 'cancel') {
      await _executeCancelPayment(returnToPreviousScreen: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final isAuthenticated =
        auth.authToken != null && auth.authToken!.trim().isNotEmpty;
    final hasActivePending =
        _activePayment != null && _activePayment!.isPending && !_isExpiredUi;

    return PopScope(
      canPop: !hasActivePending,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && hasActivePending) {
          _handleBackAttempt();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              _buildHeader(hasActivePending),
              Expanded(
                child: !isAuthenticated
                    ? _buildUnauthenticatedState()
                    : _isPreparingQris
                    ? _buildLoadingState()
                    : _needsProfileCompletion
                    ? _buildIncompleteDeliveryState()
                    : _isEmptyCartError
                    ? _buildEmptyCartState()
                    : _conflictingPendingPayment != null
                    ? _buildConflictPendingState(_conflictingPendingPayment!)
                    : _prepareError != null
                    ? _buildErrorRetryState()
                    : _activePayment != null
                    ? _buildActiveQrisBody()
                    : _buildLoadingState(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool hasActivePending) {
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
            onTap: hasActivePending
                ? _handleBackAttempt
                : () => Navigator.pop(context),
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
              'Pembayaran QRIS',
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

  Widget _buildUnauthenticatedState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 48,
                color: Color(0xFF0F8A50),
              ),
              const SizedBox(height: 12),
              Text(
                'Login Diperlukan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Silakan login ke akun NutriMeal Anda untuk membuat kode QRIS dan melakukan pembayaran.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F8A50),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Login Sekarang',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Color(0xFF0F8A50)),
          const SizedBox(height: 14),
          Text(
            'Menyiapkan QRIS...',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Menghitung rincian tagihan & membuat kode QRIS dinamis',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncompleteDeliveryState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 46,
                color: Color(0xFFD97706),
              ),
              const SizedBox(height: 12),
              Text(
                'Lengkapi Alamat & Telepon',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mohon lengkapi alamat pengiriman dan nomor WhatsApp aktif Anda sebelum membuat kode QRIS.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  color: const Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () async {
                    await Navigator.pushNamed(context, '/address');
                    if (mounted) {
                      _bootstrapFlow();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F8A50),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Lengkapi Alamat & Nomor HP',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCartState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.shopping_cart_outlined,
                size: 46,
                color: Color(0xFF94A3B8),
              ),
              const SizedBox(height: 12),
              Text(
                'Keranjang Belanja Kosong',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tambahkan menu katering terlebih dahulu sebelum melanjutkan checkout.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F8A50),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Kembali ke Keranjang',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConflictPendingState(QrisPayment oldPending) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFDBA74)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.qr_code_2_rounded,
                size: 48,
                color: Color(0xFFD97706),
              ),
              const SizedBox(height: 12),
              Text(
                'Masih Ada QRIS Menunggu Pembayaran',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Isi keranjang berbeda dengan transaksi #${oldPending.orderId} (${_formatRupiah(oldPending.amount)}). Batalkan QRIS lama terlebih dahulu untuk membuat QRIS baru.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  color: const Color(0xFF475569),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _activePayment = oldPending;
                      _conflictingPendingPayment = null;
                    });
                    _startTimers();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F8A50),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Lanjutkan QRIS Lama',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: _isCancelling
                      ? null
                      : () => _executeCancelPayment(
                          returnToPreviousScreen: false,
                          targetPayment: oldPending,
                        ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _isCancelling
                        ? 'Membatalkan QRIS Lama...'
                        : 'Batalkan QRIS Lama & Buat Baru',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorRetryState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFECACA)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 44,
                color: Color(0xFFDC2626),
              ),
              const SizedBox(height: 12),
              Text(
                'Gagal Menyiapkan QRIS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _prepareError ?? 'Terjadi gangguan jaringan.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  color: const Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => _createQrisAutomatically(forceNewKey: false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F8A50),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Coba Lagi',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _priceRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveQrisBody() {
    final payment = _activePayment!;
    final remaining = payment.remainingTime();
    final isExpired =
        _isExpiredUi ||
        payment.isExpiredStatus ||
        payment.isCancelled ||
        payment.isFailed ||
        remaining <= Duration.zero;
    final isWarningTime = remaining.inSeconds > 0 && remaining.inMinutes < 2;

    return RefreshIndicator(
      color: const Color(0xFF0F8A50),
      onRefresh: () => _syncPaymentStatusNow(userInitiated: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Banner Status Besar (Oranye "Menunggu Pembayaran" atau Merah "QRIS Kedaluwarsa")
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isExpired
                    ? const Color(0xFFFEF2F2)
                    : const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isExpired
                      ? const Color(0xFFFECACA)
                      : const Color(0xFFFDBA74),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isExpired
                        ? Icons.timer_off_rounded
                        : Icons.hourglass_top_rounded,
                    size: 28,
                    color: isExpired
                        ? const Color(0xFFDC2626)
                        : const Color(0xFFEA580C),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isExpired
                              ? 'QRIS Kedaluwarsa'
                              : 'Menunggu Pembayaran',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: isExpired
                                ? const Color(0xFFB91C1C)
                                : const Color(0xFFC2410C),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isExpired
                              ? 'Batas waktu QRIS Order #${payment.orderId} telah berakhir.'
                              : 'Order #${payment.orderId} • Selesaikan sebelum batas waktu habis',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isExpired)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFED7AA)),
                      ),
                      child: Text(
                        _formatCountdown(remaining),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: isWarningTime
                              ? const Color(0xFFDC2626)
                              : const Color(0xFFEA580C),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (isExpired) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.qr_code_rounded,
                      size: 56,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'QRIS Kedaluwarsa',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Kode QR sebelumnya tidak dapat digunakan lagi. Tekan tombol di bawah untuk membuat QRIS baru.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: const Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _activePayment = null;
                            _isExpiredUi = false;
                          });
                          _createQrisAutomatically(forceNewKey: true);
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(
                          'Buat QRIS Baru',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F8A50),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Card QRIS Dinamis
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Total Pembayaran',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatRupiah(payment.amount),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F8A50),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child:
                          (payment.qrString != null &&
                              payment.qrString!.trim().isNotEmpty)
                          ? QrImageView(
                              data: payment.qrString!,
                              version: QrVersions.auto,
                              size: 220,
                              backgroundColor: Colors.white,
                            )
                          : (payment.qrUrl != null &&
                                payment.qrUrl!.trim().isNotEmpty)
                          ? Image.network(
                              payment.qrUrl!,
                              width: 220,
                              height: 220,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => const SizedBox(
                                width: 220,
                                height: 220,
                                child: Center(
                                  child: Text('QRIS tidak dapat dimuat'),
                                ),
                              ),
                            )
                          : const SizedBox(
                              width: 220,
                              height: 220,
                              child: Center(
                                child: Text('Data QRIS belum tersedia'),
                              ),
                            ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Scan dengan GoPay, OVO, DANA, ShopeePay, atau Mobile Banking berlogo QRIS',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: const Color(0xFF475569),
                        height: 1.4,
                      ),
                    ),
                    if (kDebugMode &&
                        payment.qrUrl != null &&
                        payment.qrUrl!.trim().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      TextButton.icon(
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: payment.qrUrl!),
                          );
                          CenterFeedbackToast.showSuccess(
                            context,
                            message: 'QR URL sandbox disalin ke clipboard',
                          );
                        },
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        label: Text(
                          'Salin QR URL (Debug Sandbox)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Rincian Nominal Server
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rincian Tagihan Server',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (payment.packageName != null &&
                        payment.packageName!.isNotEmpty) ...[
                      Text(
                        payment.packageName!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F8A50),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    _priceRow('Subtotal', _formatRupiah(payment.subtotal)),
                    if (payment.shippingFee > 0) ...[
                      const SizedBox(height: 6),
                      _priceRow(
                        'Ongkos Kirim',
                        _formatRupiah(payment.shippingFee),
                      ),
                    ],
                    if (payment.tax > 0) ...[
                      const SizedBox(height: 6),
                      _priceRow('Pajak (5%)', _formatRupiah(payment.tax)),
                    ],
                    if (payment.discount > 0) ...[
                      const SizedBox(height: 6),
                      _priceRow(
                        payment.voucherCode != null
                            ? 'Diskon (${payment.voucherCode})'
                            : 'Diskon',
                        '-${_formatRupiah(payment.discount)}',
                        valueColor: const Color(0xFF16A34A),
                      ),
                    ],
                    const Divider(height: 18),
                    _priceRow(
                      'Total Tagihan',
                      _formatRupiah(payment.amount),
                      valueColor: const Color(0xFF0F8A50),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Petunjuk Pembayaran QRIS
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Petunjuk Pembayaran QRIS',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _instructionStep(
                      '1',
                      'Buka aplikasi e-wallet atau m-banking yang mendukung QRIS.',
                    ),
                    const SizedBox(height: 6),
                    _instructionStep(
                      '2',
                      'Pilih menu Scan QR dan arahkan kamera ke kode QR di atas.',
                    ),
                    const SizedBox(height: 6),
                    _instructionStep(
                      '3',
                      'Pastikan nama merchant NutriMeal dan nominal sudah sesuai, lalu konfirmasi.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Refresh Status
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isCheckingStatus
                      ? null
                      : () => _syncPaymentStatusNow(userInitiated: true),
                  icon: _isCheckingStatus
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.refresh_rounded),
                  label: Text(
                    _isCheckingStatus
                        ? 'Memeriksa Status...'
                        : 'Refresh Status',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F8A50),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () {
                          context
                              .read<NutriMealMenuController>()
                              .setActivePendingPayment(_activePayment);
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textDark,
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Bayar nanti',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: _isCancelling
                            ? null
                            : _confirmAndCancelPayment,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFDC2626),
                          side: const BorderSide(color: Color(0xFFDC2626)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          _isCancelling ? 'Membatalkan...' : 'Batalkan QRIS',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _instructionStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFFDCFCE7),
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F8A50),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: const Color(0xFF475569),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
