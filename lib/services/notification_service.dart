import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import '../core/constants/api_config.dart';
import '../data/local/secure/secure_storage_service.dart';

/// Top-level background message handler wajib untuk FCM saat aplikasi di background / terminated
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Pastikan Firebase sudah diinisialisasi di isolate background
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  if (kDebugMode) {
    print('[FCM Background] 📩 Pesan diterima: ${message.messageId}');
    print('[FCM Background] Judul: ${message.notification?.title}');
    print('[FCM Background] Body: ${message.notification?.body}');
    print('[FCM Background] Data: ${message.data}');
  }
}

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  /// Global Navigator Key untuk navigasi rute saat notifikasi diklik
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Plugin notifikasi lokal
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  /// Android High Importance Notification Channel
  static const AndroidNotificationChannel _highImportanceChannel = AndroidNotificationChannel(
    'high_importance_channel',
    'Notifikasi Penting NutriMeal',
    description: 'Kanal untuk notifikasi status pesanan, catering, dan promo NutriMeal.',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  bool _isFirebaseReady = false;
  bool get isFirebaseReady => _isFirebaseReady;

  bool _isLocalNotificationReady = false;
  bool get isLocalNotificationReady => _isLocalNotificationReady;

  /// Notifier agar UI dapat mendengarkan perubahan token secara reaktif
  final ValueNotifier<String?> fcmTokenNotifier = ValueNotifier<String?>(null);

  /// Penyimpanan notifikasi lokal in-memory (disinkronkan dengan UI dan backend)
  final List<Map<String, dynamic>> _inMemoryNotifications = [];
  List<Map<String, dynamic>> get inMemoryNotifications =>
      List.unmodifiable(_inMemoryNotifications);

  /// Menambahkan notifikasi pesanan / pembaruan status ke sistem notifikasi
  Future<void> addOrderNotification({
    required String title,
    required String body,
    String type = 'order',
    String? orderId,
    String? packageName,
    int estimatedMinutes = 30,
    String? customerId,
  }) async {
    final now = DateTime.now();
    final notifItem = {
      'id': now.millisecondsSinceEpoch,
      'title': title,
      'body': body,
      'type': type,
      'order_id': orderId,
      'package_name': packageName,
      'estimated_minutes': estimatedMinutes,
      'created_at': now.toIso8601String(),
      'is_read': false,
      'customer_id': customerId,
    };

    _inMemoryNotifications.insert(0, notifItem);

    // Kirim pop-up banner notifikasi lokal ke OS perangkat
    await showInstantNotification(
      title: title,
      body: body,
      payload: '/notifikasi',
    );
  }

  /// Inisialisasi utama Notification Service
  Future<void> initialize() async {
    await _initLocalNotifications();
    await _initFirebaseMessaging();
  }

  /// 1. Inisialisasi flutter_local_notifications (Lokal tanpa server)
  Future<void> _initLocalNotifications() async {
    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          final payload = response.payload;
          if (kDebugMode) {
            print('[Local Notification] 🔔 Notifikasi diklik! Payload: $payload');
          }
          if (payload != null && payload.isNotEmpty) {
            _handleNavigation(payload);
          }
        },
      );

      // Buat notification channel di Android
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(_highImportanceChannel);
      }

      _isLocalNotificationReady = true;
      if (kDebugMode) {
        print('[NotificationService] ✅ Local Notifications siap.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[NotificationService] ⚠️ Gagal inisialisasi Local Notifications: $e');
      }
    }
  }

  /// 2. Inisialisasi Firebase Cloud Messaging (FCM)
  Future<void> _initFirebaseMessaging() async {
    try {
      // Periksa apakah Firebase sudah aktif
      if (Firebase.apps.isEmpty) {
        try {
          await Firebase.initializeApp();
        } catch (e) {
          if (kDebugMode) {
            print('[NotificationService] ℹ️ Firebase.initializeApp() belum dikonfigurasi / google-services.json belum dimasukkan: $e');
          }
          return;
        }
      }

      _isFirebaseReady = true;
      final messaging = FirebaseMessaging.instance;

      // Daftarkan background handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Setup presentasi notifikasi saat foreground di iOS
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Ambil FCM Token
      await _fetchFcmToken(messaging);

      // Dengarkan refresh token
      messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        fcmTokenNotifier.value = newToken;
        if (kDebugMode) {
          print('[NotificationService] 🔄 FCM Token diperbarui: $newToken');
        }
        sendTokenToBackend(newToken);
      });

      // Listener 1: Foreground Message (Aplikasi sedang dibuka)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('[NotificationService] 📩 Pesan Foreground diterima: ${message.notification?.title}');
        }
        _showForegroundNotification(message);
      });

      // Listener 2: Notifikasi di-tap dari status background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('[NotificationService] 📲 Notifikasi di-tap dari background: ${message.data}');
        }
        _handleRemoteMessageNavigation(message);
      });

      // Listener 3: Notifikasi yang membuka app dari kondisi terminated (mati total)
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        if (kDebugMode) {
          print('[NotificationService] 🚀 App dibuka dari terminated lewat notifikasi: ${initialMessage.data}');
        }
        // Delay sedikit agar MaterialApp & navigatorKey sudah terpasang
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleRemoteMessageNavigation(initialMessage);
        });
      }

      if (kDebugMode) {
        print('[NotificationService] ✅ Firebase Messaging berhasil diinisialisasi.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[NotificationService] ℹ️ Catatan: Firebase Messaging belum aktif (abaikan jika google-services.json belum diatur): $e');
      }
    }
  }

  /// Request izin sistem untuk menampilkan notifikasi
  Future<NotificationSettings?> requestPermission() async {
    try {
      if (!_isFirebaseReady) return null;
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      if (kDebugMode) {
        print('[NotificationService] Status izin notifikasi: ${settings.authorizationStatus}');
      }
      return settings;
    } catch (e) {
      if (kDebugMode) {
        print('[NotificationService] Error request permission: $e');
      }
      return null;
    }
  }

  /// Mengambil FCM Token dari perangkat
  Future<String?> _fetchFcmToken(FirebaseMessaging messaging) async {
    try {
      final token = await messaging.getToken();
      _fcmToken = token;
      fcmTokenNotifier.value = token;
      if (kDebugMode) {
        print('========================================================');
        print('🔥 [FCM TOKEN PERANGKAT ANDA]');
        print(token);
        print('========================================================');
      }
      sendTokenToBackend(token);
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('[NotificationService] Gagal mengambil FCM Token: $e');
      }
      return null;
    }
  }

  /// Refresh token secara manual dari UI / tombol refresh
  Future<String?> refreshFcmTokenManual() async {
    if (!_isFirebaseReady) return null;
    try {
      final messaging = FirebaseMessaging.instance;
      return await _fetchFcmToken(messaging);
    } catch (_) {
      return null;
    }
  }

  /// Mengirimkan FCM Token ke backend server agar server dapat mengirim push notification
  Future<bool> sendTokenToBackend(String? token, {String? customerId}) async {
    final activeToken = token ?? _fcmToken;
    if (activeToken == null || activeToken.isEmpty) return false;

    try {
      final creds = await SecureStorageService.instance.getUserCredentials();
      final targetCustomerId = customerId ?? creds['userId'];

      if (targetCustomerId == null || targetCustomerId.isEmpty) {
        if (kDebugMode) {
          print('[NotificationService] ℹ️ Customer ID belum ada, token tersimpan di lokal.');
        }
        return false;
      }

      final payload = jsonEncode({
        'customerId': targetCustomerId,
        'email': creds['email'],
        'fcmToken': activeToken,
      });

      for (final urlStr in ApiConfig.candidateFcmTokenUrls) {
        try {
          final url = Uri.parse(urlStr);
          final response = await http
              .post(
                url,
                headers: {'Content-Type': 'application/json'},
                body: payload,
              )
              .timeout(const Duration(seconds: 4));

          if (response.statusCode == 200) {
            if (kDebugMode) {
              print('[NotificationService] ✅ FCM token berhasil disinkronkan ke backend: $urlStr');
            }
            return true;
          }
        } catch (_) {}
      }
    } catch (e) {
      if (kDebugMode) {
        print('[NotificationService] ⚠️ Gagal mengirim FCM token ke backend: $e');
      }
    }
    return false;
  }

  /// Menampilkan banner notifikasi lokal saat ada push message masuk di Foreground
  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final route = message.data['route'] ?? message.data['screen'] ?? '/notifikasi';

    await _localNotifications.show(
      message.hashCode,
      notification.title ?? 'NutriMeal',
      notification.body ?? '',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _highImportanceChannel.id,
          _highImportanceChannel.name,
          channelDescription: _highImportanceChannel.description,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: route,
    );
  }

  /// Method untuk memicu notifikasi lokal instan (untuk uji coba di perangkat tanpa butuh backend / server)
  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
    int? id,
  }) async {
    final notificationId = id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await _localNotifications.show(
      notificationId,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _highImportanceChannel.id,
          _highImportanceChannel.name,
          channelDescription: _highImportanceChannel.description,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload ?? '/notifikasi',
    );

    if (kDebugMode) {
      print('[NotificationService] 🔔 Instant notification dipicu: $title');
    }
  }

  /// Navigasi berbasis RemoteMessage
  void _handleRemoteMessageNavigation(RemoteMessage message) {
    final route = message.data['route'] ?? message.data['screen'];
    if (route != null && route.toString().isNotEmpty) {
      _handleNavigation(route.toString());
    } else {
      _handleNavigation('/notifikasi');
    }
  }

  /// Menjalankan navigasi rute menggunakan [navigatorKey]
  void _handleNavigation(String routeOrPayload) {
    try {
      String targetRoute = routeOrPayload;
      // Jika payload berupa JSON
      if (routeOrPayload.startsWith('{')) {
        try {
          final decoded = jsonDecode(routeOrPayload);
          if (decoded is Map && decoded.containsKey('route')) {
            targetRoute = decoded['route'].toString();
          }
        } catch (_) {}
      }

      if (kDebugMode) {
        print('[NotificationService] 🧭 Melakukan navigasi ke route: $targetRoute');
      }

      navigatorKey.currentState?.pushNamed(targetRoute);
    } catch (e) {
      if (kDebugMode) {
        print('[NotificationService] ⚠️ Gagal navigasi: $e');
      }
    }
  }
}
