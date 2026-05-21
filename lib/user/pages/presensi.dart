import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../widgets/glass_box.dart';
import '../../widgets/gradient_background.dart';
import '../../services/api_service.dart';
import '../../services/haversine_service.dart';

class PresensiPage extends StatefulWidget {
  final VoidCallback onHome;
  final bool isDarkMode;
  final Map<String, dynamic>? userData;

  PresensiPage({
    required this.onHome,
    required this.isDarkMode,
    this.userData,
  });

  @override
  State<PresensiPage> createState() => _PresensiPageState();
}

class _PresensiPageState extends State<PresensiPage> {
  final ApiService _apiService = ApiService();

  // Settings dari database
  double _centerLat = -6.200000;
  double _centerLon = 106.816666;
  double _maxRadiusMeters = 100;
  bool _presensiEnabled = true;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  // Status lokasi user
  Position? _currentPosition;
  double _jarakMeter = 0.0;
  bool _dalamArea = false;
  bool _dalamWaktu = false;

  // Loading state
  bool _isLoadingSettings = true;
  bool _isLoadingLocation = false;

  String _statusMessage = 'Memuat pengaturan...';

  @override
  void initState() {
    super.initState();
    _loadSettingsAndLocation();
  }

  Future<void> _loadSettingsAndLocation() async {
    setState(() => _isLoadingSettings = true);

    // 1. Ambil pengaturan dari database
    try {
      final settings = await _apiService.getSettings();
      if (settings != null) {
        final startParts = settings['start_time'].toString().split(':');
        final endParts = settings['end_time'].toString().split(':');
        setState(() {
          _centerLat =
              double.tryParse(settings['center_lat'].toString()) ?? _centerLat;
          _centerLon =
              double.tryParse(settings['center_lon'].toString()) ?? _centerLon;
          _maxRadiusMeters =
              double.tryParse(settings['max_radius'].toString()) ??
                  _maxRadiusMeters;
          _presensiEnabled =
              settings['is_enabled'] == 1 || settings['is_enabled'] == true;
          _startTime = TimeOfDay(
            hour: int.parse(startParts[0]),
            minute: int.parse(startParts[1]),
          );
          _endTime = TimeOfDay(
            hour: int.parse(endParts[0]),
            minute: int.parse(endParts[1]),
          );
        });
      }
    } catch (e) {
      print('Gagal memuat settings: $e');
    }

    // 2. Ambil lokasi user saat ini
    await _getCurrentLocation();
    setState(() => _isLoadingSettings = false);
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _statusMessage = 'Mengambil lokasi Anda...';
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLoadingLocation = false;
        _statusMessage = 'GPS tidak aktif. Aktifkan lokasi di HP Anda.';
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _isLoadingLocation = false;
          _statusMessage = 'Izin lokasi ditolak.';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isLoadingLocation = false;
        _statusMessage =
            'Izin lokasi ditolak permanen. Aktifkan di pengaturan HP.';
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Hitung jarak menggunakan Haversine (dalam km, lalu konversi ke meter)
      double jarakKm = Haversine.calculateDistance(
        _centerLat,
        _centerLon,
        position.latitude,
        position.longitude,
      );
      double jarakMeter = jarakKm * 1000;

      // Validasi waktu saat ini
      final now = TimeOfDay.now();
      bool dalamWaktu = false;
      if (_startTime != null && _endTime != null) {
        final nowMinutes = now.hour * 60 + now.minute;
        final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
        final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
        dalamWaktu = nowMinutes >= startMinutes && nowMinutes <= endMinutes;
      }

      setState(() {
        _currentPosition = position;
        _jarakMeter = jarakMeter;
        _dalamArea = jarakMeter <= _maxRadiusMeters;
        _dalamWaktu = dalamWaktu;
        _isLoadingLocation = false;
        _statusMessage = '';
      });
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
        _statusMessage = 'Gagal mendapatkan lokasi: $e';
      });
    }
  }

  Future<void> _absen() async {
    if (widget.userData == null || widget.userData!['id'] == null) {
      _showSnackbar('Data user tidak valid. Silakan login ulang.', Colors.red);
      return;
    }

    if (!_presensiEnabled) {
      _showSnackbar('Presensi sedang dinonaktifkan oleh admin.', Colors.red);
      return;
    }
    if (!_dalamWaktu) {
      final start = _startTime?.format(context) ?? '-';
      final end = _endTime?.format(context) ?? '-';
      _showSnackbar('Di luar jam presensi ($start – $end).', Colors.orange);
      return;
    }
    if (!_dalamArea) {
      _showSnackbar(
          'Anda di luar radius presensi (${_maxRadiusMeters.toInt()} meter).',
          Colors.red);
      return;
    }

    if (_currentPosition == null) {
      _showSnackbar('Lokasi belum ditemukan.', Colors.red);
      return;
    }

    // Tampilkan loading (opsional, bisa pakai overlay/dialog, di sini pakai state jika perlu)
    // Untuk simpelnya, kita langsung call API:
    final int userId = widget.userData!['id'];
    final double lat = _currentPosition!.latitude;
    final double lon = _currentPosition!.longitude;

    try {
      final success = await _apiService.clockIn(userId, lat, lon);
      if (success) {
        _showSnackbar(
            'Presensi berhasil! ${DateTime.now().toString().substring(0, 16)}',
            Colors.green);
      } else {
        _showSnackbar('Gagal melakukan presensi. Coba lagi.', Colors.red);
      }
    } catch (e) {
      _showSnackbar('Terjadi kesalahan koneksi.', Colors.red);
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canAbsen =
        _presensiEnabled && _dalamArea && _dalamWaktu && !_isLoadingLocation;
    final String startStr = _startTime?.format(context) ?? '-';
    final String endStr = _endTime?.format(context) ?? '-';

    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = widget.isDarkMode ? Colors.white70 : Colors.black54;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor),
          onPressed: widget.onHome,
        ),
        title: Text(
          "Presensi",
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: textColor),
            onPressed: _loadSettingsAndLocation,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: GradientBackground(
        isDarkMode: widget.isDarkMode,
        child: _isLoadingSettings
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: textColor),
                    SizedBox(height: 16),
                    Text('Memuat pengaturan presensi...',
                        style: TextStyle(color: textColor)),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24, 20, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Status Presensi Dinonaktifkan ────────────────
                    if (!_presensiEnabled)
                      Container(
                        padding: EdgeInsets.all(16),
                        margin: EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: Colors.red.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.block, color: Colors.red),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Presensi saat ini dinonaktifkan oleh Admin.',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // ── Card Utama Lokasi (Glassmorphism) ────────────────────────────
                    GlassBox(
                      isDarkMode: widget.isDarkMode,
                      padding: EdgeInsets.all(24),
                      borderRadius: 24,
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _dalamArea
                                  ? Colors.green.withOpacity(0.15)
                                  : Colors.red.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _dalamArea
                                  ? Icons.location_on_rounded
                                  : Icons.location_off_rounded,
                              size: 48,
                              color: _dalamArea ? Colors.green : Colors.red,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Status Lokasi',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor),
                          ),
                          SizedBox(height: 20),

                          // Kotak status jarak
                          _isLoadingLocation
                              ? Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(),
                                )
                              : _currentPosition == null
                                  ? Text(
                                      _statusMessage,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.red),
                                    )
                                  : Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: widget.isDarkMode
                                            ? Colors.black.withOpacity(0.2)
                                            : Colors.white.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            '${_jarakMeter.toStringAsFixed(1)} m',
                                            style: TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.w900,
                                                color: textColor),
                                          ),
                                          Text(
                                            'dari pusat presensi',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: subTextColor),
                                          ),
                                          SizedBox(height: 12),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                _dalamArea
                                                    ? Icons.check_circle_rounded
                                                    : Icons.cancel_rounded,
                                                color: _dalamArea
                                                    ? Colors.green
                                                    : Colors.red,
                                                size: 20,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                _dalamArea
                                                    ? 'Dalam radius ${_maxRadiusMeters.toInt()} m'
                                                    : 'Di luar radius ${_maxRadiusMeters.toInt()} m',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: _dalamArea
                                                      ? Colors.green
                                                      : Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // ── Card Waktu (Glassmorphism) ───────────────────────────────────
                    GlassBox(
                      isDarkMode: widget.isDarkMode,
                      padding: EdgeInsets.all(20),
                      borderRadius: 20,
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _dalamWaktu
                                  ? Colors.blue.withOpacity(0.15)
                                  : Colors.orange.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.schedule_rounded,
                              size: 32,
                              color: _dalamWaktu ? Colors.blue : Colors.orange,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Waktu Presensi',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: subTextColor,
                                      fontSize: 14),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '$startStr – $endStr',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: textColor),
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      _dalamWaktu
                                          ? Icons.check_circle_rounded
                                          : Icons.warning_rounded,
                                      size: 14,
                                      color: _dalamWaktu
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      _dalamWaktu
                                          ? 'Sesuai jadwal'
                                          : 'Di luar jadwal',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: _dalamWaktu
                                            ? Colors.green
                                            : Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 40),

                    // ── Tombol Absen ─────────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: canAbsen
                            ? LinearGradient(
                                colors: [Color(0xFF10B981), Color(0xFF059669)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: canAbsen
                            ? null
                            : (widget.isDarkMode
                                ? Colors.grey.shade800
                                : Colors.grey.shade300),
                        boxShadow: canAbsen
                            ? [
                                BoxShadow(
                                  color: Color(0xFF10B981).withOpacity(0.4),
                                  blurRadius: 16,
                                  offset: Offset(0, 8),
                                )
                              ]
                            : null,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: canAbsen ? _absen : null,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.fingerprint_rounded,
                                    size: 28,
                                    color: canAbsen
                                        ? Colors.white
                                        : (widget.isDarkMode
                                            ? Colors.white54
                                            : Colors.black38)),
                                SizedBox(width: 12),
                                Text(
                                  canAbsen
                                      ? 'Absen Sekarang'
                                      : (!_presensiEnabled
                                          ? 'Presensi Nonaktif'
                                          : !_dalamWaktu
                                              ? 'Di Luar Jam'
                                              : 'Di Luar Area'),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: canAbsen
                                        ? Colors.white
                                        : (widget.isDarkMode
                                            ? Colors.white54
                                            : Colors.black38),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Tombol refresh lokasi
                    Center(
                      child: TextButton.icon(
                        onPressed:
                            _isLoadingLocation ? null : _getCurrentLocation,
                        icon: Icon(Icons.my_location_rounded,
                            color: subTextColor, size: 18),
                        label: Text('Perbarui Lokasi',
                            style: TextStyle(
                                color: subTextColor,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
