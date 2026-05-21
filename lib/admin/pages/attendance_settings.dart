import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/api_service.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/glass_box.dart';

class AttendanceSettings extends StatefulWidget {
  final VoidCallback onHome;
  final bool isDarkMode;

  AttendanceSettings({required this.onHome, required this.isDarkMode});

  @override
  State<AttendanceSettings> createState() => _AttendanceSettingsState();
}

class _AttendanceSettingsState extends State<AttendanceSettings> {
  final ApiService _apiService = ApiService();

  // Pengaturan waktu presensi
  TimeOfDay startTime = TimeOfDay(hour: 8, minute: 0);
  TimeOfDay endTime = TimeOfDay(hour: 17, minute: 0);

  // Pengaturan lokasi presensi
  double centerLatitude = -6.2088;
  double centerLongitude = 106.8456;
  double maxRadiusMeters = 100;

  // Status presensi
  bool isAttendanceEnabled = true;

  // Loading state
  bool isLoadingLocation = false;
  bool isLoadingData = true;
  bool isSaving = false;

  // Controllers for text fields
  final TextEditingController _radiusController = TextEditingController();
  final TextEditingController _workDaysController = TextEditingController(text: "Senin - Jumat");
  final TextEditingController _workHoursController = TextEditingController(text: "08:00 - 17:00");

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _radiusController.dispose();
    _workDaysController.dispose();
    _workHoursController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => isLoadingData = true);
    try {
      final data = await _apiService.getSettings();
      if (data != null) {
        // Parse start time (format: "08:00:00")
        final startParts = data['start_time'].toString().split(':');
        final endParts = data['end_time'].toString().split(':');
        setState(() {
          startTime = TimeOfDay(
            hour: int.parse(startParts[0]),
            minute: int.parse(startParts[1]),
          );
          endTime = TimeOfDay(
            hour: int.parse(endParts[0]),
            minute: int.parse(endParts[1]),
          );
          centerLatitude = double.tryParse(data['center_lat'].toString()) ?? centerLatitude;
          centerLongitude = double.tryParse(data['center_lon'].toString()) ?? centerLongitude;
          maxRadiusMeters = double.tryParse(data['max_radius'].toString()) ?? maxRadiusMeters;
          isAttendanceEnabled = data['is_enabled'] == 1 || data['is_enabled'] == true;
          _radiusController.text = maxRadiusMeters.toInt().toString();
          if (data['work_days'] != null) {
            _workDaysController.text = data['work_days'].toString();
          }
          if (data['work_hours'] != null) {
            _workHoursController.text = data['work_hours'].toString();
          }
        });
      }
    } catch (e) {
      _showSnackbar('Gagal memuat pengaturan: $e', Colors.red);
    } finally {
      setState(() => isLoadingData = false);
    }
  }

  Future<void> _saveSettings() async {
    setState(() => isSaving = true);
    final String startStr =
        "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}:00";
    final String endStr =
        "${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}:00";

    final bool success = await _apiService.updateSettings({
      'start_time': startStr,
      'end_time': endStr,
      'center_lat': centerLatitude,
      'center_lon': centerLongitude,
      'max_radius': maxRadiusMeters.toInt(),
      'is_enabled': isAttendanceEnabled,
      'work_days': _workDaysController.text.trim(),
      'work_hours': _workHoursController.text.trim(),
    });
    setState(() => isSaving = false);

    if (success) {
      _showSnackbar('Pengaturan presensi berhasil disimpan!', Colors.green);
    } else {
      _showSnackbar('Gagal menyimpan pengaturan!', Colors.red);
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => isLoadingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackbar('Layanan lokasi tidak aktif. Aktifkan GPS!', Colors.red);
        setState(() => isLoadingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackbar('Izin lokasi ditolak', Colors.red);
          setState(() => isLoadingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackbar(
            'Izin lokasi ditolak permanen. Aktifkan di pengaturan HP.', Colors.red);
        setState(() => isLoadingLocation = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        centerLatitude = position.latitude;
        centerLongitude = position.longitude;
        isLoadingLocation = false;
      });

      _showSnackbar(
          'Titik pusat diperbarui: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
          Colors.green);
    } catch (e) {
      setState(() => isLoadingLocation = false);
      _showSnackbar('Gagal mendapatkan lokasi: $e', Colors.red);
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final picked = await showTimePicker(context: context, initialTime: startTime);
    if (picked != null) setState(() => startTime = picked);
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final picked = await showTimePicker(context: context, initialTime: endTime);
    if (picked != null) setState(() => endTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = widget.isDarkMode ? Colors.white70 : Colors.black54;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.home_rounded, color: textColor),
          onPressed: widget.onHome,
        ),
        title: Text(
          "Pengaturan Presensi",
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: textColor),
            onPressed: _loadSettings,
          ),
        ],
      ),
      body: GradientBackground(
        isDarkMode: widget.isDarkMode,
        child: isLoadingData
            ? Center(
                child: CircularProgressIndicator(
                  color: widget.isDarkMode ? Colors.white : Color(0xFF6366F1),
                ),
              )
            : Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 800),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 90),
                        // ── Status Presensi ───────────────────────────────
                        _buildCard(
                          icon: Icons.power_settings_new,
                          iconColor: Colors.blue.shade700,
                          title: 'Status Presensi',
                          child: SwitchListTile(
                            title: Text('Aktifkan Presensi',
                                style: TextStyle(fontWeight: FontWeight.w500)),
                            subtitle: Text('Izinkan user melakukan presensi',
                                style: TextStyle(color: Colors.grey.shade600)),
                            value: isAttendanceEnabled,
                            onChanged: (val) =>
                                setState(() => isAttendanceEnabled = val),
                            activeColor: Colors.green,
                          ),
                        ),
                        SizedBox(height: 16),

                        // ── Waktu Presensi ───────────────────────────────
                        _buildCard(
                          icon: Icons.access_time,
                          iconColor: Colors.green.shade700,
                          title: 'Waktu Presensi',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTimeSelector(
                                label: 'Jam Mulai Presensi',
                                time: startTime,
                                onTap: () => _selectStartTime(context),
                              ),
                              SizedBox(height: 16),
                              _buildTimeSelector(
                                label: 'Jam Akhir Presensi',
                                time: endTime,
                                onTap: () => _selectEndTime(context),
                              ),
                              SizedBox(height: 12),
                              Text('Hari Kerja',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700)),
                              SizedBox(height: 8),
                              TextField(
                                controller: _workDaysController,
                                decoration: InputDecoration(
                                  hintText: 'Misal: Senin - Jumat',
                                  prefixIcon: Icon(Icons.calendar_today, color: Colors.blue.shade600),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text('Jam Kerja',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700)),
                              SizedBox(height: 8),
                              TextField(
                                controller: _workHoursController,
                                decoration: InputDecoration(
                                  hintText: 'Misal: 08:00 - 17:00',
                                  prefixIcon: Icon(Icons.schedule, color: Colors.blue.shade600),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                              ),
                              SizedBox(height: 12),
                              _buildInfoBox(
                                'User hanya dapat presensi antara ${startTime.format(context)} – ${endTime.format(context)}.',
                                false,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),

                        // ── Lokasi & Radius Presensi ───────────────────
                        _buildCard(
                          icon: Icons.location_on,
                          iconColor: Colors.red.shade700,
                          title: 'Lokasi & Radius Presensi',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Koordinat titik pusat (read-only)
                              Text('Titik Pusat Presensi',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700)),
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.gps_fixed, color: Colors.red.shade600, size: 20),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Lat: ${centerLatitude.toStringAsFixed(6)}',
                                            style: TextStyle(
                                                fontFamily: 'monospace',
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'Lon: ${centerLongitude.toStringAsFixed(6)}',
                                            style: TextStyle(
                                                fontFamily: 'monospace',
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 12),

                              // Tombol ambil lokasi saat ini
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: isLoadingLocation ? null : _getCurrentLocation,
                                  icon: isLoadingLocation
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation(Colors.white),
                                          ),
                                        )
                                      : Icon(Icons.my_location, size: 20),
                                  label: Text(isLoadingLocation
                                      ? 'Mengambil Lokasi...'
                                      : 'Jadikan Lokasi Saat Ini Sebagai Pusat'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade600,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              Divider(height: 1, color: Colors.grey.shade300),
                              SizedBox(height: 20),

                              // Radius / jarak maksimum
                              Text('Radius Maksimum',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700)),
                              SizedBox(height: 8),
                              TextField(
                                controller: _radiusController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: '100',
                                  suffixText: 'meter',
                                  prefixIcon: Icon(Icons.radar, color: Colors.red.shade500),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 14),
                                ),
                                onChanged: (val) {
                                  maxRadiusMeters =
                                      double.tryParse(val) ?? maxRadiusMeters;
                                },
                              ),
                              SizedBox(height: 12),
                              // Preview radius slider
                              Text(
                                'Geser untuk menyesuaikan radius: ${maxRadiusMeters.toInt()} m',
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey.shade600),
                              ),
                              Slider(
                                value: maxRadiusMeters.clamp(10.0, 1000.0),
                                min: 10,
                                max: 1000,
                                divisions: 99,
                                label: '${maxRadiusMeters.toInt()} m',
                                activeColor: Colors.red.shade500,
                                onChanged: (val) {
                                  setState(() {
                                    maxRadiusMeters = val;
                                    _radiusController.text = val.toInt().toString();
                                  });
                                },
                              ),
                              SizedBox(height: 4),
                              _buildInfoBox(
                                'User hanya dapat presensi jika berada dalam radius ${maxRadiusMeters.toInt()} meter dari titik pusat menggunakan algoritma Haversine.',
                                true,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24),

                        // ── Tombol Simpan ─────────────────────────────
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isSaving ? null : _saveSettings,
                            icon: isSaving
                                ? SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(Colors.white)),
                                  )
                                : Icon(Icons.save_rounded),
                            label: Text(isSaving ? 'Menyimpan...' : 'Simpan Pengaturan',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return GlassBox(
      isDarkMode: widget.isDarkMode,
      borderRadius: 20,
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: iconColor),
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: widget.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildTimeSelector({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = widget.isDarkMode ? Colors.white70 : Colors.grey.shade600;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: subTextColor,
            )),
        SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(
                color: widget.isDarkMode
                    ? Colors.white.withOpacity(0.2)
                    : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(12),
              color: widget.isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.shade50,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time.format(context),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6366F1),
                  ),
                ),
                Icon(Icons.schedule_rounded, color: Color(0xFF6366F1)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBox(String text, bool isRed) {
    final Color bgColor = isRed
        ? Color(0xFFEF4444).withOpacity(0.1)
        : Color(0xFF10B981).withOpacity(0.1);
    final Color borderColor = isRed
        ? Color(0xFFEF4444).withOpacity(0.3)
        : Color(0xFF10B981).withOpacity(0.3);
    final Color textColor = isRed ? Color(0xFFEF4444) : Color(0xFF10B981);
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_rounded, color: textColor, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
