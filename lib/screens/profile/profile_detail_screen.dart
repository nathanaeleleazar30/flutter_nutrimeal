import 'package:image_picker/image_picker.dart';
import '../../core/constants/api_config.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/menu_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../address_screen.dart';
import '../bantuan_faq_screen.dart';

class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({super.key});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  String _name = '';
  String _email = '';
  String _phone = '';
  String? _avatarUrl;
  bool _twoFactorAuth = true;
  bool _isSaving = false;

  // Physical & Nutrition Data
  double _heightCm = 163.0;
  double _weightKg = 52.0;
  int _age = 24;
  double _nutritionPercent = 0.85;
  List<String> _selectedAllergies = [];
  String _dietGoal = 'Defisit Kalori';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileFromBackend();
    });
  }

  void _loadProfileFromBackend() async {
    final auth = context.read<AuthController>();
    await auth.fetchCustomerProfile();
    if (!mounted) return;
    setState(() {
      _name = auth.currentUserName ?? _name;
      _email = auth.currentUserEmail ?? _email;
      if (auth.customerPhone != null && auth.customerPhone!.isNotEmpty) {
        _phone = auth.customerPhone!;
      }
      _avatarUrl = auth.customerAvatarUrl;
      _heightCm = auth.customerHeight;
      _weightKg = auth.customerWeight;
      _age = auth.customerAge;
      _selectedAllergies = List.from(auth.customerAllergies);
      _dietGoal = auth.customerDietGoal;
      _twoFactorAuth = auth.customerTwoFactorAuth;
      _nutritionPercent = _selectedAllergies.isNotEmpty ? 1.0 : 0.85;
    });
  }

  double get _bmi => _weightKg / ((_heightCm / 100) * (_heightCm / 100));

  String get _bmiCategory {
    if (_bmi < 18.5) return 'Kurang (Underweight)';
    if (_bmi < 24.9) return 'Ideal & Normal (Healthy)';
    if (_bmi < 29.9) return 'Kelebihan (Overweight)';
    return 'Obesitas';
  }

  void _showEditNameDialog() {
    final controller = TextEditingController(text: _name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Ubah Nama Lengkap',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: AppColors.textDark,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: 'Masukkan nama lengkap',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF0F8A50), width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: const Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                setState(() => _name = newName);
                Navigator.pop(ctx);
                final auth = context.read<AuthController>();
                final ok = await auth.updateCustomerProfile(name: newName);
                if (ok) {
                  _showSuccessToast('Nama profil berhasil disimpan ke backend MySQL!');
                } else {
                  _showSuccessToast('Nama diperbarui secara lokal');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F8A50),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    final auth = context.read<AuthController>();
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      if (!mounted) return;
      setState(() => _isSaving = true);
      _showSuccessToast('Mengunggah foto profil dari perangkat ke server...');

      final uploadedUrl = await auth.uploadProfileImage(pickedFile);

      if (uploadedUrl != null) {
        if (!mounted) return;
        setState(() {
          _avatarUrl = uploadedUrl;
        });
        final ok = await auth.updateCustomerProfile(avatarUrl: uploadedUrl);
        if (!mounted) return;
        if (ok) {
          _showSuccessToast('Foto profil baru berhasil diunggah & disimpan ke MySQL!');
        } else {
          _showSuccessToast('Foto profil berhasil diunggah!');
        }
      } else {
        if (!mounted) return;
        _showErrorToast('Gagal mengunggah foto ke backend server. Periksa koneksi.');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorToast('Gagal memilih foto: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showAvatarPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ubah Foto Profil',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Pilih foto langsung dari galeri atau kamera perangkat Anda:',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),

              // Opsi 1: Kamera HP / Perangkat
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(color: Color(0xFFDCFCE7), shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF16A34A), size: 22),
                ),
                title: Text(
                  'Ambil Foto dari Kamera',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13.5),
                ),
                subtitle: Text(
                  'Gunakan kamera perangkat untuk memotret',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF94A3B8)),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUploadImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 10),

              // Opsi 2: Galeri / File Explorer Perangkat
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(color: Color(0xFFE0F2FE), shape: BoxShape.circle),
                  child: const Icon(Icons.photo_library_rounded, color: Color(0xFF0284C7), size: 22),
                ),
                title: Text(
                  'Pilih dari Galeri Perangkat',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13.5),
                ),
                subtitle: Text(
                  'Buka galeri foto atau penyimpanan perangkat',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF94A3B8)),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUploadImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _showNutritionDataSheet() {
    double tempHeight = _heightCm;
    double tempWeight = _weightKg;
    int tempAge = _age;
    List<String> tempAllergies = List.from(_selectedAllergies);
    String tempDietGoal = _dietGoal;

    final allAllergies = ['Kacang', 'Seafood', 'Gluten', 'Susu Sapi', 'Telur', 'Rendah Gula', 'Tidak Ada Alergi'];
    final allGoals = ['Defisit Kalori', 'Maintenance', 'Tinggi Protein', 'Rendah Karbo'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final bmiVal = tempWeight / ((tempHeight / 100) * (tempHeight / 100));
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 18,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Modal
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(color: Color(0xFFDCFCE7), shape: BoxShape.circle),
                                child: const Icon(Icons.fitness_center_rounded, color: Color(0xFF16A34A), size: 18),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Data Fisik & Nutrisi',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const Divider(height: 18),

                      // Measurements (Height & Weight)
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Tinggi Badan', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF64748B))),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${tempHeight.toInt()} cm', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800)),
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () => setSheetState(() => tempHeight = (tempHeight - 1).clamp(120, 220)),
                                            child: const Icon(Icons.remove_circle_outline, size: 20, color: Color(0xFF64748B)),
                                          ),
                                          const SizedBox(width: 4),
                                          InkWell(
                                            onTap: () => setSheetState(() => tempHeight = (tempHeight + 1).clamp(120, 220)),
                                            child: const Icon(Icons.add_circle_outline, size: 20, color: Color(0xFF0F8A50)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Berat Badan', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF64748B))),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${tempWeight.toStringAsFixed(1)} kg', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800)),
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () => setSheetState(() => tempWeight = (tempWeight - 0.5).clamp(30, 180)),
                                            child: const Icon(Icons.remove_circle_outline, size: 20, color: Color(0xFF64748B)),
                                          ),
                                          const SizedBox(width: 4),
                                          InkWell(
                                            onTap: () => setSheetState(() => tempWeight = (tempWeight + 0.5).clamp(30, 180)),
                                            child: const Icon(Icons.add_circle_outline, size: 20, color: Color(0xFF0F8A50)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // BMI Live Preview Card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.health_and_safety_rounded, color: Color(0xFF047857), size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'BMI: ${bmiVal.toStringAsFixed(1)} (${bmiVal < 18.5 ? "Underweight" : bmiVal < 25 ? "Ideal & Normal" : "Overweight"}) • Usia $tempAge th',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF065F46),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Riwayat Alergi
                      Text(
                        'Riwayat Alergi / Pantangan Makan',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textDark),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: allAllergies.map((allergy) {
                          final isSelected = tempAllergies.contains(allergy);
                          return FilterChip(
                            label: Text(allergy),
                            selected: isSelected,
                            selectedColor: const Color(0xFFDCFCE7),
                            checkmarkColor: const Color(0xFF0F8A50),
                            labelStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? const Color(0xFF0F8A50) : const Color(0xFF475569),
                            ),
                            backgroundColor: const Color(0xFFF1F5F9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: isSelected ? const Color(0xFF0F8A50) : const Color(0xFFE2E8F0)),
                            ),
                            onSelected: (val) {
                              setSheetState(() {
                                if (allergy == 'Tidak Ada Alergi') {
                                  tempAllergies = ['Tidak Ada Alergi'];
                                } else {
                                  tempAllergies.remove('Tidak Ada Alergi');
                                  if (val) {
                                    tempAllergies.add(allergy);
                                  } else {
                                    tempAllergies.remove(allergy);
                                  }
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),

                      // Target Pola Makan
                      Text(
                        'Target Katering Harian',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textDark),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: allGoals.map((goal) {
                          final isSelected = tempDietGoal == goal;
                          return ChoiceChip(
                            label: Text(goal),
                            selected: isSelected,
                            selectedColor: const Color(0xFF0F8A50),
                            labelStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? Colors.white : const Color(0xFF475569),
                            ),
                            backgroundColor: const Color(0xFFF1F5F9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: isSelected ? const Color(0xFF0F8A50) : const Color(0xFFE2E8F0)),
                            ),
                            onSelected: (val) {
                              if (val) setSheetState(() => tempDietGoal = goal);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              _heightCm = tempHeight;
                              _weightKg = tempWeight;
                              _age = tempAge;
                              _selectedAllergies = tempAllergies;
                              _dietGoal = tempDietGoal;
                              _nutritionPercent = tempAllergies.isNotEmpty ? 1.0 : 0.85;
                            });
                            Navigator.pop(ctx);
                            final auth = context.read<AuthController>();
                            final ok = await auth.updateCustomerProfile(
                              heightCm: tempHeight,
                              weightKg: tempWeight,
                              age: tempAge,
                              allergies: tempAllergies,
                              dietaryGoals: tempDietGoal,
                            );
                            if (ok) {
                              _showSuccessToast('Data nutrisi & fisik tersimpan di database MySQL!');
                            } else {
                              _showSuccessToast('Data nutrisi disimpan secara lokal');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F8A50),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            'Simpan Data Nutrisi',
                            style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditEmailDialog() {
    final controller = TextEditingController(text: _email);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Ubah Alamat Email',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: AppColors.textDark,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.mail_outline_rounded, color: Color(0xFF64748B), size: 18),
            hintText: 'nama@email.com',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF0F8A50), width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: const Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () async {
              final newEmail = controller.text.trim();
              if (newEmail.isNotEmpty && newEmail.contains('@')) {
                setState(() => _email = newEmail);
                Navigator.pop(ctx);
                final auth = context.read<AuthController>();
                final ok = await auth.updateCustomerProfile(email: newEmail);
                if (ok) {
                  _showSuccessToast('Alamat email berhasil disimpan ke backend MySQL!');
                } else {
                  _showSuccessToast('Email diperbarui secara lokal');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F8A50),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showEditPhoneDialog() {
    final controller = TextEditingController(text: _phone);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Ubah Nomor WhatsApp (Katering)',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: AppColors.textDark,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF64748B), size: 18),
            hintText: '+62 8xx-xxxx-xxxx',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF0F8A50), width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: const Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () async {
              final newPhone = controller.text.trim();
              if (newPhone.isNotEmpty) {
                setState(() => _phone = newPhone);
                Navigator.pop(ctx);
                final auth = context.read<AuthController>();
                final ok = await auth.updateCustomerProfile(phone: newPhone);
                if (ok) {
                  _showSuccessToast('Nomor WhatsApp berhasil disimpan ke backend MySQL!');
                } else {
                  _showSuccessToast('Nomor diperbarui secara lokal');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F8A50),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    bool obscureOld = true;
    bool obscureNew = true;
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                'Ubah Kata Sandi',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textDark),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: oldPassController,
                      obscureText: obscureOld,
                      decoration: InputDecoration(
                        labelText: 'Kata Sandi Saat Ini',
                        suffixIcon: IconButton(
                          icon: Icon(obscureOld ? Icons.visibility_off : Icons.visibility, size: 18),
                          onPressed: () => setDialogState(() => obscureOld = !obscureOld),
                        ),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: newPassController,
                      obscureText: obscureNew,
                      decoration: InputDecoration(
                        labelText: 'Kata Sandi Baru',
                        suffixIcon: IconButton(
                          icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility, size: 18),
                          onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                        ),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: confirmPassController,
                      obscureText: obscureNew,
                      decoration: const InputDecoration(
                        labelText: 'Konfirmasi Sandi Baru',
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Batal', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: const Color(0xFF64748B))),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (newPassController.text.trim().length < 6) {
                      _showErrorToast('Kata sandi baru minimal 6 karakter!');
                      return;
                    }
                    if (newPassController.text != confirmPassController.text) {
                      _showErrorToast('Konfirmasi kata sandi tidak cocok!');
                      return;
                    }
                    final auth = context.read<AuthController>();
                    Navigator.pop(ctx);
                    final res = await auth.changeCustomerPassword(
                      oldPassword: oldPassController.text.trim(),
                      newPassword: newPassController.text.trim(),
                    );
                    if (res['success'] == true) {
                      _showSuccessToast(res['message'] ?? 'Kata sandi berhasil diperbarui di database MySQL!');
                    } else {
                      _showErrorToast(res['message'] ?? 'Kata sandi saat ini tidak cocok.');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F8A50),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Perbarui', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSuccessToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF0F8A50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Header with soft mint background matching Image 2
            _buildHeader(context),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  children: [
                    // 1. Avatar & Name (Interactive edit)
                    _buildAvatarSection(),
                    const SizedBox(height: 16),

                    // 2. Kelengkapan Data Nutrisi Card (Interactive bottom sheet)
                    _buildNutritionProgressCard(),
                    const SizedBox(height: 16),

                    // 3. Kontak & Akun Section Card (Interactive fields)
                    _buildContactSection(),
                    const SizedBox(height: 16),

                    // 4. Keamanan Akun Section Card (Interactive password & 2FA)
                    _buildSecuritySection(),
                    const SizedBox(height: 20),

                    // 5. Action Buttons
                    _buildActionButtons(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
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
              'Informasi Pribadi',
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

  Widget _buildAvatarSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _showAvatarPickerSheet,
          child: Stack(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: (_avatarUrl != null && _avatarUrl!.trim().isNotEmpty)
                    ? Image.network(
                        ApiConfig.resolveImageUrl(_avatarUrl),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildAvatarPlaceholder(),
                      )
                    : _buildAvatarPlaceholder(),
              ),
              Positioned(
                bottom: 2,
                right: 4,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F8A50),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.edit_rounded, color: Colors.white, size: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _showEditNameDialog,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.edit_outlined, color: Color(0xFF0F8A50), size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarPlaceholder() {
    final initial = _name.trim().isNotEmpty ? _name.trim()[0].toUpperCase() : '';
    return Container(
      color: const Color(0xFFDCFCE7),
      alignment: Alignment.center,
      child: initial.isNotEmpty
          ? Text(
              initial,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F8A50),
              ),
            )
          : const Icon(Icons.person_rounded, color: Color(0xFF16A34A), size: 44),
    );
  }

  Widget _buildNutritionProgressCard() {
    return GestureDetector(
      onTap: _showNutritionDataSheet,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified_outlined, color: Color(0xFF0F8A50), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Kelengkapan Data Nutrisi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '${(_nutritionPercent * 100).toInt()}% Lengkap',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F8A50),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right_rounded, color: Color(0xFF0F8A50), size: 18),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _nutritionPercent,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0F8A50)),
                minHeight: 5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Data Fisik: ${_heightCm.toInt()} cm • ${_weightKg.toInt()} kg (BMI: ${_bmiCategory.split(' ').first}) • Tap untuk lengkapi riwayat alergi.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: const Color(0xFF64748B),
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          // Section Title
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFF0F8A50),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_box_rounded, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                'Kontak & Akun',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Alamat Email
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Alamat Email',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
              GestureDetector(
                onTap: _showEditEmailDialog,
                child: Text(
                  'Ubah',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F8A50),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _showEditEmailDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.mail_outline_rounded, color: Color(0xFF64748B), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _email,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_rounded, color: Color(0xFF166534), size: 12),
                        const SizedBox(width: 3),
                        Text(
                          'Terverifikasi',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF166534),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Nomor WhatsApp (Katering)
          Text(
            'Nomor WhatsApp (Katering)',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _showEditPhoneDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF64748B), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _phone,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  Text(
                    'Ganti',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F8A50),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Alamat Pengiriman Utama
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Alamat Pengiriman Utama',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
              GestureDetector(
                onTap: () {
                  final controller = context.read<NutriMealMenuController>();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddressFormScreen(
                        mode: AddressFormMode.edit,
                        address: controller.deliveryAddress,
                      ),
                    ),
                  ).then((_) => setState(() {}));
                },
                child: Text(
                  'Ubah Alamat',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F8A50),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Consumer<NutriMealMenuController>(
            builder: (context, controller, child) {
              final addr = controller.deliveryAddress;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddressFormScreen(
                        mode: AddressFormMode.edit,
                        address: addr,
                      ),
                    ),
                  ).then((_) => setState(() {}));
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined, color: Color(0xFF0F8A50), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              addr.label.isNotEmpty ? addr.label : 'Rumah (Senopati)',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              addr.fullAddress.isNotEmpty
                                  ? addr.fullAddress
                                  : 'Jl. Senopati No. 42, Kebayoran Baru, Jakarta Selatan, DKI Jakarta 12190',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                color: const Color(0xFF64748B),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 18),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          // Section Title
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFF0F8A50),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.security_rounded, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                'Keamanan Akun',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Kata Sandi (Interactive modal)
          GestureDetector(
            onTap: _showChangePasswordDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline_rounded, color: Color(0xFF64748B), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kata Sandi',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                        ),
                        Text(
                          '••••••••••••',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF64748B), letterSpacing: 1.5),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      'Ubah Sandi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F8A50),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Autentikasi 2 Langkah (Interactive toggle)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_outlined, color: Color(0xFF0F8A50), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Autentikasi 2 Langkah',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                      ),
                      Text(
                        _twoFactorAuth ? 'Aktif via SMS / WhatsApp' : 'Nonaktif',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: _twoFactorAuth ? const Color(0xFF0F8A50) : const Color(0xFF94A3B8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: _twoFactorAuth,
                    activeThumbColor: Colors.white,
                    activeTrackColor: const Color(0xFF0F8A50),
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: const Color(0xFFCBD5E1),
                    onChanged: (val) async {
                      setState(() => _twoFactorAuth = val);
                      final auth = context.read<AuthController>();
                      await auth.updateCustomerProfile(twoFactorAuth: val);
                      _showSuccessToast(
                        val ? 'Autentikasi 2 Langkah diaktifkan & disimpan ke backend' : 'Autentikasi 2 Langkah dinonaktifkan',
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Button 1: Simpan Perubahan (Commit ke Backend Express & MySQL)
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isSaving
                ? null
                : () async {
                    setState(() => _isSaving = true);
                    final auth = context.read<AuthController>();
                    final ok = await auth.updateCustomerProfile(
                      name: _name,
                      email: _email,
                      phone: _phone,
                      avatarUrl: _avatarUrl,
                      heightCm: _heightCm,
                      weightKg: _weightKg,
                      age: _age,
                      allergies: _selectedAllergies,
                      dietaryGoals: _dietGoal,
                      twoFactorAuth: _twoFactorAuth,
                    );
                    if (!context.mounted) return;
                    setState(() => _isSaving = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ok
                              ? 'Semua informasi pribadi berhasil disimpan ke Database MySQL!'
                              : 'Perubahan informasi pribadi tersimpan secara lokal.',
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                        ),
                        backgroundColor: const Color(0xFF0F8A50),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                    Navigator.pop(context);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F8A50),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Simpan Perubahan',
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
        const SizedBox(height: 10),

        // Button 2: Pusat Bantuan & FAQ >
        SizedBox(
          width: double.infinity,
          height: 46,
          child: OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BantuanFaqScreen()),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.help_outline_rounded, size: 16, color: Color(0xFF475569)),
                const SizedBox(width: 6),
                Text(
                  'Pusat Bantuan & FAQ',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF475569),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF475569)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Footer: Keluar dari Akun • Hapus Akun
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Keluar dari Akun?'),
                    content: const Text('Apakah Anda yakin ingin keluar dari sesi aplikasi?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
                        child: const Text('Keluar', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
              child: Row(
                children: [
                  const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Keluar dari Akun',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                width: 3.5,
                height: 3.5,
                decoration: const BoxDecoration(
                  color: Color(0xFFCBD5E1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Hapus Akun'),
                    content: const Text('Akun dan seluruh riwayat langganan Anda akan dihapus permanen. Tindakan ini tidak dapat dibatalkan.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
                        child: const Text('Hapus Akun', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
              child: Text(
                'Hapus Akun',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
