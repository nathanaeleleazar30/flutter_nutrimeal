import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/menu_controller.dart';
import '../core/constants/app_colors.dart';
import 'payment_status_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
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
    final controller = context.watch<NutriMealMenuController>();
    final amountText = controller.grandTotal > 0 ? _formatRupiah(controller.grandTotal) : 'Rp170.347';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Top App Bar
            _buildHeader(context),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card 1: Total Pembayaran & Batas Waktu
                    _buildPaymentHeaderCard(amountText),
                    const SizedBox(height: 16),

                    // Card 2: QRIS Card
                    _buildQrisCard(),
                    const SizedBox(height: 20),

                    // Petunjuk Pembayaran QRIS
                    _buildInstructionsSection(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Sticky Bottom Action Buttons
            _buildBottomButtons(context, amountText),
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
              'Pembayaran',
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

  Widget _buildPaymentHeaderCard(String amountText) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          // Top Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Pembayaran',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
              Text(
                'Batas Waktu',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Total & Timer Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    amountText,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: amountText.replaceAll('Rp', '').replaceAll('.', '')));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nominal disalin ke clipboard'),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.copy_rounded,
                      size: 14,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 12, color: Color(0xFF166534)),
                    const SizedBox(width: 4),
                    Text(
                      '23 : 58 : 55',
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
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          // Jatuh tempo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Jatuh tempo',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
              Text(
                '12 Oktober 2026, 22:26 WIB',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQrisCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // QRIS Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'QRIS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'QR Code Standar',
                    style: GoogleFonts.plusJakartaSans(fontSize: 8, fontWeight: FontWeight.w700, color: Colors.black),
                  ),
                  Text(
                    'Pembayaran Nasional',
                    style: GoogleFonts.plusJakartaSans(fontSize: 8, fontWeight: FontWeight.w700, color: Colors.black),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          // QR Code Graphic with NutriMeal Leaf in center
          Container(
            width: 200,
            height: 200,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(184, 184),
                  painter: _QrisPainter(),
                ),
                // Center Green Leaf
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F8A50),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.eco_rounded, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // NMID
          Text(
            'NMID:  ID2025444802321',
            style: GoogleFonts.sourceCodePro(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsSection() {
    final instructions = [
      {
        'title': 'Simpan atau screenshot Kode QR',
        'body': 'Gunakan tombol "Simpan Kode QR" di bawah layar atau tangkap layar secara manual.',
        'highlight': '"Simpan Kode QR"',
      },
      {
        'title': 'Buka aplikasi pembayaran favorit Anda',
        'body': 'Buka BCA mobile, GoPay, ShopeePay, DANA, OVO, Livin\' by Mandiri, atau m-Banking pilihan Anda.',
      },
      {
        'title': 'Pilih menu Scan QR & upload gambar',
        'body': 'Ketuk ikon QR/Bayar di aplikasi Anda, lalu pilih opsi ambil gambar dari galeri foto perangkat.',
      },
      {
        'title': 'Periksa detail & konfirmasi nominal',
        'body': 'Pastikan nama penerima adalah NutriMeal Official Catering dengan jumlah tepat.',
        'highlight': 'NutriMeal Official Catering',
      },
      {
        'title': 'Masukkan PIN transaksi Anda',
        'body': 'Pesanan katering sehat Anda akan diverifikasi otomatis oleh sistem dalam 10-30 detik.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Petunjuk Pembayaran QRIS',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(instructions.length, (index) {
          final item = instructions[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step Number Circle (solid green with white number)
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title']!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['body']!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBottomButtons(BuildContext context, String amountText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          // Button 1: Simpan Kode QR
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Kode QR berhasil disimpan ke Galeri!'),
                    backgroundColor: Color(0xFF16A34A),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.download_rounded, color: Colors.white, size: 18),
              label: Text(
                'Simpan Kode QR',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F8A50),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Button 2: Cek Status Pembayaran
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentStatusScreen(
                      totalAmount: amountText,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.sync_rounded, color: AppColors.textDark, size: 18),
              label: Text(
                'Cek Status Pembayaran',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF1F5F9),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for a QRIS QR code aesthetic
class _QrisPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintDark = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final paintGreen = Paint()
      ..color = const Color(0xFF0F8A50)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Helper to draw a finder pattern
    void drawFinderPattern(double x, double y, double s, Paint innerPaint) {
      // Outer box
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y, s, s), const Radius.circular(8)),
        paintDark,
      );
      // Inner clear
      final innerClearPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x + s * 0.15, y + s * 0.15, s * 0.7, s * 0.7), const Radius.circular(5)),
        innerClearPaint,
      );
      // Inner dot
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x + s * 0.3, y + s * 0.3, s * 0.4, s * 0.4), const Radius.circular(3)),
        innerPaint,
      );
    }

    final cornerSize = w * 0.28;
    // Top-Left Finder
    drawFinderPattern(0, 0, cornerSize, paintGreen);
    // Top-Right Finder
    drawFinderPattern(w - cornerSize, 0, cornerSize, paintDark);
    // Bottom-Left Finder
    drawFinderPattern(0, h - cornerSize, cornerSize, paintDark);

    // Decorative Data Modules / Matrix Dots
    final dotSize = w * 0.042;
    for (int r = 0; r < 21; r++) {
      for (int c = 0; c < 21; c++) {
        // Skip finder areas
        if ((r < 7 && c < 7) || (r < 7 && c > 13) || (r > 13 && c < 7)) continue;
        // Skip center area
        if (r >= 8 && r <= 12 && c >= 8 && c <= 12) continue;

        // Pseudo-random pattern based on formula
        if ((r * 7 + c * 13 + (r * c)) % 3 == 0 || (r + c) % 5 == 0) {
          final px = c * (w / 21);
          final py = r * (h / 21);
          canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(px, py, dotSize, dotSize), const Radius.circular(1.5)),
            paintDark,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
