import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class AttendanceSettings extends StatefulWidget {
  final VoidCallback onHome;
  final bool isDarkMode;

  AttendanceSettings({required this.onHome, required this.isDarkMode});

  @override
  State<AttendanceSettings> createState() => _AttendanceSettingsState();
}

class _AttendanceSettingsState extends State<AttendanceSettings> {
  // Pengaturan waktu presensi
  TimeOfDay startTime = TimeOfDay(hour: 8, minute: 0);
  TimeOfDay endTime = TimeOfDay(hour: 17, minute: 0);

  // Pengaturan lokasi presensi
  double centerLatitude = -6.2088;
  double centerLongitude = 106.8456;
  int maxDistanceMeters = 100; // Jarak maksimal dari titik pusat

  // Status presensi
  bool isAttendanceEnabled = true;

  // Loading state untuk get location
  bool isLoadingLocation = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: widget.onHome,
        ),
        title: Text("Pengaturan Presensi"),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.isDarkMode
                ? [Colors.grey.shade900, Colors.grey.shade800]
                : [
                    Color(0xFF667EEA),
                    Color(0xFF764BA2),
                    Color(0xFFF093FB),
                    Color(0xFFF5576C),
                  ],
            stops: widget.isDarkMode ? null : [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Presensi
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.power_settings_new,
                            size: 32,
                            color: Colors.blue.shade700,
                          ),
                          SizedBox(width: 16),
                          Text(
                            'Status Presensi',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      SwitchListTile(
                        title: Text(
                          'Aktifkan Presensi',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          'Izinkan user melakukan presensi',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        value: isAttendanceEnabled,
                        onChanged: (value) {
                          setState(() {
                            isAttendanceEnabled = value;
                          });
                        },
                        activeColor: Colors.green,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Pengaturan Waktu Presensi
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 32,
                            color: Colors.green.shade700,
                          ),
                          SizedBox(width: 16),
                          Text(
                            'Waktu Presensi',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Jam Mulai Presensi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectStartTime(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                startTime.format(context),
                                style: TextStyle(fontSize: 16),
                              ),
                              Icon(Icons.access_time, color: Colors.grey.shade600),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Jam Akhir Presensi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectEndTime(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                endTime.format(context),
                                style: TextStyle(fontSize: 16),
                              ),
                              Icon(Icons.access_time, color: Colors.grey.shade600),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Pengaturan Lokasi Presensi
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 32,
                            color: Colors.red.shade700,
                          ),
                          SizedBox(width: 16),
                          Text(
                            'Lokasi Presensi',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Titik Pusat Presensi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: 'Latitude',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              controller: TextEditingController(text: centerLatitude.toString()),
                              onChanged: (value) {
                                setState(() {
                                  centerLatitude = double.tryParse(value) ?? centerLatitude;
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: 'Longitude',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              controller: TextEditingController(text: centerLongitude.toString()),
                              onChanged: (value) {
                                setState(() {
                                  centerLongitude = double.tryParse(value) ?? centerLongitude;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
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
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Icon(Icons.my_location),
                          label: Text(isLoadingLocation ? "Mengambil Lokasi..." : "Ambil Lokasi Saat Ini"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Jarak Maksimal dari Titik Pusat',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '100',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixText: 'meter',
                        ),
                        controller: TextEditingController(text: maxDistanceMeters.toString()),
                        onChanged: (value) {
                          setState(() {
                            maxDistanceMeters = int.tryParse(value) ?? 100;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue.shade700),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'User hanya bisa melakukan presensi jika berada dalam radius ${maxDistanceMeters} meter dari titik pusat yang ditentukan.',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveSettings,
                  icon: Icon(Icons.save),
                  label: Text("Simpan Pengaturan"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: startTime,
    );
    if (picked != null && picked != startTime) {
      setState(() {
        startTime = picked;
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: endTime,
    );
    if (picked != null && picked != endTime) {
      setState(() {
        endTime = picked;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      isLoadingLocation = true;
    });

    try {
      // Cek permission lokasi
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Izin lokasi ditolak'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Izin lokasi ditolak secara permanen. Silakan aktifkan di pengaturan'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          isLoadingLocation = false;
        });
        return;
      }

      // Dapatkan posisi saat ini
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        centerLatitude = position.latitude;
        centerLongitude = position.longitude;
        isLoadingLocation = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lokasi berhasil diperbarui: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        isLoadingLocation = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mendapatkan lokasi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _saveSettings() {
    // Simpan pengaturan ke storage atau state management
    // Untuk sementara hanya tampilkan snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Pengaturan presensi berhasil disimpan!"),
        backgroundColor: Colors.green,
      ),
    );
  }
}
