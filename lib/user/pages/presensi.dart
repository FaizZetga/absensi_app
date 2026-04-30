import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/haversine_service.dart';

class PresensiPage extends StatefulWidget {
  final VoidCallback onHome;
  final bool isDarkMode;

  PresensiPage({required this.onHome, required this.isDarkMode});

  @override
  State<PresensiPage> createState() => _PresensiPageState();
}

class _PresensiPageState extends State<PresensiPage> {
  double _centerLat = -6.200000;
  double _centerLon = 106.816666;
  bool _useLaptopAsCenter = false;

  Position? _currentPosition;
  double _jarak = 0.0;
  bool _dalamArea = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Layanan lokasi tidak aktif')),
      );
      setState(() => _isLoading = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Izin lokasi ditolak')),
        );
        setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Izin lokasi ditolak permanen')),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
        final centerLat = _centerLat;
        final centerLon = _centerLon;
        _jarak = Haversine.calculateDistance(
          centerLat,
          centerLon,
          position.latitude,
          position.longitude,
        );
        _dalamArea = _jarak < 0.05; // 50 meter radius
        _isLoading = false;
      });
      print('Lokasi user: ${position.latitude}, ${position.longitude}');
      print('Koordinat pusat presensi: ${_centerLat.toStringAsFixed(6)}, ${_centerLon.toStringAsFixed(6)}');
      print('Jarak ke pusat: $_jarak km');
      print('Dalam area: $_dalamArea');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mendapatkan lokasi: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  void _setLaptopAsCenter() {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lokasi belum tersedia, tekan refresh terlebih dahulu')),
      );
      return;
    }

    setState(() {
      _centerLat = _currentPosition!.latitude;
      _centerLon = _currentPosition!.longitude;
      _useLaptopAsCenter = true;
      _jarak = 0.0;
      _dalamArea = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pusat presensi diatur ke lokasi laptop saat ini')),
    );
  }

  void _absen() {
    if (_dalamArea) {
      // Simpan presensi (untuk demo, hanya snackbar)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Presensi Berhasil pada ${DateTime.now().toString()}"),
          backgroundColor: Colors.green,
        ),
      );
      // Di sini bisa tambah logika simpan ke database
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: widget.onHome,
        ),
        title: Text("Presensi"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _getCurrentLocation,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.isDarkMode
                ? [Colors.grey.shade900, Colors.grey.shade800]
                : [
                    Color(0xFF10B981),
                    Color(0xFF059669),
                    Color(0xFF06B6D4),
                    Color(0xFF0891B2),
                  ],
            stops: widget.isDarkMode ? null : [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 64,
                              color: Colors.blue.shade700,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Lokasi Anda',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _dalamArea ? Colors.green.shade100 : Colors.red.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "Jarak: ${_jarak.toStringAsFixed(3)} km",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _dalamArea ? Icons.check_circle : Icons.cancel,
                                        color: _dalamArea ? Colors.green : Colors.red,
                                        size: 24,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        _dalamArea ? "Dalam Area (50m) ✅" : "Di Luar Area ❌",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: _dalamArea ? Colors.green.shade700 : Colors.red.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Pusat Presensi: ${_centerLat.toStringAsFixed(6)}, ${_centerLon.toStringAsFixed(6)}',
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                            ),
                            SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _setLaptopAsCenter,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  "Set Lokasi Laptop Sebagai Pusat",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _dalamArea ? _absen : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _dalamArea ? Colors.green : Colors.grey,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  "Absen Sekarang",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}