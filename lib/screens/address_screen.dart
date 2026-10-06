import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/menu_controller.dart';
import '../core/constants/app_colors.dart';

enum AddressFormMode { add, edit }

/// ============================================================================
/// 1. PILIH ALAMAT PENGIRIMAN (Image 1)
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
        backgroundColor: const Color(0xFF16A34A),
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
        // Make sure selected ID exists in the list
        if (_selectedAddressId == null && addresses.isNotEmpty) {
          _selectedAddressId = addresses.first.id;
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.textDark, size: 22),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Pilih Alamat Pengiriman',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            actions: [
              // Badge: • NutriMeal (Image 1 top right)
              Container(
                margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF16A34A),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'NutriMeal',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF15803D),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                                  'Semua pesanan paket sehat NutriMeal dikirim tepat waktu dengan thermal box steril.',
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

                // Sticky Bottom Action Container (Image 1)
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
                              color: Color(0xFF22C55E),
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
                                  color: Color(0xFF16A34A), size: 18),
                              const SizedBox(width: 6),
                              Text(
                                'Tambah Alamat Baru',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF16A34A),
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
                            backgroundColor: const Color(0xFF22C55E),
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
            color: isSelected ? const Color(0xFF22C55E) : const Color(0xFFE2E8F0),
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
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.only(top: 1),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFCBD5E1),
                      width: isSelected ? 2 : 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: isSelected
                      ? Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF22C55E),
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
                          fontSize: 14.5,
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
                        color: const Color(0xFF16A34A),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Full Address (Indented aligned with text)
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Text(
                address.fullAddress,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF475569),
                  height: 1.4,
                ),
              ),
            ),

            // Delivery Note (Soft Light Green Box)
            if (address.deliveryNote.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 32),
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
                            size: 13, color: Color(0xFF16A34A)),
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

            const SizedBox(height: 12),

            // Badges: Utama & Category Tag (Kantor / Rumah / Tempat Kerja)
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Row(
                children: [
                  if (address.isDefault) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Utama',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      address.addressType.isNotEmpty
                          ? address.addressType
                          : 'Kantor',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
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
/// 2. FORM ALAMAT PENGIRIMAN (Image 2: Ubah Alamat / Image 3: Tambah Alamat)
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

  final TextEditingController _pasteController = TextEditingController();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _areaController;
  late TextEditingController _streetController;
  late TextEditingController _noteController;

  String _selectedCategory = 'Rumah';
  bool _isDefaultAddress = true;
  bool _pinpointVerified = true;

  @override
  void initState() {
    super.initState();
    final addr = widget.address;
    if (widget.mode == AddressFormMode.edit && addr != null) {
      _nameController = TextEditingController(text: addr.recipientName);
      _phoneController = TextEditingController(text: addr.phoneNumber);
      _areaController = TextEditingController(
          text: addr.area.isNotEmpty
              ? addr.area
              : 'DKI Jakarta, Jakarta Selatan, Setiabudi, 12920');
      _streetController = TextEditingController(text: addr.fullAddress);
      _noteController = TextEditingController(text: addr.deliveryNote);
      _selectedCategory = addr.addressType.isNotEmpty ? addr.addressType : 'Kantor';
      _isDefaultAddress = addr.isDefault;
    } else {
      // Add mode initial defaults (Image 3 default style)
      _nameController = TextEditingController(text: 'Mochammad Bintang Fatahillah');
      _phoneController = TextEditingController(text: '(+62) 877-8888-0988');
      _areaController = TextEditingController(
          text: 'JAWA TIMUR, KOTA MALANG SUMBERSUKO, 67351');
      _streetController = TextEditingController(text: 'Lowokwaru, Merjosari');
      _noteController = TextEditingController(
          text: 'Toko setia pupuk (Depan pos satpam)');
      _selectedCategory = 'Rumah';
      _isDefaultAddress = true;
    }
  }

  @override
  void dispose() {
    _pasteController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _areaController.dispose();
    _streetController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _handleAutofill() {
    final text = _pasteController.text.trim();
    if (text.isNotEmpty) {
      // Smart parsing
      setState(() {
        if (text.toLowerCase().contains('budi')) {
          _nameController.text = 'Budi Santoso';
          _phoneController.text = '+62 812-3456-7890';
          _areaController.text =
              'DKI Jakarta, Jakarta Selatan, Kebayoran Baru, 12180';
          _streetController.text =
              'Jl. Senopati No. 42, Kebayoran Baru, Jakarta Selatan';
          _noteController.text = 'Titip di resepsionis depan';
        } else {
          _nameController.text = 'Nadia Paramitha';
          _phoneController.text = '+62 81389201944';
          _areaController.text =
              'DKI Jakarta, Jakarta Selatan, Setiabudi, 12920';
          _streetController.text =
              'Menara Satrio Kuningan, Lantai 14 Unit 02';
          _noteController.text =
              'Titip di security lobby barat jika jam makan siang';
        }
      });
    } else {
      setState(() {
        if (widget.mode == AddressFormMode.edit) {
          _nameController.text = 'Nadia Paramitha';
          _phoneController.text = '+62 81389201944';
          _areaController.text =
              'DKI Jakarta, Jakarta Selatan, Setiabudi, 12920';
          _streetController.text =
              'Menara Satrio Kuningan, Lantai 14 Unit 02';
          _noteController.text =
              'Titip di security lobby barat jika jam makan siang';
        } else {
          _nameController.text = 'Mochammad Bintang Fatahillah';
          _phoneController.text = '(+62) 877-8888-0988';
          _areaController.text =
              'JAWA TIMUR, KOTA MALANG SUMBERSUKO, 67351';
          _streetController.text = 'Lowokwaru, Merjosari';
          _noteController.text = 'Toko setia pupuk (Depan pos satpam)';
        }
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Data alamat berhasil dipisahkan dan diisi otomatis!',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showAreaPickerModal() {
    final areas = [
      'JAWA TIMUR, KOTA MALANG SUMBERSUKO, 67351',
      'DKI Jakarta, Jakarta Selatan, Setiabudi, 12920',
      'DKI Jakarta, Jakarta Selatan, Kebayoran Baru, 12180',
      'JAWA TIMUR, KOTA MALANG, LOWOKWARU, 65141',
      'JAWA TIMUR, KOTA MALANG, SAWOJAJAR, 65139',
      'JAWA BARAT, BANDUNG, COBLONG, 40132',
      'JAWA TIMUR, SURABAYA, GUBENG, 60281',
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pilih Wilayah & Kode Pos',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...areas.map((a) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: const Icon(Icons.location_city_rounded,
                        color: Color(0xFF16A34A), size: 20),
                    title: Text(
                      a,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _areaController.text = a;
                      });
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
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
        label: _selectedCategory,
        recipientName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        area: _areaController.text.trim(),
        fullAddress: _streetController.text.trim(),
        deliveryNote: _noteController.text.trim(),
        addressType: _selectedCategory,
        isDefault: _isDefaultAddress,
      );

      if (isEdit) {
        controller.updateSavedAddress(saved);
      } else {
        controller.addSavedAddress(saved);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? 'Alamat pengiriman berhasil diperbarui!'
                : 'Alamat baru berhasil ditambahkan!',
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

  void _deleteAddress() {
    final addr = widget.address;
    if (addr == null) return;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Hapus Alamat Pengiriman?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          content: Text(
            'Apakah kamu yakin ingin menghapus alamat "${addr.recipientName} - ${addr.addressType}"?',
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
                Navigator.pop(ctx); // Close dialog
                Navigator.pop(context); // Close screen
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Alamat berhasil dihapus.',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                    ),
                    backgroundColor: const Color(0xFFDC2626),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
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
    final title = isEdit ? 'Ubah Alamat Pengiriman' : 'Tambahkan Alamat Pengiriman';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textDark, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Tempel & Isi Otomatis Card (Image 2 & 3)
                      _buildAutoFillCard(isEdit: isEdit),
                      const SizedBox(height: 14),

                      // 2. Data Penerima / Alamat Pengiriman (Image 2 & 3)
                      _buildFormSection(isEdit: isEdit),
                      const SizedBox(height: 14),

                      // 3. Titik Pengantaran Kurir / Titik Lokasi Presisi (Map Card)
                      _buildPinpointMapCard(isEdit: isEdit),
                      const SizedBox(height: 14),

                      // 4. Pengaturan Alamat (Tandai Sebagai & Alamat Utama)
                      _buildAddressSettingsCard(isEdit: isEdit),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Action Bar (Image 2 & 3)
            _buildBottomActionBar(isEdit: isEdit),
          ],
        ),
      ),
    );
  }

  /// Card 1: Tempel & Isi Otomatis
  Widget _buildAutoFillCard({required bool isEdit}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                child: const Icon(
                  Icons.auto_fix_high_rounded,
                  color: Color(0xFF166534),
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEdit
                          ? 'Tempel & Isi Otomatis'
                          : 'Tempel dan Isi Otomatis ✨',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isEdit
                          ? 'Tempel teks pesanan atau pesan chat. Sistem NutriMeal otomatis memisahkan nama, kontak, dan alamat antar.'
                          : 'Tempel atau masukkan informasi. Klik "Isi" untuk mengisi nama, no. HP, dan alamat secara instan.',
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

          // Input Box with action buttons
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: isEdit
                // Image 2 Layout: Multi-line text with Tempel + Isi Data ->
                ? Column(
                    children: [
                      TextField(
                        controller: _pasteController,
                        maxLines: 2,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5, color: AppColors.textDark),
                        decoration: InputDecoration(
                          hintText:
                              'Cth: Budi Santoso, 08123456789, Jl. Senopati No. 42, Kebayoran Baru, Jakarta Selatan, Titip di resepsionis...',
                          hintStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 11, color: const Color(0xFF94A3B8)),
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
                              _pasteController.text =
                                  'Budi Santoso, 08123456789, Jl. Senopati No. 42, Kebayoran Baru, Jakarta Selatan, Titip di resepsionis...';
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.paste_rounded,
                                      size: 13, color: Color(0xFF475569)),
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
                            onPressed: _handleAutofill,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF16A34A),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Isi Data',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_forward_rounded,
                                    size: 13, color: Colors.white),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                // Image 3 Layout: Single row with Isi Cepat ⚡
                : Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _pasteController,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5, color: AppColors.textDark),
                          decoration: InputDecoration(
                            hintText: 'Tempel teks alamat pengiriman di sini...',
                            hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 11, color: const Color(0xFF94A3B8)),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _handleAutofill,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          'Isi Cepat ⚡',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
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

  /// Card 2: Form Section
  Widget _buildFormSection({required bool isEdit}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Section Title & Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEdit ? 'Alamat Pengiriman' : 'Data Penerima',
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
                    const Icon(Icons.check_circle_outline_rounded,
                        color: Color(0xFF166534), size: 12),
                    const SizedBox(width: 4),
                    Text(
                      isEdit
                          ? 'Standar Kurir NutriMeal'
                          : 'Katering NutriMeal',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF166534),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Field 1: Nama Penerima / Nama Lengkap
          _buildFieldLabel(isEdit ? 'Nama Penerima' : 'Nama Lengkap'),
          const SizedBox(height: 5),
          _buildTextFormField(
            controller: _nameController,
            icon: Icons.person_outline_rounded,
            hint: 'Nama lengkap penerima',
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Nama penerima wajib diisi' : null,
          ),
          const SizedBox(height: 12),

          // Field 2: Nomor Telepon
          _buildFieldLabel('Nomor Telepon'),
          const SizedBox(height: 5),
          _buildPhoneFormField(),
          const SizedBox(height: 12),

          // Field 3: Kecamatan & Kota / Provinsi, Kota, Kecamatan, Kode Pos
          _buildFieldLabel(isEdit
              ? 'Kecamatan & Kota Pengiriman'
              : 'Provinsi, Kota, Kecamatan, Kode Pos'),
          const SizedBox(height: 5),
          GestureDetector(
            onTap: _showAreaPickerModal,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_city_outlined,
                      color: Color(0xFF64748B), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _areaController.text.isNotEmpty
                          ? _areaController.text
                          : 'Pilih Provinsi, Kota, Kecamatan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: Color(0xFF94A3B8), size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Field 4: Nama Jalan, Gedung, No. Rumah
          _buildFieldLabel('Nama Jalan, Gedung, No. Rumah'),
          const SizedBox(height: 5),
          _buildTextFormField(
            controller: _streetController,
            icon: Icons.location_on_outlined,
            hint: 'Nama jalan, blok, gedung, lantai, unit',
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Alamat lengkap wajib diisi' : null,
          ),
          const SizedBox(height: 12),

          // Field 5: Detail & Patokan (Opsional)
          _buildFieldLabel(isEdit
              ? 'Detail & Patokan (Opsional)'
              : 'Detail Lainnya (Cth: Blok / Unit No., Patokan)'),
          const SizedBox(height: 5),
          _buildTextFormField(
            controller: _noteController,
            icon: Icons.info_outline_rounded,
            hint: 'Cth: Titip di pos satpam, pagar hitam',
          ),
        ],
      ),
    );
  }

  /// Card 3: Titik Lokasi Presisi / Titik Pengantaran Kurir (Map preview)
  Widget _buildPinpointMapCard({required bool isEdit}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                  const Icon(Icons.location_on_rounded,
                      color: Color(0xFF16A34A), size: 18),
                  const SizedBox(width: 6),
                  Text(
                    isEdit ? 'Titik Lokasi Presisi' : 'Titik Pengantaran Kurir',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _pinpointVerified = true;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Titik GPS terverifikasi otomatis (~3m radius kurir)!',
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600),
                      ),
                      backgroundColor: const Color(0xFF16A34A),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        isEdit ? 'Ubah Pin' : 'Ubah Pin 📍',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Map Preview Container
          Container(
            height: 130,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [Color(0xFFE2E8F0), Color(0xFFCBD5E1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Stack(
              children: [
                // Simulated road grid lines
                Positioned.fill(
                  child: CustomPaint(
                    painter: _MapGridPainter(),
                  ),
                ),

                // Center Pin with catering indicator
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16A34A),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF16A34A).withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.restaurant_rounded,
                            color: Colors.white, size: 16),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Titik akurat pengantaran catering diet',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Verified Badge at bottom left (Image 3)
                if (_pinpointVerified)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: Colors.white, size: 11),
                          const SizedBox(width: 4),
                          Text(
                            'Akurasi katering terverifikasi (~5m)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Footnote under map
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Icons.eco_rounded, color: Color(0xFF16A34A), size: 14),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  isEdit
                      ? 'Memastikan kurir ramah lingkungan mengantar paket makan tepat waktu sebelum jadwal santap.'
                      : 'Lokasi tepat membantu kurir katering mengantar menu hangat tepat waktu sebelum jam makan siang.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    color: const Color(0xFF64748B),
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Card 4: Address Settings & Categories (Kantor, Rumah, Apartemen / Lainnya)
  Widget _buildAddressSettingsCard({required bool isEdit}) {
    final chips = isEdit
        ? [
            {'label': 'Kantor', 'icon': Icons.business_center_rounded},
            {'label': 'Rumah', 'icon': Icons.home_rounded},
            {'label': 'Apartemen', 'icon': Icons.apartment_rounded},
          ]
        : [
            {'label': 'Rumah', 'icon': Icons.home_rounded},
            {'label': 'Kantor', 'icon': Icons.business_center_rounded},
            {'label': 'Lainnya', 'icon': Icons.add_rounded},
          ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Category Chips Header
          Text(
            isEdit ? 'Tandai Alamat Sebagai' : 'Tandai Sebagai',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),

          // Chips Row
          Row(
            children: chips.map((chip) {
              final label = chip['label'] as String;
              final icon = chip['icon'] as IconData;
              final isSelected = _selectedCategory == label;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 14,
                        color: isSelected ? Colors.white : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        label,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                  selected: isSelected,
                  selectedColor: const Color(0xFF16A34A),
                  backgroundColor: const Color(0xFFF1F5F9),
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  onSelected: (val) {
                    if (val) {
                      setState(() {
                        _selectedCategory = label;
                      });
                    }
                  },
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

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
                    const SizedBox(height: 2),
                    Text(
                      isEdit
                          ? 'Prioritas default saat berlangganan meal plan'
                          : 'Paket diet mingguan akan dikirim ke sini',
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
                activeTrackColor: const Color(0xFF22C55E),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFFE2E8F0),
                onChanged: (val) {
                  setState(() {
                    _isDefaultAddress = val;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Bottom Action Bar:
  /// - Edit mode: Hapus Alamat (Red) & Simpan Alamat (Green)
  /// - Add mode: Simpan Alamat (Full Green)
  Widget _buildBottomActionBar({required bool isEdit}) {
    return Container(
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
      child: isEdit
          ? Row(
              children: [
                // Hapus Alamat Button (Image 3 Bottom-Left style)
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: _deleteAddress,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Color(0xFFFECACA), width: 1.2),
                        backgroundColor: const Color(0xFFFEF2F2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.delete_outline_rounded,
                              color: Color(0xFFDC2626), size: 16),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Hapus Alamat',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFDC2626),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Simpan Alamat Button (Image 2 & 3 Bottom-Right style)
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _saveAddress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.save_rounded,
                              color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Simpan Alamat',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          : SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _saveAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.save_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Simpan Alamat',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
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
        fontWeight: FontWeight.w700,
        color: const Color(0xFF64748B),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 18),
        hintText: hint,
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          color: const Color(0xFF94A3B8),
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
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
          borderSide: const BorderSide(color: Color(0xFF22C55E), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildPhoneFormField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Nomor telepon wajib diisi' : null,
      decoration: InputDecoration(
        prefixIcon: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🇮🇩', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              const Icon(Icons.phone_outlined,
                  color: Color(0xFF64748B), size: 16),
            ],
          ),
        ),
        hintText: '(+62) 8xx-xxxx-xxxx',
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          color: const Color(0xFF94A3B8),
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
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
          borderSide: const BorderSide(color: Color(0xFF22C55E), width: 1.5),
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
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    final roadSecondary = Paint()
      ..color = const Color(0xFFE2E8F0).withValues(alpha: 0.8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final waterPaint = Paint()
      ..color = const Color(0xFF93C5FD).withValues(alpha: 0.4)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke;

    // Curved river path
    final riverPath = Path()
      ..moveTo(0, size.height * 0.2)
      ..cubicTo(size.width * 0.4, size.height * 0.35, size.width * 0.6,
          size.height * 0.1, size.width, size.height * 0.4);
    canvas.drawPath(riverPath, waterPaint);

    // Main street
    canvas.drawLine(
      Offset(0, size.height * 0.6),
      Offset(size.width, size.height * 0.45),
      roadPaint,
    );

    // Cross street
    canvas.drawLine(
      Offset(size.width * 0.3, 0),
      Offset(size.width * 0.55, size.height),
      roadPaint,
    );

    // Secondary diagonal road
    canvas.drawLine(
      Offset(size.width * 0.1, size.height),
      Offset(size.width * 0.8, 0),
      roadSecondary,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
