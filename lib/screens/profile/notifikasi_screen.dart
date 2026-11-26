import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../services/api_service.dart';
import '../../services/notification_service.dart';
import '../../core/widgets/center_feedback_toast.dart';
import '../order/order_tracking_screen.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  int _selectedFilterIndex = 0; // 0: Semua, 1: Pesanan, 2: Promo & Diskon
  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });
  }

  Future<void> _loadNotifications() async {
    final auth = context.read<AuthController>();
    final customerId = auth.customerId;
    setState(() => _isLoading = true);

    try {
      final list = await ApiService.instance.fetchNotifications(
        customerId ?? '',
      );
      if (mounted) {
        setState(() {
          _notifications = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        final fallback = NotificationService.instance.inMemoryNotifications;
        setState(() {
          _notifications = List.from(fallback);
          _isLoading = false;
        });
      }
    }
  }

  int get _unreadCount => _notifications
      .where((n) => n['is_read'] != true && n['is_read'] != 1)
      .length;

  Future<void> _markAllAsRead() async {
    final auth = context.read<AuthController>();
    final customerId = auth.customerId;
    if (customerId != null && customerId.isNotEmpty) {
      await ApiService.instance.markAllNotificationsAsRead(customerId);
    }
    setState(() {
      for (final n in _notifications) {
        n['is_read'] = true;
      }
    });
    if (mounted) {
      CenterFeedbackToast.showSuccess(
        context,
        message: 'Semua notifikasi telah ditandai sebagai dibaca',
      );
    }
  }

  Future<void> _markSingleAsRead(Map<String, dynamic> item) async {
    if (item['is_read'] == true || item['is_read'] == 1) return;
    final auth = context.read<AuthController>();
    final customerId = auth.customerId ?? '';
    final id = item['id'];
    if (id != null && customerId.isNotEmpty) {
      await ApiService.instance.markNotificationAsRead(
        id is int ? id : int.tryParse('$id') ?? 0,
        customerId,
      );
    }
    setState(() {
      item['is_read'] = true;
    });
  }

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_selectedFilterIndex == 1) {
      return _notifications.where((n) {
        final t = (n['type'] ?? '').toString().toLowerCase();
        return t == 'order' ||
            t == 'pesanan' ||
            t == 'subscription' ||
            t == 'langganan';
      }).toList();
    }
    if (_selectedFilterIndex == 2) {
      return _notifications.where((n) {
        final t = (n['type'] ?? '').toString().toLowerCase();
        return t == 'promo' || t == 'voucher' || t == 'discount';
      }).toList();
    }
    return _notifications;
  }

  String _formatDate(dynamic dateVal) {
    if (dateVal == null) return '';
    try {
      final dt = DateTime.parse(dateVal.toString());
      final now = DateTime.now();
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        final hour = dt.hour.toString().padLeft(2, '0');
        final min = dt.minute.toString().padLeft(2, '0');
        return 'Hari ini, $hour:$min WIB';
      }
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return dateVal.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredNotifications;

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
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'Notifikasi',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadNotifications,
          color: AppColors.primaryGreen,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter Chips Row
                _buildFilterChips(),
                const SizedBox(height: 14),

                // Unread Status Bar
                _buildStatusBar(),
                const SizedBox(height: 18),

                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  )
                else if (filtered.isEmpty)
                  _buildEmptyState()
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 12),
                    itemBuilder: (ctx, idx) =>
                        _buildNotificationCard(filtered[idx]),
                  ),

                const SizedBox(height: 24),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: Color(0xFFCBD5E1),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Semua pembaruan sudah ditampilkan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          color: const Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: Color(0xFFCBD5E1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
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
              color: Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 40,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Notifikasi',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pemberitahuan status pesanan dan promo makanan sehat akan muncul di sini.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> item) {
    final isUnread = item['is_read'] != true && item['is_read'] != 1;
    final type = (item['type'] ?? 'general').toString().toLowerCase();

    IconData iconData = Icons.notifications_rounded;
    Color iconBg = const Color(0xFFDCFCE7);
    Color iconColor = const Color(0xFF166534);

    if (type == 'order' || type == 'pesanan') {
      iconData = Icons.two_wheeler_rounded;
      iconBg = const Color(0xFFDCFCE7);
      iconColor = const Color(0xFF166534);
    } else if (type == 'subscription' || type == 'langganan') {
      iconData = Icons.calendar_month_rounded;
      iconBg = const Color(0xFFEEF2FF);
      iconColor = const Color(0xFF4338CA);
    } else if (type == 'promo' || type == 'voucher') {
      iconData = Icons.local_offer_rounded;
      iconBg = const Color(0xFFFEF3C7);
      iconColor = const Color(0xFFB45309);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          _markSingleAsRead(item);
          final route = item['route']?.toString();
          if (type == 'subscription' || type == 'langganan') {
            Navigator.pushNamed(context, route ?? '/langganan-saya');
          } else if (type == 'order' || type == 'pesanan') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderTrackingScreen(
                  orderId: item['order_id']?.toString() ?? '',
                  packageName:
                      item['package_name']?.toString() ??
                      'Paket Menu NutriMeal',
                  estimatedMinutes: item['estimated_minutes'] is int
                      ? item['estimated_minutes']
                      : int.tryParse('${item['estimated_minutes']}') ?? 30,
                  isSubscription: false,
                ),
              ),
            );
          } else if (route != null && route.isNotEmpty) {
            Navigator.pushNamed(context, route);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isUnread
                  ? const Color(0xFF86EFAC)
                  : const Color(0xFFE2E8F0),
              width: isUnread ? 1.2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isUnread ? 0.04 : 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: iconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(iconData, color: iconColor, size: 22),
                  ),
                  if (isUnread)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item['title'] ?? 'Pemberitahuan',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: isUnread
                                  ? FontWeight.w800
                                  : FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        Text(
                          _formatDate(item['created_at']),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            color: const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['body'] ?? '',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: isUnread
                            ? const Color(0xFF334155)
                            : const Color(0xFF64748B),
                        height: 1.35,
                      ),
                    ),
                    if (type == 'subscription' || type == 'langganan') ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFC7D2FE)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.event_available_rounded,
                              size: 15,
                              color: Color(0xFF4338CA),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                item['delivery_schedule'] ??
                                    'Langganan Aktif • Mulai Senin 11:30 WIB',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF4338CA),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (item['estimated_minutes'] != null ||
                        item['order_id'] != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF86EFAC)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.delivery_dining_rounded,
                              size: 15,
                              color: Color(0xFF166534),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Estimasi Tiba: ${item['estimated_minutes'] ?? 30} Menit • Lacak Pesanan',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF166534),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            index: 0,
            label: 'Semua',
            badgeText: _unreadCount > 0 ? '$_unreadCount' : null,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            index: 1,
            label: 'Pesanan',
            icon: Icons.sync_alt_rounded,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            index: 2,
            label: 'Promo & Diskon',
            icon: Icons.local_offer_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required int index,
    required String label,
    String? badgeText,
    IconData? icon,
  }) {
    final bool isSelected = _selectedFilterIndex == index;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          setState(() {
            _selectedFilterIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF0F5132)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(22),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF0F5132).withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                ),
              ),
              if (badgeText != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badgeText,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF22C55E),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$_unreadCount Belum Dibaca',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        if (_unreadCount > 0)
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: _markAllAsRead,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  'Tandai Semua Dibaca',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
