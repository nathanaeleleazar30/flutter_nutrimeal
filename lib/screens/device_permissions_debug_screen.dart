import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/constants/app_colors.dart';
import '../services/notification_service.dart';
import '../services/permission_service.dart';

class DevicePermissionsDebugScreen extends StatefulWidget {
  const DevicePermissionsDebugScreen({super.key});

  @override
  State<DevicePermissionsDebugScreen> createState() =>
      _DevicePermissionsDebugScreenState();
}

class _DevicePermissionsDebugScreenState
    extends State<DevicePermissionsDebugScreen> {
  // Status izin masing-masing
  final Map<AppPermissionType, PermissionStatus> _permissionStatuses = {
    AppPermissionType.notification: PermissionStatus.denied,
    AppPermissionType.camera: PermissionStatus.denied,
    AppPermissionType.gallery: PermissionStatus.denied,
    AppPermissionType.location: PermissionStatus.denied,
  };

  bool _isLoadingStatuses = true;

  // Media preview
  File? _capturedImage;
  String? _imageSourceType;

  // Location result
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  String? _locationError;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _refreshAllPermissions();
  }

  Future<void> _refreshAllPermissions() async {
    setState(() => _isLoadingStatuses = true);
    for (final type in AppPermissionType.values) {
      final status = await PermissionService.instance.checkPermission(type);
      _permissionStatuses[type] = status;
    }
    if (mounted) {
      setState(() => _isLoadingStatuses = false);
    }
  }

  Future<void> _handleRequestPermission(AppPermissionType type) async {
    final status = await PermissionService.instance.requestPermission(
      context,
      type,
    );
    setState(() {
      _permissionStatuses[type] = status;
    });

    if (type == AppPermissionType.notification) {
      await NotificationService.instance.requestPermission();
    }
  }

  // Uji Coba Kamera
  Future<void> _pickFromCamera() async {
    final status = await PermissionService.instance.requestPermission(
      context,
      AppPermissionType.camera,
    );
    if (!status.isGranted && !status.isLimited) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin kamera diperlukan untuk mengambil foto.')),
        );
      }
      return;
    }

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (photo != null) {
        setState(() {
          _capturedImage = File(photo.path);
          _imageSourceType = 'Kamera';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka kamera: $e')),
        );
      }
    }
  }

  // Uji Coba Galeri
  Future<void> _pickFromGallery() async {
    final status = await PermissionService.instance.requestPermission(
      context,
      AppPermissionType.gallery,
    );
    if (!status.isGranted && !status.isLimited) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin galeri diperlukan untuk memilih foto.')),
        );
      }
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _capturedImage = File(image.path);
          _imageSourceType = 'Galeri Foto';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka galeri: $e')),
        );
      }
    }
  }

  // Uji Coba GPS / Lokasi
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      final status = await PermissionService.instance.requestPermission(
        context,
        AppPermissionType.location,
      );

      if (!status.isGranted && !status.isLimited) {
        setState(() {
          _locationError = 'Izin lokasi belum disetujui.';
          _isLoadingLocation = false;
        });
        return;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError = 'Layanan GPS di HP dalam keadaan mati. Silakan aktifkan GPS.';
          _isLoadingLocation = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _locationError = 'Gagal membaca koordinat GPS: $e';
        _isLoadingLocation = false;
      });
    }
  }

  // Uji Coba Local Notification
  Future<void> _sendTestNotification() async {
    // Pastikan izin notifikasi sudah aktif
    await _handleRequestPermission(AppPermissionType.notification);

    await NotificationService.instance.showInstantNotification(
      title: 'Pesanan NutriMeal Sedang Disiapkan! 🥗',
      body: 'Catering sehat paket Defisit Kalori sedang dimasak oleh chef. Ketuk untuk melihat notifikasi.',
      payload: '/notifikasi',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔔 Notifikasi instan berhasil dikirim! Periksa bar notifikasi HP Anda.'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    }
  }

  // Salin Token FCM
  void _copyFcmToken(String token) {
    Clipboard.setData(ClipboardData(text: token));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Token FCM berhasil disalin ke clipboard!'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA),
      appBar: AppBar(
        title: const Text(
          'Debug Izin & Notifikasi',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Cek Ulang Semua Izin',
            onPressed: _refreshAllPermissions,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoBanner(),
          const SizedBox(height: 16),
          _buildSectionHeader('1. Manajemen Izin Perangkat Terpusat'),
          const SizedBox(height: 8),
          ...AppPermissionType.values.map(_buildPermissionTile),
          const SizedBox(height: 20),
          _buildSectionHeader('2. Uji Coba Push & Notifikasi Lokal (Tanpa Server)'),
          const SizedBox(height: 8),
          _buildNotificationCard(),
          const SizedBox(height: 20),
          _buildSectionHeader('3. Token FCM Perangkat (Firebase Cloud Messaging)'),
          const SizedBox(height: 8),
          _buildFcmTokenCard(),
          const SizedBox(height: 20),
          _buildSectionHeader('4. Uji Coba Akses Perangkat Fisik'),
          const SizedBox(height: 8),
          _buildHardwareTestCard(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_user_outlined, color: AppColors.primaryGreen, size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Halaman ini dirancang untuk menguji izin perangkat fisik dan Push Notification secara lokal tanpa ketergantungan pada backend server.',
              style: TextStyle(fontSize: 12.5, height: 1.4, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildPermissionTile(AppPermissionType type) {
    final status = _permissionStatuses[type] ?? PermissionStatus.denied;
    final isGranted = status.isGranted || status.isLimited;
    final isPermanentlyDenied = status.isPermanentlyDenied;

    Color badgeColor;
    String badgeText;
    IconData badgeIcon;

    if (isGranted) {
      badgeColor = Colors.green;
      badgeText = 'Disetujui';
      badgeIcon = Icons.check_circle;
    } else if (isPermanentlyDenied) {
      badgeColor = Colors.deepOrange;
      badgeText = 'Ditolak Permanen';
      badgeIcon = Icons.block;
    } else {
      badgeColor = Colors.amber.shade800;
      badgeText = 'Belum Disetujui';
      badgeIcon = Icons.help_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isGranted
                      ? Colors.green.shade50
                      : (isPermanentlyDenied ? Colors.deepOrange.shade50 : Colors.amber.shade50),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(type.icon, color: badgeColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.displayName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(badgeIcon, size: 13, color: badgeColor),
                        const SizedBox(width: 4),
                        Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: badgeColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!isGranted)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPermanentlyDenied
                        ? Colors.deepOrange
                        : AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: isPermanentlyDenied
                      ? () => PermissionService.instance.openSettings()
                      : () => _handleRequestPermission(type),
                  child: Text(isPermanentlyDenied ? 'Buka Pengaturan' : 'Minta Izin'),
                )
              else
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: const BorderSide(color: Colors.green),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    textStyle: const TextStyle(fontSize: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _handleRequestPermission(type),
                  child: const Text('Cek Ulang'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            type.defaultReason,
            style: const TextStyle(fontSize: 11.5, color: Colors.black54, height: 1.3),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.notifications_active, color: AppColors.primaryGreen, size: 22),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Uji Coba Banner Notifikasi Lokal',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Klik tombol di bawah untuk memunculkan notifikasi instan langsung di bilah status HP tanpa butuh server/FCM. Mengetuk notifikasi akan membuka halaman Notifikasi.',
            style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.4),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text(
                'Kirim Test Notifikasi Lokal Sekarang',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              onPressed: _sendTestNotification,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFcmTokenCard() {
    return ValueListenableBuilder<String?>(
      valueListenable: NotificationService.instance.fcmTokenNotifier,
      builder: (context, token, _) {
        final currentToken = token ?? NotificationService.instance.fcmToken;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.vpn_key_outlined, color: Colors.indigo, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'FCM Device Registration Token',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    tooltip: 'Refresh Token',
                    onPressed: () async {
                      await NotificationService.instance.refreshFcmTokenManual();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Token ini dapat langsung ditempel ke Firebase Console (Messaging > Test on Device) untuk mengirim notifikasi uji coba:',
                style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.4),
              ),
              const SizedBox(height: 10),
              if (currentToken != null && currentToken.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SelectableText(
                    currentToken,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Salin Token FCM ke Clipboard'),
                    onPressed: () => _copyFcmToken(currentToken),
                  ),
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Token FCM belum tersedia.',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Pastikan berkas google-services.json (Android) atau GoogleService-Info.plist (iOS) sudah disiapkan di proyek. Notifikasi lokal tetap dapat diuji tanpa FCM.',
                        style: TextStyle(fontSize: 11.5, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildHardwareTestCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Uji Kamera & Galeri Foto',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.camera_alt, size: 18),
                  label: const Text('Buka Kamera', style: TextStyle(fontSize: 12)),
                  onPressed: _pickFromCamera,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.photo_library, size: 18),
                  label: const Text('Pilih dari Galeri', style: TextStyle(fontSize: 12)),
                  onPressed: _pickFromGallery,
                ),
              ),
            ],
          ),
          if (_capturedImage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        _imageSourceType == 'Kamera' ? Icons.camera : Icons.photo,
                        size: 16,
                        color: AppColors.primaryGreen,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Hasil foto dari $_imageSourceType:',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _capturedImage!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Divider(height: 28),
          const Text(
            'Uji Lokasi GPS (Geolocator)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: _isLoadingLocation
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location, size: 18),
              label: Text(
                _isLoadingLocation ? 'Membaca GPS...' : 'Ambil Lokasi Saat Ini',
                style: const TextStyle(fontSize: 12),
              ),
              onPressed: _isLoadingLocation ? null : _getCurrentLocation,
            ),
          ),
          if (_currentPosition != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.check_circle, size: 16, color: Colors.green),
                      SizedBox(width: 6),
                      Text(
                        'Koordinat Lokasi Berhasil Didapatkan:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Latitude: ${_currentPosition!.latitude}',
                      style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
                  Text('Longitude: ${_currentPosition!.longitude}',
                      style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
                  Text(
                      'Akurasi: ±${_currentPosition!.accuracy.toStringAsFixed(1)} meter',
                      style: const TextStyle(fontSize: 11, color: Colors.black54)),
                ],
              ),
            ),
          ],
          if (_locationError != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, size: 16, color: Colors.red),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _locationError!,
                      style: const TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
