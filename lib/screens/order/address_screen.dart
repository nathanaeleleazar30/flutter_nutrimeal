import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/menu_controller.dart';
import '../../core/constants/app_colors.dart';

enum AddressFormMode { add, edit }

/// ============================================================================
/// 1. PILIH ALAMAT PENGIRIMAN
/// ============================================================================
class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  String? _selectedAddressId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<NutriMealMenuController>();
      setState(() {
        _selectedAddressId = controller.deliveryAddress.id.isNotEmpty
            ? controller.deliveryAddress.id
            : (controller.savedAddresses.isNotEmpty
                ? controller.savedAddresses.first.id
                : 'addr_1');
      });
    });
  }

  void _confirmSelection(NutriMealMenuController controller) {
    final list = controller.savedAddresses;
    if (list.isEmpty) return;

    final chosen = list.firstWhere(
      (a) => a.id == _selectedAddressId,
      orElse: () => list.first,
    );

    controller.selectDeliveryAddress(chosen);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Alamat ${chosen.recipientName} (${chosen.addressType}) aktif digunakan!',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF0F8A50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    Navigator.pop(context, chosen);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NutriMealMenuController>(
      builder: (context, controller, child) {
        final addresses = controller.savedAddresses;
        if (_selectedAddressId == null && addresses.isNotEmpty) {
          _selectedAddressId = addresses.first.id;
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: const Color(0xFFC3E7C4),
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            leading: Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Center(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.textDark,
                      size: 24,
                    ),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
            title: Text(
              'Pilih Alamat Pengiriman',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Subheader: ALAMAT TERSIMPAN (X) | Pilih salah satu
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ALAMAT TERSIMPAN (${addresses.length})',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              'Pilih salah satu',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // List of Saved Address Cards
                        ...addresses.map((address) {
                          final isSelected = address.id == _selectedAddressId;
                          return _buildAddressItemCard(
                            context: context,
                            address: address,
                            isSelected: isSelected,
                            onSelect: () {
                              setState(() {
                                _selectedAddressId = address.id;
                              });
                            },
                            onEdit: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddressFormScreen(
                                    mode: AddressFormMode.edit,
                                    address: address,
                                  ),
                                ),
                              );
                            },
                          );
                        }),

                        const SizedBox(height: 6),

                        // Green Info Card (Thermal Box Steril)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFA7F3D0),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Color(0xFF047857),
                                  size: 14,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Semua pesanan paket katering NutriMeal dikirim tepat waktu dengan thermal box steril.',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    color: const Color(0xFF065F46),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Sticky Bottom Action Container
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. + Tambah Alamat Baru (Outline Green)
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: OutlinedButton(
                          onPressed: () {
                            if (controller.savedAddresses.length >= 5) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Maksimal 5 alamat pengiriman telah tercapai.',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  backgroundColor: const Color(0xFFDC2626),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddressFormScreen(
                                  mode: AddressFormMode.add,
                                ),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFF0F8A50),
                              width: 1.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: const Color(0xFFF0FDF4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_rounded,
                                  color: Color(0xFF0F8A50), size: 18),
                              const SizedBox(width: 6),
                              Text(
                                'Tambah Alamat Baru',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F8A50),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 2. Gunakan Alamat Ini > (Solid Green)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => _confirmSelection(controller),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F8A50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Gunakan Alamat Ini',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddressItemCard({
    required BuildContext context,
    required DeliveryAddress address,
    required bool isSelected,
    required VoidCallback onSelect,
    required VoidCallback onEdit,
  }) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F8A50) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isSelected ? 0.04 : 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Radio + Name/Phone + Ubah Action
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Radio Button
                Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.only(top: 1),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF0F8A50)
                          : const Color(0xFFCBD5E1),
                      width: isSelected ? 2 : 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: isSelected
                      ? Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF0F8A50),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 10),

                // Name & Phone
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        address.recipientName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      if (address.phoneNumber.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            address.phoneNumber,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Ubah Action Button
                GestureDetector(
                  onTap: onEdit,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6, bottom: 4),
                    child: Text(
                      'Ubah',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F8A50),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Full Address
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Text(
                address.fullAddress,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF475569),
                  height: 1.4,
                ),
              ),
            ),

            // Delivery Note
            if (address.deliveryNote.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 1.5),
                        child: Icon(Icons.info_rounded,
                            size: 13, color: Color(0xFF0F8A50)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          address.deliveryNote.startsWith('Catatan')
                              ? address.deliveryNote
                              : 'Catatan pengantaran: ${address.deliveryNote}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF166534),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 10),

            // Badges: Utama & Category Tag (Rumah / Kantor)
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Row(
                children: [
                  if (address.isDefault) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F8A50),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Utama',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      address.addressType.isNotEmpty
                          ? address.addressType
                          : 'Rumah',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================================
/// 2. FORM UBAH ALAMAT / TAMBAH ALAMAT (Image 1 Bottom-Left)
/// ============================================================================
class AddressFormScreen extends StatefulWidget {
  final AddressFormMode mode;
  final DeliveryAddress? address;

  const AddressFormScreen({
    super.key,
    required this.mode,
    this.address,
  });

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _coordinatesController;
  late TextEditingController _areaController;
  late TextEditingController _detailController;

  String _selectedCategory = 'Rumah';
  bool _isDefaultAddress = true;

  @override
  void initState() {
    super.initState();
    final addr = widget.address;
    if (widget.mode == AddressFormMode.edit && addr != null) {
      _nameController = TextEditingController(text: addr.recipientName);
      _phoneController = TextEditingController(text: addr.phoneNumber);
      final rawCoords = addr.fullAddress.isNotEmpty
          ? addr.fullAddress
          : 'Jl. Senopati, Kebayoran Baru, Jakarta Selatan, 12190';
      _coordinatesController = TextEditingController(
          text: rawCoords.length > 100 ? rawCoords.substring(0, 100) : rawCoords);
      _areaController = TextEditingController(
          text: addr.area.isNotEmpty
              ? addr.area
              : 'Kebayoran Baru, Jakarta Selatan, DKI Jakarta 12190');
      final rawDetail = addr.deliveryNote.isNotEmpty
          ? addr.deliveryNote
          : 'Rumah pagar hitam samping Alfamart / Titipkan pos security';
      _detailController = TextEditingController(
          text: rawDetail.length > 100 ? rawDetail.substring(0, 100) : rawDetail);
      _selectedCategory = addr.addressType.isNotEmpty ? addr.addressType : 'Rumah';
      _isDefaultAddress = addr.isDefault;
    } else {
      // Default initial values matching screenshot (Image 1 bottom left)
      _nameController = TextEditingController(text: 'Nadia Salsabila');
      _phoneController = TextEditingController(text: '+62 812-8890-1234');
      _coordinatesController = TextEditingController(
          text: 'Jl. Senopati, Kebayoran Baru, Jakarta Selatan, 12190');
      _areaController = TextEditingController(
          text: 'Kebayoran Baru, Jakarta Selatan, DKI Jakarta 12190');
      _detailController = TextEditingController(
          text: 'Rumah pagar hitam samping Alfamart / Titipkan pos security');
      _selectedCategory = 'Rumah';
      _isDefaultAddress = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _coordinatesController.dispose();
    _areaController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    if (_formKey.currentState?.validate() ?? false) {
      final controller = context.read<NutriMealMenuController>();
      final isEdit = widget.mode == AddressFormMode.edit;

      final addressId = isEdit && widget.address != null
          ? widget.address!.id
          : 'addr_${DateTime.now().millisecondsSinceEpoch}';

      final saved = DeliveryAddress(
        id: addressId,
        label: '$_selectedCategory (${_nameController.text.trim().split(' ').first})',
        recipientName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        area: _areaController.text.trim(),
        fullAddress: _coordinatesController.text.trim(),
        deliveryNote: _detailController.text.trim(),
        addressType: _selectedCategory,
        isDefault: _isDefaultAddress,
      );

      if (isEdit) {
        controller.updateSavedAddress(saved);
      } else {
        if (controller.savedAddresses.length >= 5) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Maksimal 5 alamat pengiriman telah tercapai.',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
              ),
              backgroundColor: const Color(0xFFDC2626),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          return;
        }
        controller.addSavedAddress(saved);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? 'Alamat pengiriman berhasil disimpan!'
                : 'Alamat baru berhasil ditambahkan!',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF0F8A50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      Navigator.pop(context);
    }
  }

  void _deleteAddress() {
    final addr = widget.address;
    if (addr == null) {
      Navigator.pop(context);
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Hapus Alamat?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          content: Text(
            'Apakah kamu yakin ingin menghapus alamat "${addr.recipientName}"?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFF64748B),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Batal',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<NutriMealMenuController>().removeSavedAddress(addr.id);
                Navigator.pop(ctx);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Alamat berhasil dihapus.',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                    ),
                    backgroundColor: const Color(0xFFEF4444),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'Ya, Hapus',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.mode == AddressFormMode.edit;
    final title = isEdit ? 'Ubah Alamat' : 'Tambah Alamat';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFC3E7C4),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Center(
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.chevron_left_rounded,
                  color: AppColors.textDark,
                  size: 24,
                ),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // White Card Container (Matching Image 1 bottom-left)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
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
                      // Section Title: Alamat Pengantaran
                      Text(
                        'Alamat Pengantaran',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 1. Nama Penerima
                      _buildFieldLabel('Nama Penerima'),
                      const SizedBox(height: 6),
                      _buildFormField(
                        controller: _nameController,
                        icon: Icons.person_outline_rounded,
                        hint: 'Nama lengkap penerima',
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Nama penerima wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 12),

                      // 2. Nomor Telepon
                      _buildFieldLabel('Nomor Telepon'),
                      const SizedBox(height: 6),
                      _buildFormField(
                        controller: _phoneController,
                        icon: Icons.phone_outlined,
                        hint: '+62 8xx-xxxx-xxxx',
                        keyboardType: TextInputType.phone,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Nomor telepon wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 12),

                      // 3. Alamat Lengkap Pengiriman (Expandable & Max 100 Karakter)
                      _buildFieldLabel('Alamat Lengkap Pengiriman'),
                      const SizedBox(height: 6),
                      _buildFormField(
                        controller: _coordinatesController,
                        icon: Icons.location_on_outlined,
                        hint: 'Tuliskan nama jalan, no. rumah, RT/RW, dsb.',
                        minLines: 2,
                        maxLines: 5,
                        maxLength: 100,
                        showCounter: true,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Alamat pengiriman wajib diisi';
                          }
                          if (v.trim().length > 100) {
                            return 'Alamat maksimal 100 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // 4. Kota / Kecamatan / Kode Pos
                      _buildFieldLabel('Kota / Kecamatan / Kode Pos'),
                      const SizedBox(height: 6),
                      _buildFormField(
                        controller: _areaController,
                        icon: Icons.location_city_outlined,
                        hint: 'Kecamatan, Kota, Provinsi, Kode Pos',
                        maxLength: 100,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Wilayah & kode pos wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 12),

                      // 5. Detail & Patokan Domisili (Expandable & Max 100 Karakter)
                      _buildFieldLabel('Detail & Patokan Domisili (Opsional)'),
                      const SizedBox(height: 6),
                      _buildFormField(
                        controller: _detailController,
                        icon: Icons.home_outlined,
                        hint: 'Cth: Pagar hitam samping Alfamart / Pos satpam',
                        minLines: 2,
                        maxLines: 4,
                        maxLength: 100,
                        showCounter: true,
                      ),
                      const SizedBox(height: 16),

                      // Titik Lokasi Presisi (Map Card)
                      _buildPinpointMapCard(),
                      const SizedBox(height: 16),

                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      const SizedBox(height: 14),

                      // Atur sebagai Alamat Utama Switch
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Atur sebagai Alamat Utama',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Prioritas default pengantaran katering harian kamu.',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _isDefaultAddress,
                            activeThumbColor: Colors.white,
                            activeTrackColor: const Color(0xFF0F8A50),
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: const Color(0xFFCBD5E1),
                            onChanged: (val) {
                              setState(() {
                                _isDefaultAddress = val;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Tipe Alamat (Rumah / Kantor)
                      _buildFieldLabel('Tipe Alamat'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildTypeChip(
                            label: 'Rumah',
                            isSelected: _selectedCategory == 'Rumah',
                            onTap: () {
                              setState(() {
                                _selectedCategory = 'Rumah';
                              });
                            },
                          ),
                          const SizedBox(width: 10),
                          _buildTypeChip(
                            label: 'Kantor',
                            isSelected: _selectedCategory == 'Kantor',
                            onTap: () {
                              setState(() {
                                _selectedCategory = 'Kantor';
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Bottom Buttons Row: [Hapus Alamat] & [Simpan Alamat]
                Row(
                  children: [
                    // Hapus Alamat Button (Red outline pill)
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: _deleteAddress,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFFEF4444),
                              width: 1.2,
                            ),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Hapus Alamat',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFEF4444),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Simpan Alamat Button (Solid Green pill)
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _saveAddress,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F8A50),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Simpan Alamat',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF64748B),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    IconData? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int minLines = 1,
    int? maxLines = 1,
    int? maxLength,
    bool showCounter = false,
  }) {
    final isMultiLine = (maxLines == null || maxLines > 1 || minLines > 1);
    return TextFormField(
      controller: controller,
      keyboardType: isMultiLine ? TextInputType.multiline : keyboardType,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      validator: validator,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
        height: 1.45,
      ),
      buildCounter: showCounter && maxLength != null
          ? (context, {required currentLength, required isFocused, maxLength}) {
              return Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 2),
                child: Text(
                  '$currentLength/$maxLength karakter',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: currentLength >= (maxLength ?? 100)
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF94A3B8),
                  ),
                ),
              );
            }
          : (maxLength != null && !showCounter
              ? (_, {required currentLength, required isFocused, maxLength}) => null
              : null),
      decoration: InputDecoration(
        prefixIcon: isMultiLine
            ? Padding(
                padding: const EdgeInsets.only(left: 12, right: 10, top: 12),
                child: Icon(icon, color: const Color(0xFF64748B), size: 18),
              )
            : Icon(icon, color: const Color(0xFF64748B), size: 18),
        prefixIconConstraints: isMultiLine
            ? const BoxConstraints(minWidth: 40, minHeight: 40)
            : null,
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, color: const Color(0xFF94A3B8), size: 18)
            : null,
        hintText: hint,
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          color: const Color(0xFF94A3B8),
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF0F8A50), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildPinpointMapCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.gps_fixed_rounded,
                  color: Color(0xFF0F8A50),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Titik Lokasi Presisi',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Pin lokasi berhasil disesuaikan secara presisi!',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                    ),
                    backgroundColor: const Color(0xFF0F8A50),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              child: Text(
                'Geser Pin',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F8A50),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Map Preview Box
        Container(
          height: 105,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFE2E8F0),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: Stack(
            children: [
              // Map background grid
              Positioned.fill(
                child: CustomPaint(
                  painter: _MapGridPainter(),
                ),
              ),

              // Center Green Pin with White Dot inside (matching Image 1 bottom-left)
              Center(
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F8A50),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F8A50).withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Caption Note under map
        Text(
          'Titik akurat pengantaran katering kamu',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10.5,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F8A50) : const Color(0xFFCBD5E1),
            width: isSelected ? 1.4 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(
                Icons.check_rounded,
                size: 13,
                color: Color(0xFF0F8A50),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? const Color(0xFF0F8A50) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for stylized map streets and contours
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    final roadSecondary = Paint()
      ..color = const Color(0xFFCBD5E1).withValues(alpha: 0.9)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final waterPaint = Paint()
      ..color = const Color(0xFFBFDBFE).withValues(alpha: 0.45)
      ..strokeWidth = 7.0
      ..style = PaintingStyle.stroke;

    // Curved river path
    final riverPath = Path()
      ..moveTo(0, size.height * 0.25)
      ..cubicTo(size.width * 0.4, size.height * 0.4, size.width * 0.6,
          size.height * 0.1, size.width, size.height * 0.35);
    canvas.drawPath(riverPath, waterPaint);

    // Main street
    canvas.drawLine(
      Offset(0, size.height * 0.65),
      Offset(size.width, size.height * 0.45),
      roadPaint,
    );

    // Cross street
    canvas.drawLine(
      Offset(size.width * 0.35, 0),
      Offset(size.width * 0.55, size.height),
      roadPaint,
    );

    // Secondary diagonal road
    canvas.drawLine(
      Offset(size.width * 0.1, size.height),
      Offset(size.width * 0.85, 0),
      roadSecondary,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
