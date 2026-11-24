import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Jenis izin perangkat yang didukung secara terpusat di NutriMeal
enum AppPermissionType { notification, camera, gallery, location }

extension AppPermissionTypeExtension on AppPermissionType {
  String get displayName {
    switch (this) {
      case AppPermissionType.notification:
        return 'Notifikasi';
      case AppPermissionType.camera:
        return 'Kamera';
      case AppPermissionType.gallery:
        return 'Galeri Foto';
      case AppPermissionType.location:
        return 'Lokasi GPS';
    }
  }

  IconData get icon {
    switch (this) {
      case AppPermissionType.notification:
        return Icons.notifications_active_outlined;
      case AppPermissionType.camera:
        return Icons.camera_alt_outlined;
      case AppPermissionType.gallery:
        return Icons.photo_library_outlined;
      case AppPermissionType.location:
        return Icons.location_on_outlined;
    }
  }

  String get defaultReason {
    switch (this) {
      case AppPermissionType.notification:
        return 'NutriMeal membutuhkan izin notifikasi agar Anda mendapatkan info promo, jadwal catering, dan status pesanan tepat waktu.';
      case AppPermissionType.camera:
        return 'NutriMeal membutuhkan izin kamera untuk mengambil foto profil langsung atau memindai dokumen.';
      case AppPermissionType.gallery:
        return 'NutriMeal membutuhkan izin galeri untuk memilih foto profil atau bukti pembayaran dari penyimpanan HP Anda.';
      case AppPermissionType.location:
        return 'NutriMeal membutuhkan izin lokasi agar kurir dapat mengantar pesanan makanan catering ke alamat Anda secara akurat.';
    }
  }
}

class PermissionService {
  PermissionService._internal();
  static final PermissionService instance = PermissionService._internal();

  /// Mengonversi tipe izin aplikasi ke objek [Permission] dari package permission_handler
  Permission _mapToPermission(AppPermissionType type) {
    switch (type) {
      case AppPermissionType.notification:
        return Permission.notification;
      case AppPermissionType.camera:
        return Permission.camera;
      case AppPermissionType.gallery:
        // Pada iOS dan Android 13+ menggunakan photos, versi lawas fallback ke storage
        return Permission.photos;
      case AppPermissionType.location:
        return Permission.locationWhenInUse;
    }
  }

  /// Cek status izin saat ini
  Future<PermissionStatus> checkPermission(AppPermissionType type) async {
    final permission = _mapToPermission(type);
    var status = await permission.status;

    // Khusus Android versi lama yang belum mendukung Permission.photos
    if (type == AppPermissionType.gallery &&
        Platform.isAndroid &&
        status.isDenied) {
      final storageStatus = await Permission.storage.status;
      if (storageStatus.isGranted || storageStatus.isLimited) {
        return storageStatus;
      }
    }

    return status;
  }

  /// Meminta izin ke pengguna. Jika ditolak permanen, menampilkan dialog ramah untuk buka pengaturan
  Future<PermissionStatus> requestPermission(
    BuildContext context,
    AppPermissionType type, {
    bool showDialogIfPermanentlyDenied = true,
  }) async {
    final permission = _mapToPermission(type);
    var status = await permission.request();

    // Fallback storage untuk galeri pada Android < 13
    if (type == AppPermissionType.gallery &&
        Platform.isAndroid &&
        !status.isGranted) {
      final storageStatus = await Permission.storage.request();
      if (storageStatus.isGranted || storageStatus.isLimited) {
        status = storageStatus;
      }
    }

    // Jika ditolak permanen, tawarkan buka pengaturan HP
    if (status.isPermanentlyDenied &&
        showDialogIfPermanentlyDenied &&
        context.mounted) {
      await showPermanentlyDeniedDialog(context, type);
    }

    return status;
  }

  /// Dialog ramah saat izin ditolak secara permanen oleh sistem operasi
  Future<void> showPermanentlyDeniedDialog(
    BuildContext context,
    AppPermissionType type, {
    String? customReason,
  }) async {
    final theme = Theme.of(context);

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          actionsPadding: const EdgeInsets.all(16),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  type.icon,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Izin ${type.displayName}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customReason ?? type.defaultReason,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.amber.shade800,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Izin ini sebelumnya dinonaktifkan permanen. Anda dapat mengaktifkannya langsung di Pengaturan Aplikasi.',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                Navigator.of(dialogCtx).pop();
                await openAppSettings();
              },
              child: const Text('Buka Pengaturan'),
            ),
          ],
        );
      },
    );
  }

  /// Shortcut untuk membuka halaman App Settings di HP
  Future<bool> openSettings() async {
    return await openAppSettings();
  }
}
