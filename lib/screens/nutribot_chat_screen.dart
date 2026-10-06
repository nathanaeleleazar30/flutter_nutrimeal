import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

class ChatMessage {
  final bool isUser;
  final String text;
  final String time;
  final bool hasMacroCard;
  final bool hasMenuCard;
  final List<String>? chips;

  const ChatMessage({
    required this.isUser,
    required this.text,
    required this.time,
    this.hasMacroCard = false,
    this.hasMenuCard = false,
    this.chips,
  });
}

class NutriBotChatScreen extends StatefulWidget {
  final bool isTab;

  const NutriBotChatScreen({super.key, this.isTab = false});

  @override
  State<NutriBotChatScreen> createState() => _NutriBotChatScreenState();
}

class _NutriBotChatScreenState extends State<NutriBotChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [
    const ChatMessage(
      isUser: false,
      text:
          'Halo Andi! 👋 Saya NutriBot, asisten AI pribadi kamu. Tanyakan apa saja seputar hitungan kalori, rekomendasi menu sehat NutriMeal harian, atau tips diet sesuai targetmu hari ini.',
      time: '18:40',
      chips: [
        '🥗 Hitung kalori makan siang',
        '⚡ Menu rendah garam',
        '🍗 Protein tinggi > 40g',
      ],
    ),
    const ChatMessage(
      isUser: true,
      text:
          'Halo NutriBot, hari ini jatah kalori saya sisa 520 kkal. Mau tanya, apakah Salmon Poke Bowl cocok buat makan malam saya dan berapa rincian makronya?',
      time: '18:42',
    ),
    const ChatMessage(
      isUser: false,
      text:
          'Pilihan yang sangat tepat, Andi! 🥗 Poke Bowl Salmon sangat pas untuk sisa target kalori harianmu.',
      time: '18:43',
      hasMacroCard: true,
      hasMenuCard: true,
      chips: [
        'Cek alergen hidangan ini',
        'Ganti saus rendah kalori',
        'Rekomendasi minuman',
      ],
    ),
    const ChatMessage(
      isUser: true,
      text:
          'Kalau mau ganti dressing wijen sangrai ke lemon olive oil bisa potong berapa kalori?',
      time: '18:44',
    ),
    const ChatMessage(
      isUser: false,
      text:
          'Bisa menghemat sekitar 65 kkal dan mengurangi 5g lemak jenuh! 🍋 Pilihan cerdas untuk defisit kalori ringan tanpa mengubah cita rasa segar hidangan.',
      time: '18:45',
    ),
  ];

  final List<String> _quickBottomSuggestions = [
    '🥑 Berapa kalori alpukat 100g?',
    '🥗 Menu bebas gluten',
    '💪 Rekomendasi camilan tinggi protein',
  ];

  void _sendMessage([String? customText]) {
    final text = customText ?? _textController.text.trim();
    if (text.isEmpty) return;

    final now = TimeOfDay.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    setState(() {
      _messages.add(
        ChatMessage(
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

    // AI smart reply simulation
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      String reply =
          'Rekomendasi terbaik untuk target diet sehatmu: Kombinasikan serat tinggi dengan protein tanpa lemak untuk rasa kenyang lebih lama!';
      if (text.toLowerCase().contains('alpukat')) {
        reply =
            'Alpukat 100g mengandung sekitar 160 kkal, 15g lemak tak jenuh ganda yang sangat baik untuk jantung, dan 7g serat pangan.';
      } else if (text.toLowerCase().contains('gluten')) {
        reply =
            'Menu bebas gluten kami disiapkan di dapur higienis terpisah! Coba Pepes Tongkol Rempah atau Grilled Salmon Quinoa Bowl.';
      }

      setState(() {
        _messages.add(
          ChatMessage(
            isUser: false,
            text: reply,
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
            ? null
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
                onPressed: () => Navigator.pop(context),
              ),
        titleSpacing: widget.isTab ? 16 : 0,
        title: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.smart_toy_rounded, color: AppColors.primaryGreen, size: 24),
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
                    'NutriBot AI',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    'Asisten Nutrisi & Kalori 24/7',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
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

          // Chat Messages List
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

          // Bottom Quick Suggestions
          _buildQuickSuggestions(),

          // Bottom Input Bar
          _buildBottomInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage message) {
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

    // AI Message
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14, right: 30),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.smart_toy_rounded, color: AppColors.primaryGreen, size: 18),
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

                        // Embedded Macro Breakdown Card
                        if (message.hasMacroCard) ...[
                          const SizedBox(height: 12),
                          _buildMacroBreakdownCard(),
                        ],

                        // Embedded Menu Recommendation Card
                        if (message.hasMenuCard) ...[
                          const SizedBox(height: 12),
                          _buildMenuRecommendationCard(),
                        ],

                        const SizedBox(height: 6),
                        Text(
                          message.time,
                          style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),

                  // Quick Chips below message
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

  Widget _buildMacroBreakdownCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.pie_chart_rounded, size: 16, color: AppColors.primaryGreen),
                  const SizedBox(width: 6),
                  Text(
                    'Total Kalori',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              Text(
                '420 kkal',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Sisa aman +100 kkal untuk snack malam',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF16A34A),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildMacroRow('Protein', '38g (Pemulihan otot)', 0.75, AppColors.primaryGreen),
          const SizedBox(height: 6),
          _buildMacroRow('Karbohidrat Kompleks', '42g (GI rendah)', 0.65, const Color(0xFF0284C7)),
          const SizedBox(height: 6),
          _buildMacroRow('Lemak Baik (Omega-3)', '14g (Alpukat & Salmon)', 0.40, const Color(0xFFE11D48)),
          const SizedBox(height: 6),
          _buildMacroRow('Serat Pangan', '6g', 0.50, const Color(0xFF9333EA)),
        ],
      ),
    );
  }

  Widget _buildMacroRow(String label, String value, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF475569)),
            ),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textDark),
            ),
          ],
        ),
        const SizedBox(height: 2),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFFE2E8F0),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuRecommendationCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Menu Rekomendasi',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 58,
                  height: 58,
                  child: Image.network(
                    'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=800&auto=format&fit=crop',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFDCFCE7),
                      child: const Icon(Icons.lunch_dining_rounded, color: AppColors.primaryGreen),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Poke Bowl Salmon',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      'Segar, Quinoa & Kaya Omega-3',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Rp 45.000',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '🌱 Kaya asam lemak omega-3 baik untuk kesehatan jantung dan otak',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.5,
              color: const Color(0xFF047857),
              height: 1.3,
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
                'Saran pertanyaan cepat:',
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
                    hintText: 'Tanya kalori, menu, atau diet...',
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
