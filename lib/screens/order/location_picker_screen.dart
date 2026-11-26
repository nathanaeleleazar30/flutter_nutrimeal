import 'dart:async';
import 'dart:convert';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/center_feedback_toast.dart';

class LocationPinResult {
  final LatLng point;
  final String fullAddress;
  final String area;
  final String road;

  const LocationPinResult({
    required this.point,
    required this.fullAddress,
    required this.area,
    required this.road,
  });
}

enum MapTileType { googleRoadmap, googleSatellite, openStreetMap }

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initialPosition;
  final String? initialAddress;

  const LocationPickerScreen({
    super.key,
    this.initialPosition,
    this.initialAddress,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen>
    with SingleTickerProviderStateMixin {
  late final MapController _mapController;

  // Default coordinate: Malang Center (-7.9826, 112.6308)
  late LatLng _currentCenter;
  double _currentZoom = 16.5;

  MapTileType _currentTileType = MapTileType.googleRoadmap;

  bool _isMapMoving = false;
  bool _isLoadingGps = false;
  bool _isReverseGeocoding = false;

  String _detectedAddress = 'Memuat titik lokasi...';
  String _detectedRoad = 'Titik Lokasi';
  String _detectedArea = 'Malang, Jawa Timur';

  Timer? _debounceTimer;

  // Search places
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    _currentCenter = widget.initialPosition ?? const LatLng(-7.9826, 112.6308);
    if (widget.initialAddress != null && widget.initialAddress!.isNotEmpty) {
      _detectedAddress = widget.initialAddress!;
      _detectedRoad = widget.initialAddress!.split(',').first;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialPosition == null) {
        _getCurrentGpsLocation(silent: true);
      } else {
        _reverseGeocode(_currentCenter);
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchDebounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _mapController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // GPS REALTIME LOCATION
  // ---------------------------------------------------------------------------
  Future<void> _getCurrentGpsLocation({bool silent = false}) async {
    setState(() => _isLoadingGps = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!silent && mounted) {
          _showToast('GPS / Layanan lokasi belum aktif di perangkat Anda.');
        }
        setState(() => _isLoadingGps = false);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!silent && mounted) {
            _showToast('Izin akses lokasi ditolak.');
          }
          setState(() => _isLoadingGps = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!silent && mounted) {
          _showToast(
            'Izin lokasi ditolak permanen. Buka pengaturan untuk mengizinkan.',
          );
          await openAppSettings();
        }
        setState(() => _isLoadingGps = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final userPoint = LatLng(position.latitude, position.longitude);
      if (!mounted) return;

      setState(() {
        _currentCenter = userPoint;
        _isLoadingGps = false;
      });

      _mapController.move(userPoint, 17.0);
      _reverseGeocode(userPoint);

      if (!silent) {
        _showToast('Lokasi GPS realtime berhasil dideteksi!');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingGps = false);
        if (!silent) _showToast('Gagal mengambil titik GPS: $e');
      }
    }
  }

  // ---------------------------------------------------------------------------
  // REVERSE GEOCODING (OSM Nominatim API)
  // ---------------------------------------------------------------------------
  Future<void> _reverseGeocode(LatLng point) async {
    setState(() => _isReverseGeocoding = true);
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

        final road =
            address['road']?.toString() ??
            address['suburb']?.toString() ??
            address['village']?.toString() ??
            'Titik Terpilih';

        final areaParts = [
          address['suburb'] ?? address['village'] ?? address['city_district'],
          address['city'] ?? address['town'] ?? address['county'],
        ].where((e) => e != null && e.toString().isNotEmpty).toList();

        final area = areaParts.isNotEmpty
            ? areaParts.join(', ')
            : 'Malang, Jawa Timur';

        if (mounted) {
          setState(() {
            _detectedAddress = displayName.isNotEmpty
                ? displayName
                : 'Alamat terdeteksi di koordinat ini';
            _detectedRoad = road;
            _detectedArea = area;
            _isReverseGeocoding = false;
          });
        }
        return;
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _detectedAddress =
            'Koordinat: ${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}';
        _detectedRoad = 'Titik Terpilih';
        _isReverseGeocoding = false;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // SEARCH PLACES / STREET
  // ---------------------------------------------------------------------------
  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 400), () async {
      setState(() => _isSearching = true);
      try {
        final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=5&countrycodes=id',
        );

        final response = await http
            .get(
              url,
              headers: {'User-Agent': 'NutriMealApp/1.0 (flutter.nutrimeal)'},
            )
            .timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final list = jsonDecode(response.body) as List<dynamic>;
          if (mounted) {
            setState(() {
              _searchResults = list
                  .map((e) => e as Map<String, dynamic>)
                  .toList();
              _isSearching = false;
            });
          }
          return;
        }
      } catch (_) {}

      if (mounted) setState(() => _isSearching = false);
    });
  }

  void _selectSearchResult(Map<String, dynamic> item) {
    final lat = double.tryParse(item['lat']?.toString() ?? '');
    final lon = double.tryParse(item['lon']?.toString() ?? '');
    if (lat != null && lon != null) {
      final target = LatLng(lat, lon);
      setState(() {
        _currentCenter = target;
        _searchResults = [];
        _searchController.text = item['display_name'] ?? '';
      });
      _searchFocusNode.unfocus();
      _mapController.move(target, 17.0);
      _reverseGeocode(target);
    }
  }

  void _showToast(String msg) {
    if (!mounted) return;
    CenterFeedbackToast.showInfo(context, message: msg);
  }

  String _getTileUrl() {
    switch (_currentTileType) {
      case MapTileType.googleRoadmap:
        // Google Maps Standard Roadmap
        return 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}';
      case MapTileType.googleSatellite:
        // Google Maps Hybrid (Satellite + Road Labels)
        return 'https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}';
      case MapTileType.openStreetMap:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 1. PETA INTERAKTIF GOOGLE MAPS (FLUTTER MAP ENGINE)
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentCenter,
                initialZoom: _currentZoom,
                minZoom: 4.0,
                maxZoom: 19.5,
                onPositionChanged: (camera, hasGesture) {
                  setState(() {
                    _currentCenter = camera.center;
                    _currentZoom = camera.zoom;
                    if (hasGesture) {
                      _isMapMoving = true;
                    }
                  });
                  _debounceTimer?.cancel();
                  _debounceTimer = Timer(const Duration(milliseconds: 350), () {
                    if (mounted) {
                      setState(() => _isMapMoving = false);
                      _reverseGeocode(_currentCenter);
                    }
                  });
                },
                onTap: (_, point) {
                  setState(() {
                    _currentCenter = point;
                    _isMapMoving = false;
                  });
                  _mapController.move(point, _currentZoom);
                  _reverseGeocode(point);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: _getTileUrl(),
                  userAgentPackageName: 'com.nutrimeal.app',
                  maxZoom: 19,
                ),
              ],
            ),
          ),

          // 2. PIN LOKASI PRESISI DI TENGAH LAYAR DENGAN ANIMASI FLOAT/DROP
          IgnorePointer(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 38,
                ), // Mengarahkan ujung jarum pin tepat ke titik tengah
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Floating Tooltip Tag
                    AnimatedOpacity(
                      opacity: _isMapMoving ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F8A50),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'Titik Antar Pesanan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    // Pin Icon dengan Efek Animasi Melayang saat Map digeser
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      transform: Matrix4.translationValues(
                        0,
                        _isMapMoving ? -12 : 0,
                        0,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF0F8A50),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF0F8A50,
                                  ).withValues(alpha: 0.35),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bayangan Pin di Permukaan Peta
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: _isMapMoving ? 10 : 16,
                      height: _isMapMoving ? 3 : 6,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(
                          alpha: _isMapMoving ? 0.2 : 0.45,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. TOP BAR: TOMBOL KEMBALI & PENCARIAN ALAMAT REALTIME
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Row(
                  children: [
                    // Tombol Kembali
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Search Field
                    Expanded(
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.10),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          onChanged: _onSearchChanged,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Cari jalan, gedung, atau area...',
                            hintStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              color: const Color(0xFF94A3B8),
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: Color(0xFF0F8A50),
                              size: 20,
                            ),
                            suffixIcon: _isSearching
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF0F8A50),
                                      ),
                                    ),
                                  )
                                : (_searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(
                                            Icons.clear_rounded,
                                            size: 18,
                                            color: Color(0xFF94A3B8),
                                          ),
                                          onPressed: () {
                                            _searchController.clear();
                                            setState(() => _searchResults = []);
                                          },
                                        )
                                      : null),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Suggestion Search Dropdown
                if (_searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      itemBuilder: (ctx, index) {
                        final item = _searchResults[index];
                        return ListTile(
                          dense: true,
                          leading: const Icon(
                            Icons.location_on_outlined,
                            color: Color(0xFF0F8A50),
                            size: 20,
                          ),
                          title: Text(
                            item['display_name'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                          onTap: () => _selectSearchResult(item),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // 4. FLOATING CONTROLS: LAYER SWITCHER, ZOOM IN/OUT, & GPS BUTTON
          Positioned(
            right: 16,
            bottom: 240,
            child: Column(
              children: [
                // Layer Switcher (Peta Standar vs Satelit Google)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentTileType =
                          _currentTileType == MapTileType.googleRoadmap
                          ? MapTileType.googleSatellite
                          : MapTileType.googleRoadmap;
                    });
                    _showToast(
                      _currentTileType == MapTileType.googleSatellite
                          ? 'Mode Satelit Google Maps Aktif'
                          : 'Mode Peta Jalan Google Maps Aktif',
                    );
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      _currentTileType == MapTileType.googleSatellite
                          ? Icons.map_rounded
                          : Icons.satellite_alt_rounded,
                      color: const Color(0xFF0F8A50),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Zoom In
                GestureDetector(
                  onTap: () {
                    _currentZoom = (_currentZoom + 1).clamp(4.0, 19.5);
                    _mapController.move(_currentCenter, _currentZoom);
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: AppColors.textDark,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Zoom Out
                GestureDetector(
                  onTap: () {
                    _currentZoom = (_currentZoom - 1).clamp(4.0, 19.5);
                    _mapController.move(_currentCenter, _currentZoom);
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.remove_rounded,
                      color: AppColors.textDark,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Tombol GPS Lokasi Saya Real-Time
                GestureDetector(
                  onTap: () => _getCurrentGpsLocation(silent: false),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F8A50),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF0F8A50,
                          ).withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _isLoadingGps
                        ? const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.my_location_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                  ),
                ),
              ],
            ),
          ),

          // 5. BOTTOM CARD: INFORMASI ALAMAT TERDETEKSI & TOMBOL KONFIRMASI TITIK
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 18,
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle Bar
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Header Baris: Label & Live Coordinates Badge
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
                            'Titik Lokasi Pengantaran',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_currentCenter.latitude.toStringAsFixed(5)}, ${_currentCenter.longitude.toStringAsFixed(5)}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Nama Jalan & Lokasi
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _detectedRoad,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isReverseGeocoding
                                  ? 'Mencari detail alamat...'
                                  : _detectedAddress,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: const Color(0xFF64748B),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_isReverseGeocoding)
                        const Padding(
                          padding: EdgeInsets.only(left: 10, top: 4),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF0F8A50),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tombol Konfirmasi Pilih Titik Ini
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final result = LocationPinResult(
                          point: _currentCenter,
                          fullAddress: _detectedAddress,
                          area: _detectedArea,
                          road: _detectedRoad,
                        );
                        Navigator.pop(context, result);
                      },
                      icon: const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Text(
                        'Pilih Titik Lokasi Ini',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F8A50),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
