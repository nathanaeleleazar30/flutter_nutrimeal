import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/menu_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/center_feedback_toast.dart';
import 'location_picker_screen.dart';

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
    if (list.isEmpty) {
      CenterFeedbackToast.showInfo(
        context,
        message: 'Silakan tambahkan alamat pengiriman terlebih dahulu.',
      );
      return;
    }

    final chosen = list.firstWhere(
      (a) => a.id == _selectedAddressId,
      orElse: () => list.first,
    );

    controller.selectDeliveryAddress(chosen);

    final auth = context.read<AuthController>();
    if (auth.isLoggedIn && chosen.fullAddress.isNotEmpty) {
      auth.updateCustomerProfile(address: chosen.fullAddress);
    }

    CenterFeedbackToast.showSuccess(
      context,
      message:
          'Alamat ${chosen.recipientName} (${chosen.addressType}) aktif digunakan!',
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
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

                        if (addresses.isEmpty)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.location_off_outlined,
                                  size: 40,
                                  color: Color(0xFF94A3B8),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Belum Ada Alamat Tersimpan',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tambahkan alamat pengiriman agar makanan kateringmu sampai tepat waktu.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
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
                              CenterFeedbackToast.showError(
                                context,
                                message:
                                    'Maksimal 5 alamat pengiriman telah tercapai.',
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
                              const Icon(
                                Icons.add_rounded,
                                color: Color(0xFF0F8A50),
                                size: 18,
                              ),
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
                          onPressed: controller.savedAddresses.isEmpty
                              ? null
                              : () => _confirmSelection(controller),
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
            color: isSelected
                ? const Color(0xFF0F8A50)
                : const Color(0xFFE2E8F0),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 1.5),
                        child: Icon(
                          Icons.info_rounded,
                          size: 13,
                          color: Color(0xFF0F8A50),
                        ),
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
                        horizontal: 8,
                        vertical: 3,
                      ),
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
                      horizontal: 8,
                      vertical: 3,
                    ),
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

  const AddressFormScreen({super.key, required this.mode, this.address});

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
  double? _selectedLat;
  double? _selectedLng;
  bool _isLoadingGps = false;

  @override
  void initState() {
    super.initState();
    final addr = widget.address;
    if (widget.mode == AddressFormMode.edit && addr != null) {
      _selectedLat = addr.latitude ?? -7.9826;
      _selectedLng = addr.longitude ?? 112.6308;
      _nameController = TextEditingController(text: addr.recipientName);
      _phoneController = TextEditingController(text: addr.phoneNumber);
      final rawCoords =
          addr.fullAddress.isNotEmpty &&
              !addr.fullAddress.contains('Belum ada alamat')
          ? addr.fullAddress
          : '';
      _coordinatesController = TextEditingController(
        text: rawCoords.length > 100 ? rawCoords.substring(0, 100) : rawCoords,
      );
      _areaController = TextEditingController(text: addr.area);
      final rawDetail = addr.deliveryNote;
      _detailController = TextEditingController(
        text: rawDetail.length > 100 ? rawDetail.substring(0, 100) : rawDetail,
      );
      _selectedCategory = addr.addressType.isNotEmpty
          ? addr.addressType
          : 'Rumah';
      _isDefaultAddress = addr.isDefault;
    } else {
      // Default ke koordinat Malang atau akun
      _selectedLat = -7.9826;
      _selectedLng = 112.6308;
      final auth = context.read<AuthController>();
      _nameController = TextEditingController(text: auth.currentUserName ?? '');
      _phoneController = TextEditingController(text: auth.customerPhone ?? '');
      _coordinatesController = TextEditingController(
        text: auth.customerAddress ?? '',
      );
      _areaController = TextEditingController(text: '');
      _detailController = TextEditingController(text: '');
      _selectedCategory = 'Rumah';
      _isDefaultAddress = true;
    }
  }

  Future<void> _openLocationPicker() async {
    final result = await Navigator.push<LocationPinResult>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          initialPosition: _selectedLat != null && _selectedLng != null
              ? LatLng(_selectedLat!, _selectedLng!)
              : null,
          initialAddress: _coordinatesController.text,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedLat = result.point.latitude;
        _selectedLng = result.point.longitude;
        _coordinatesController.text = result.fullAddress;
        if (result.area.isNotEmpty) {
          _areaController.text = result.area;
        }
      });
      if (mounted) {
        CenterFeedbackToast.showSuccess(
          context,
          message: 'Titik lokasi Google Maps berhasil diperbarui!',
        );
      }
    }
  }

  Future<void> _getCurrentGpsLocation() async {
    setState(() => _isLoadingGps = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          CenterFeedbackToast.showError(
            context,
            message: 'GPS / Layanan lokasi belum aktif.',
          );
        }
        setState(() => _isLoadingGps = false);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            CenterFeedbackToast.showError(
              context,
              message: 'Izin akses lokasi perangkat ditolak.',
            );
          }
          setState(() => _isLoadingGps = false);
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;
      setState(() {
        _selectedLat = position.latitude;
        _selectedLng = position.longitude;
        _isLoadingGps = false;
      });

      _reverseGeocodePoint(LatLng(position.latitude, position.longitude));

      CenterFeedbackToast.showSuccess(
        context,
        message:
            'Titik GPS berhasil dideteksi: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingGps = false);
        CenterFeedbackToast.showError(
          context,
          message: 'Gagal mendapatkan GPS: $e',
        );
      }
    }
  }

  Future<void> _reverseGeocodePoint(LatLng point) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${point.latitude}&lon=${point.longitude}&zoom=18&addressdetails=1',
      );
      final response = await http
          .get(
            url,
            headers: {'User-Agent': 'NutriMealApp/1.0 (flutter.nutrimeal)'},
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final displayName = data['display_name']?.toString() ?? '';
        final address = data['address'] as Map<String, dynamic>? ?? {};

        final areaParts = [
          address['suburb'] ?? address['village'] ?? address['city_district'],
          address['city'] ?? address['town'] ?? address['county'],
        ].where((e) => e != null && e.toString().isNotEmpty).toList();

        final area = areaParts.isNotEmpty ? areaParts.join(', ') : '';

        if (mounted) {
          setState(() {
            if (displayName.isNotEmpty) {
              _coordinatesController.text = displayName;
            }
            if (area.isNotEmpty) {
              _areaController.text = area;
            }
          });
        }
      }
    } catch (_) {}
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
        label:
            '$_selectedCategory (${_nameController.text.trim().split(' ').first})',
        recipientName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        area: _areaController.text.trim(),
        fullAddress: _coordinatesController.text.trim(),
        deliveryNote: _detailController.text.trim(),
        addressType: _selectedCategory,
        isDefault: _isDefaultAddress,
        latitude: _selectedLat,
        longitude: _selectedLng,
      );

      if (isEdit) {
        controller.updateSavedAddress(saved);
      } else {
        if (controller.savedAddresses.length >= 5) {
          CenterFeedbackToast.showError(
            context,
            message: 'Maksimal 5 alamat pengiriman telah tercapai.',
          );
          return;
        }
        controller.addSavedAddress(saved);
      }

      // Sinkronkan ke profil customer backend MySQL
      try {
        final auth = context.read<AuthController>();
        auth.updateCustomerProfile(
          phone: _phoneController.text.trim(),
          address: _coordinatesController.text.trim(),
        );
      } catch (_) {}

      CenterFeedbackToast.showSuccess(
        context,
        message: isEdit
            ? 'Alamat pengiriman berhasil disimpan!'
            : 'Alamat baru berhasil ditambahkan!',
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
                context.read<NutriMealMenuController>().removeSavedAddress(
                  addr.id,
                );
                Navigator.pop(ctx);
                Navigator.pop(context);
                CenterFeedbackToast.showSuccess(
                  context,
                  message: 'Alamat berhasil dihapus.',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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

                      // 3. Alamat Lengkap Pengiriman (Expandable)
                      _buildFieldLabel('Alamat Lengkap Pengiriman'),
                      const SizedBox(height: 6),
                      _buildFormField(
                        controller: _coordinatesController,
                        icon: Icons.location_on_outlined,
                        hint:
                            'Tuliskan nama jalan, no. rumah, RT/RW, kelurahan, dsb.',
                        minLines: 2,
                        maxLines: 5,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Alamat pengiriman wajib diisi';
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
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Wilayah & kode pos wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 12),

                      // 5. Detail & Patokan Domisili (Opsional)
                      _buildFieldLabel('Detail & Patokan Domisili (Opsional)'),
                      const SizedBox(height: 6),
                      _buildFormField(
                        controller: _detailController,
                        icon: Icons.home_outlined,
                        hint: 'Cth: Pagar hitam samping Alfamart / Pos satpam',
                        minLines: 2,
                        maxLines: 4,
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

                // Bottom Buttons:
                if (isEdit && widget.address != null)
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

                      // Simpan Perubahan Button
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
                              'Simpan Perubahan',
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
                  )
                else
                  SizedBox(
                    width: double.infinity,
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
                          fontSize: 14.5,
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
                ? (
                    _, {
                    required currentLength,
                    required isFocused,
                    maxLength,
                  }) => null
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
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
    final lat = _selectedLat ?? -7.9826;
    final lng = _selectedLng ?? 112.6308;
    final centerPoint = LatLng(lat, lng);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  const Icon(
                    Icons.gps_fixed_rounded,
                    color: Color(0xFF0F8A50),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Titik Lokasi Presisi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _openLocationPicker,
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

        // Interactive Map Preview Box (Google Maps Roadmap Tiles)
        GestureDetector(
          onTap: _openLocationPicker,
          child: Container(
            height: 135,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFFE2E8F0),
              border: Border.all(color: const Color(0xFFCBD5E1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Live Google Maps Roadmap Layer
                Positioned.fill(
                  child: IgnorePointer(
                    child: FlutterMap(
                      key: ValueKey('preview_map_${lat}_$lng'),
                      options: MapOptions(
                        initialCenter: centerPoint,
                        initialZoom: 16.0,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                          userAgentPackageName: 'com.nutrimeal.app',
                        ),
                      ],
                    ),
                  ),
                ),

                // Center Pin Icon
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F8A50),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF0F8A50,
                            ).withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),

                // Top Badge: "Ketuk untuk Membuka Peta Interaktif"
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.touch_app_rounded,
                          size: 12,
                          color: Color(0xFF0F8A50),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Buka Peta Penuh',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F8A50),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Left Coordinates Badge
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '📍 ${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Action Buttons Row: Tombol Buka Peta & Tombol GPS Saat Ini
        Row(
          children: [
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 38,
                child: OutlinedButton.icon(
                  onPressed: _openLocationPicker,
                  icon: const Icon(
                    Icons.pin_drop_rounded,
                    size: 15,
                    color: Color(0xFF0F8A50),
                  ),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Pilih di Peta Google',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F8A50),
                      ),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFF0F8A50),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 38,
                child: ElevatedButton.icon(
                  onPressed: _isLoadingGps ? null : _getCurrentGpsLocation,
                  icon: _isLoadingGps
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.my_location_rounded,
                          size: 15,
                          color: Colors.white,
                        ),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'GPS Realtime',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F8A50),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Caption Note under map
        Text(
          'Titik koordinat akurat memudahkan kurir mengantar pesanan langsung ke depan pintu Anda.',
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
            color: isSelected
                ? const Color(0xFF0F8A50)
                : const Color(0xFFCBD5E1),
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
                color: isSelected
                    ? const Color(0xFF0F8A50)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
