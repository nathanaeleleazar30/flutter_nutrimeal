import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/menu_controller.dart';
import '../core/constants/app_colors.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _pasteController = TextEditingController();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _cityDistrictController;
  late TextEditingController _streetBuildingController;
  late TextEditingController _noteController;

  String _selectedLabelType = 'Kantor'; // Kantor, Rumah, Apartemen
  bool _isDefaultAddress = true;

  @override
  void initState() {
    super.initState();
    final address = context.read<NutriMealMenuController>().deliveryAddress;
    _nameController = TextEditingController(text: address.recipientName.isNotEmpty ? address.recipientName : 'Nadia Paramitha');
    _phoneController = TextEditingController(text: address.phoneNumber.isNotEmpty ? address.phoneNumber : '+62 81389201944');
    _cityDistrictController = TextEditingController(text: 'DKI Jakarta, Jakarta Selatan, Setiabudi, 12920');
    _streetBuildingController = TextEditingController(text: address.fullAddress.isNotEmpty ? address.fullAddress : 'Menara Satrio Kuningan, Lantai 14 Unit 02');
    _noteController = TextEditingController(text: address.deliveryNote.isNotEmpty ? address.deliveryNote : 'Titip di security lobby barat jika jam makan siang');
    _selectedLabelType = address.addressType;
    _isDefaultAddress = address.isDefault;
  }

  @override
  void dispose() {
    _pasteController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _cityDistrictController.dispose();
    _streetBuildingController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _handleAutofillFromPaste() {
    final text = _pasteController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _nameController.text = 'Budi Santoso';
        _phoneController.text = '+62 812-3456-7890';
        _streetBuildingController.text = 'Jl. Senopati No. 42, Kebayoran Baru, Jakarta Selatan';
        _noteController.text = 'Titip di resepsionis depan';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Data alamat berhasil dipisahkan dan diisi otomatis!',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.primaryGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      _pasteController.text = 'Budi Santoso, 08123456789, Jl. Senopati No. 42, Kebayoran Baru, Jakarta Selatan. Titip di resepsionis...';
      _handleAutofillFromPaste();
    }
  }

  void _saveAddress() {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedAddress = DeliveryAddress(
        label: '$_selectedLabelType (${_isDefaultAddress ? "Utama" : "Tersimpan"})',
        recipientName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        area: _cityDistrictController.text.trim(),
        fullAddress: _streetBuildingController.text.trim(),
        deliveryNote: _noteController.text.trim(),
        addressType: _selectedLabelType,
        isDefault: _isDefaultAddress,
      );

      context.read<NutriMealMenuController>().updateDeliveryAddress(updatedAddress);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Alamat pengiriman berhasil disimpan!',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Ubah Alamat Pengiriman',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Tempel & Isi Otomatis Card (Image 2)
                _buildAutoFillCard(),
                const SizedBox(height: 16),

                // 2. Alamat Pengiriman Form Section
                _buildFormSection(),
                const SizedBox(height: 16),

                // 3. Titik Lokasi Presisi Card
                _buildPinpointMapCard(),
                const SizedBox(height: 16),

                // 4. Atur sebagai Alamat Utama & Label Alamat
                _buildAddressSettingsCard(),
                const SizedBox(height: 20),

                // 5. Button: Simpan Alamat
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _saveAddress,
                    icon: const Icon(Icons.save_rounded, color: Colors.white, size: 18),
                    label: Text(
                      'Simpan Alamat',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
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

  Widget _buildAutoFillCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_fix_high_rounded, color: Color(0xFF166534), size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tempel & Isi Otomatis',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tempel teks pesanan atau pesan chat. Sistem NutriMeal otomatis memisahkan nama, kontak, dan alamat antar.',
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
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _pasteController,
                  maxLines: 2,
                  style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppColors.textDark),
                  decoration: InputDecoration(
                    hintText: 'Cth: Budi Santoso, 08123456789, Jl. Senopati No. 42, Kebayoran Baru, Jakarta Selatan. Titip di resepsionis...',
                    hintStyle: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF94A3B8)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        _pasteController.text = 'Budi Santoso, 08123456789, Jl. Senopati No. 42, Kebayoran Baru, Jakarta Selatan. Titip di resepsionis...';
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.paste_rounded, size: 13, color: Color(0xFF475569)),
                            const SizedBox(width: 4),
                            Text(
                              'Tempel',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _handleAutofillFromPaste,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Isi Data',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 13),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
              Text(
                'Alamat Pengiriman',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_rounded, color: Color(0xFF166534), size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'Standar Kurir NutriMeal',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF166534),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 1. Nama Penerima
          _buildFieldHeader('Nama Penerima'),
          _buildInputBox(
            controller: _nameController,
            hint: 'Nama lengkap penerima',
            icon: Icons.work_outline_rounded,
          ),
          const SizedBox(height: 12),

          // 2. Nomor Telepon
          _buildFieldHeader('Nomor Telepon'),
          _buildInputBox(
            controller: _phoneController,
            hint: '+62 812-xxxx-xxxx',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),

          // 3. Kecamatan & Kota Pengiriman
          _buildFieldHeader('Kecamatan & Kota Pengiriman'),
          _buildInputBox(
            controller: _cityDistrictController,
            hint: 'Kecamatan, Kota, Kode Pos',
            icon: Icons.business_outlined,
            trailingIcon: Icons.chevron_right_rounded,
          ),
          const SizedBox(height: 12),

          // 4. Nama Jalan, Gedung, No. Rumah
          _buildFieldHeader('Nama Jalan, Gedung, No. Rumah'),
          _buildInputBox(
            controller: _streetBuildingController,
            hint: 'Nama jalan, gedung, lantai, unit...',
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 12),

          // 5. Detail & Patokan (Opsional)
          _buildFieldHeader('Detail & Patokan (Opsional)'),
          _buildInputBox(
            controller: _noteController,
            hint: 'Patokan lokasi atau instruksi kurir...',
            icon: Icons.info_outline_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildFieldHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF475569),
        ),
      ),
    );
  }

  Widget _buildInputBox({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    IconData? trailingIcon,
    TextInputType? keyboardType,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 17, color: const Color(0xFF64748B)),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textDark),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF94A3B8)),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
            ),
          ),
          if (trailingIcon != null)
            Icon(trailingIcon, size: 18, color: const Color(0xFF94A3B8)),
        ],
      ),
    );
  }

  Widget _buildPinpointMapCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
              Row(
                children: [
                  const Icon(Icons.location_on_rounded, color: Color(0xFF16A34A), size: 17),
                  const SizedBox(width: 6),
                  Text(
                    'Titik Lokasi Presisi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              Text(
                'Ubah Pin',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF16A34A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Map preview container with green pinpoint in center
          Container(
            height: 90,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE2E8F0), Color(0xFFCBD5E1)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFF16A34A),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Titik akurat pengantaran catering diet',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.eco_rounded, color: Color(0xFF16A34A), size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Memastikan kurir ramah lingkungan mengantar paket makan tepat waktu sebelum jadwal santap.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    color: const Color(0xFF64748B),
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSettingsCard() {
    final labels = ['Kantor', 'Rumah', 'Apartemen'];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Switch Atur Sebagai Alamat Utama
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Atur sebagai Alamat Utama',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    'Prioritas default saat berlangganan meal plan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Switch(
                value: _isDefaultAddress,
                activeTrackColor: const Color(0xFF16A34A),
                activeThumbColor: Colors.white,
                onChanged: (val) => setState(() => _isDefaultAddress = val),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          // Tandai Alamat Sebagai
          Text(
            'Tandai Alamat Sebagai',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: labels.map((lbl) {
              final isSelected = _selectedLabelType == lbl;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => setState(() => _selectedLabelType = lbl),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF16A34A) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            lbl == 'Kantor'
                                ? Icons.business_rounded
                                : (lbl == 'Rumah' ? Icons.home_rounded : Icons.apartment_rounded),
                            size: 14,
                            color: isSelected ? Colors.white : const Color(0xFF475569),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            lbl,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? Colors.white : const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
