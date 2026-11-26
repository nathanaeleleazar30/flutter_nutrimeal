import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../services/api_service.dart';
import '../../core/widgets/center_feedback_toast.dart';
import '../address_screen.dart';
import 'langganan_katalog_screen.dart';

class LanggananSayaScreen extends StatefulWidget {
  final bool showBottomNav;

  const LanggananSayaScreen({super.key, this.showBottomNav = true});

  @override
  State<LanggananSayaScreen> createState() => _LanggananSayaScreenState();
}

class _LanggananSayaScreenState extends State<LanggananSayaScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _subscription;
  bool _isAutoRenew = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSubscription();
    });
  }

  Future<void> _loadSubscription() async {
    final auth = context.read<AuthController>();
    final customerId = auth.customerId;
    setState(() => _isLoading = true);

    try {
      final list = await ApiService.instance.fetchSubscriptions(customerId);
      if (mounted) {
        setState(() {
          // Cari langganan yang aktif atau dijeda
          _subscription = list.firstWhere(
            (s) => (s['status'] ?? '').toString() != 'Selesai',
            orElse: () => list.isNotEmpty ? list.first : {},
          );
          if (_subscription?.isEmpty ?? true) {
            _subscription = null;
          }
          if (_subscription != null) {
            _isAutoRenew =
                _subscription!['auto_renew'] == 1 ||
                _subscription!['auto_renew'] == true;
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleAutoRenew(bool val) async {
    if (_subscription == null) return;
    final subId = _subscription!['id']?.toString() ?? '';
    setState(() => _isAutoRenew = val);

    final ok = await ApiService.instance.updateSubscriptionStatus(
      subId,
      autoRenew: val,
    );

    if (mounted) {
      if (ok) {
        CenterFeedbackToast.showSuccess(
          context,
          message:
              'Perpanjangan otomatis berhasil ${val ? "diaktifkan" : "dimatikan"}',
        );
      } else {
        CenterFeedbackToast.showError(
          context,
          message: 'Gagal memperbarui status perpanjangan otomatis',
        );
      }
    }
  }

  Future<void> _togglePause() async {
    if (_subscription == null) return;
    final subId = _subscription!['id']?.toString() ?? '';
    final currentStatus = _subscription!['status']?.toString() ?? 'Aktif';
    final newStatus = currentStatus == 'Aktif' ? 'Dijeda' : 'Aktif';

    final ok = await ApiService.instance.updateSubscriptionStatus(
      subId,
      status: newStatus,
    );

    if (ok) {
      setState(() {
        _subscription!['status'] = newStatus;
      });
    }

    if (mounted) {
      CenterFeedbackToast.showSuccess(
        context,
        message: 'Status langganan berhasil diubah menjadi: $newStatus',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              child: RefreshIndicator(
                onRefresh: _loadSubscription,
                color: AppColors.primaryGreen,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: _isLoading
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 60),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        )
                      : _subscription == null
                      ? _buildEmptySubscriptionState()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Active Package Card
                            _buildActivePackageCard(),
                            const SizedBox(height: 20),

                            // 2. Jadwal Hari Ini Section
                            _buildTodayScheduleSection(),
                            const SizedBox(height: 20),

                            // 3. Alamat Pengantaran Section
                            _buildDeliveryAddressSection(context),
                            const SizedBox(height: 20),

                            // 4. Perpanjang Otomatis Section
                            _buildAutoRenewSection(),
                            const SizedBox(height: 20),

                            // 5. Button: Jadwal & Menu Bulanan
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/jadwal');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0F8A50),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: Text(
                                  'Jadwal & Menu Bulanan',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySubscriptionState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              color: Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              size: 42,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Belum Ada Langganan Aktif',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nikmati makanan katering sehat terjadwal setiap hari langsung diantar ke rumah atau kantormu.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFF64748B),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 22),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LanggananKatalogScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F8A50),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Lihat Katalog Paket Langganan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
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
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/home', (route) => false);
              }
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
              'Langganan Saya',
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

  Widget _buildActivePackageCard() {
    final sub = _subscription!;
    final pkgName = sub['package_name'] ?? 'Paket Langganan';
    final slot = sub['meal_slot'] ?? 'Siang & Malam';
    final status = sub['status'] ?? 'Aktif';
    final isPaused = status == 'Dijeda';

    final totalDays = int.tryParse('${sub['total_days']}') ?? 30;
    final daysRemaining = int.tryParse('${sub['days_remaining']}') ?? 0;
    final daysUsed = (totalDays - daysRemaining).clamp(0, totalDays);
    final progressVal = totalDays > 0
        ? (daysUsed / totalDays).clamp(0.0, 1.0)
        : 0.0;
    final percent = (progressVal * 100).round();

    final startDate = sub['start_date']?.toString() ?? '-';
    final endDate = sub['end_date']?.toString() ?? '-';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPaused ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isPaused
                      ? const Color(0xFFFEF3C7)
                      : const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isPaused
                            ? const Color(0xFFD97706)
                            : const Color(0xFF16A34A),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isPaused ? 'Langganan Dijeda' : 'Aktif Berlangganan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isPaused
                            ? const Color(0xFF92400E)
                            : const Color(0xFF166534),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: _togglePause,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    isPaused ? 'Lanjutkan' : 'Jeda',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isPaused
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFD97706),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Title
          Text(
            pkgName,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),

          // Subtitle
          Text(
            'Slot: $slot • Sisa $daysRemaining dari $totalDays Hari',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 14),

          // Progress Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '$daysUsed dari $totalDays Hari Berjalan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$percent% Selesai',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F8A50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progressVal,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF0F8A50),
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),

          // Dates Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Mulai: $startDate',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: const Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Berakhir: $endDate',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: const Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodayScheduleSection() {
    final sub = _subscription!;
    final timeSlot =
        sub['delivery_time_slot'] ?? '11.30 – 13.00 WIB (Slot Utama)';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.restaurant_rounded,
                  color: Color(0xFF0F8A50),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Waktu Pengantaran',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                color: Color(0xFF0F8A50),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  timeSlot,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryAddressSection(BuildContext context) {
    final sub = _subscription;
    final address = sub?['address'] ?? 'Alamat pengantaran terdaftar';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alamat Pengantaran',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: Color(0xFF0F8A50),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Lokasi Pengiriman',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddressScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Ganti',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F8A50),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: const Color(0xFF64748B),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAutoRenewSection() {
    return Container(
      padding: const EdgeInsets.all(14),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Perpanjang Otomatis',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Hemat +10%',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF166534),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Tagihan otomatis diperpanjang di akhir siklus.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isAutoRenew,
            onChanged: _toggleAutoRenew,
            activeThumbColor: const Color(0xFF0F8A50),
          ),
        ],
      ),
    );
  }
}
