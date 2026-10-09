import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

class AdminChatMessage {
  final bool isUser;
  final String text;
  final String time;
  final bool hasTicketCard;
  final List<String>? chips;

  const AdminChatMessage({
    required this.isUser,
    required this.text,
    required this.time,
    this.hasTicketCard = false,
    this.chips,
  });
}

class AdminChatScreen extends StatefulWidget {
  final bool isTab;

  const AdminChatScreen({super.key, this.isTab = false});

  @override
  State<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<AdminChatMessage> _messages = [
    const AdminChatMessage(
      isUser: false,
      text:
          'Halo Andi! 👋 Selamat datang di layanan NutriCare! Saya Sarah dari tim Customer Care & Ahli Gizi NutriMeal. Ada kendala jadwal pengiriman katering, perubahan alamat, atau konsultasi menu diet yang bisa saya bantu hari ini?',
      time: '10:15',
      chips: [
        '📍 Ubah Alamat Pengiriman',
        '⚡ Ganti Jadwal Makan Siang',
        '📋 Konsultasi Alergi Menu',
      ],
    ),
    const AdminChatMessage(
      isUser: true,
      text:
          'Halo Kak Sarah, besok siang jam 11:30 katering saya mau dialihkan ke kantor di SCBD Lot 18 lantai 12 apa masih sempat diproses? Soalnya pagi ada rapat dadakan.',
      time: '10:17',
    ),
    const AdminChatMessage(
      isUser: false,
      text:
          'Tentu bisa Kak Andi! Perubahan alamat makan siang untuk besok kami terima maksimal pukul 19:00 WIB malam ini. Sudah kami catat dan update ke sistem kurir katering ya.',
      time: '10:19',
      hasTicketCard: true,
    ),
    const AdminChatMessage(
      isUser: true,
      text:
          'Mantap, terima kasih banyak Kak Sarah! Kurirnya tolong ingatkan jangan pakai sendok plastik ya, di kantor sudah ada cutlery.',
      time: '10:20',
    ),
    const AdminChatMessage(
      isUser: false,
      text:
          'Siap Kak Andi!, catatan zero-waste (tanpa alat makan plastik) sudah kami tambahkan ke slip pengiriman kurir. Selamat beristirahat dan menikmati menu NutriMeal besok! 🌱',
      time: '10:21',
    ),
  ];

  final List<String> _quickBottomSuggestions = [
    '🛵 Cek posisi kurir hari ini',
    '⏸ Pause langganan weekend',
    '📄 Minta invoice langganan',
  ];

  void _sendMessage([String? customText]) {
    final text = customText ?? _textController.text.trim();
    if (text.isEmpty) return;

    final now = TimeOfDay.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    setState(() {
      _messages.add(
        AdminChatMessage(
          isUser: true,
          text: text,
          time: timeStr,
        ),
      );
    });

    if (customText == null) {
      _textController.clear();
    }

    _scrollToBottom();

    // CS Admin auto-reply simulation
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _messages.add(
          AdminChatMessage(
            isUser: false,
            text:
                'Terima kasih pesannya Kak Andi! Permintaan Anda sedang kami tindak lanjuti bersama tim katering kami.',
            time: timeStr,
          ),
        );
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: widget.isTab
            ? Padding(
                padding: const EdgeInsets.only(left: 8),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          'N',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF16A34A),
                          ),
                        ),
                        Positioned(
                          top: 5,
                          right: 4,
                          child: Container(
                            width: 5.5,
                            height: 5.5,
                            decoration: const BoxDecoration(
                              color: Color(0xFF22C55E),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : IconButton(
                icon: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: AppColors.textDark,
                  ),
                ),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.pop(context);
                  } else {
                    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                  }
                },
              ),
        titleSpacing: widget.isTab ? 4 : 0,
        title: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=200&auto=format&fit=crop',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFDCFCE7),
                      child: const Icon(Icons.support_agent_rounded, color: AppColors.primaryGreen),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admin NutriCare',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Customer Care & Ahli Gizi • ',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        'Online',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_outlined, color: Color(0xFF64748B), size: 22),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF64748B), size: 22),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pushNamed('/profile'),
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_rounded, color: AppColors.primaryGreen, size: 18),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Separator
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Hari ini, 24 Oktober 2024',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
          ),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageItem(message);
              },
            ),
          ),

          // Quick Suggestion Chips
          _buildQuickSuggestions(),

          // Bottom Input Bar
          _buildBottomInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageItem(AdminChatMessage message) {
    if (message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 40),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF15803D),
            borderRadius: BorderRadius.circular(18).copyWith(
              bottomRight: const Radius.circular(4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                message.text,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.time,
                    style: const TextStyle(fontSize: 10, color: Colors.white70),
                  ),
                  const SizedBox(width: 4),
                  const Text('• Dibaca', style: TextStyle(fontSize: 10, color: Colors.white70)),
                  const SizedBox(width: 3),
                  const Icon(Icons.done_all_rounded, size: 12, color: Color(0xFF86EFAC)),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // CS Message
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14, right: 26),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=200&auto=format&fit=crop',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFDCFCE7),
                  child: const Icon(Icons.support_agent_rounded, color: AppColors.primaryGreen, size: 18),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18).copyWith(
                        topLeft: const Radius.circular(4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.text,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: AppColors.textDark,
                            height: 1.45,
                          ),
                        ),

                        // Embedded Delivery Ticket Card
                        if (message.hasTicketCard) ...[
                          const SizedBox(height: 12),
                          _buildDeliveryTicketCard(),
                        ],

                        const SizedBox(height: 6),
                        Text(
                          message.time,
                          style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),

                  // Quick Action Chips below message
                  if (message.chips != null) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: message.chips!.map((chip) {
                        return GestureDetector(
                          onTap: () => _sendMessage(chip),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Text(
                              chip,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF334155),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryTicketCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen, size: 16),
                  const SizedBox(width: 5),
                  Text(
                    'Status Tiket Permintaan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '#TIK-8492',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Green Update Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_rounded, color: AppColors.primaryGreen, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Berhasil Diperbarui di Sistem Pengiriman',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF15803D),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Ticket Info Rows
          _buildTicketRow('Paket Katering', 'Healthy Diet 14 Hari (#NM-8492)'),
          const SizedBox(height: 5),
          _buildTicketRow('Pengiriman', 'Makan Siang (Besok, 25 Okt 2024)'),
          const SizedBox(height: 5),
          _buildTicketRow('Alamat Baru', 'Pacific Century Place Lt. 12, SCBD\nJakarta Selatan'),
          const SizedBox(height: 5),
          _buildTicketRow('Estimasi Tiba', '11:15 - 11:45 WIB', isHighlight: true),
          const SizedBox(height: 10),

          // Mini Dish Preview
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Image.network(
                      'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=800&auto=format&fit=crop',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFFDCFCE7),
                        child: const Icon(Icons.restaurant_rounded, color: AppColors.primaryGreen),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Grilled Salmon Rice',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        'Bebas Gluten • 480 kkal',
                        style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Termasuk Paket',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0284C7),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Courier note
          Text(
            '📌 Instruksi Kurir: Titipkan di resepsionis lobi utama lantai 1',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 10),

          // Quick Action Buttons
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildMiniActionButton('Hubungi Kurir Langsung', Icons.phone_rounded),
              _buildMiniActionButton('Tambah Catatan Khusus', Icons.edit_note_rounded),
              _buildMiniActionButton('Konfirmasi WhatsApp', Icons.chat_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTicketRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF64748B)),
          ),
        ),
        const Text(': ', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
              color: isHighlight ? AppColors.primaryGreen : AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniActionButton(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primaryGreen),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSuggestions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt_rounded, size: 14, color: AppColors.primaryGreen),
              const SizedBox(width: 4),
              Text(
                'Saran pesan cepat:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _quickBottomSuggestions.map((sug) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(sug),
                    onPressed: () => _sendMessage(sug),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    labelStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _textController,
                  onSubmitted: (val) => _sendMessage(),
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textDark),
                  decoration: InputDecoration(
                    hintText: 'Tulis pesan ke NutriCare...',
                    hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppColors.textMuted),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _sendMessage(),
              child: Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
