import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Gunakan 10.0.2.2 jika pakai emulator Android, atau localhost jika pakai Chrome/Windows
  static const String baseUrl = 'http://10.208.70.210:5000/api';

  // Build URI safely: trim baseUrl to avoid accidental trailing spaces
  Uri _buildUri(String path) {
    final base = baseUrl.trim();
    return Uri.parse('$base$path');
  }

  // Ambil data users
  Future<List<dynamic>> getUsers() async {
    try {
      final response = await http.get(_buildUri('/users'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print('Error GetUsers: $e');
      return [];
    }
  }

  // Ambil data departemen
  Future<List<dynamic>> getDepartments() async {
    try {
      final response = await http.get(_buildUri('/departments'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      print('Error GetDepartments: $e');
      return [];
    }
  }

  // Ambil data jabatan
  Future<List<dynamic>> getPositions() async {
    try {
      final response = await http.get(_buildUri('/positions'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      print('Error GetPositions: $e');
      return [];
    }
  }

  // Fungsi Login
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        _buildUri('/login'), // Kita perlu buat endpoint ini di backend
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print('Error Login: $e');
      return null;
    }
  }

  // Fungsi Clock In (Presensi Masuk)
  Future<bool> clockIn(int userId, double lat, double long) async {
    try {
      final response = await http.post(
        _buildUri('/attendance/clock-in'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'latitude': lat,
          'longitude': long,
        }),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Error ClockIn: $e');
      return false;
    }
  }

  // Fungsi Tambah User Baru
  Future<Map<String, dynamic>> addUser(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        _buildUri('/users'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'message': 'User berhasil ditambahkan'};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal menambahkan user'
        };
      }
    } catch (e) {
      print('Error AddUser: $e');
      return {'success': false, 'message': 'Terjadi kesalahan koneksi'};
    }
  }

  // Fungsi Update User
  Future<Map<String, dynamic>> updateUser(
      int id, Map<String, dynamic> userData) async {
    try {
      final response = await http.put(
        _buildUri('/users/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'User berhasil diperbarui'};
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal memperbarui user'
        };
      }
    } catch (e) {
      print('Error UpdateUser: $e');
      return {'success': false, 'message': 'Terjadi kesalahan koneksi'};
    }
  }

  // Fungsi Hapus User
  Future<bool> deleteUser(int id) async {
    try {
      final response = await http.delete(_buildUri('/users/$id'));
      return response.statusCode == 200;
    } catch (e) {
      print('Error DeleteUser: $e');
      return false;
    }
  }

  // Ambil riwayat absensi semua user
  Future<List<dynamic>> getAttendance() async {
    try {
      final response = await http.get(_buildUri('/attendance'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load attendance');
      }
    } catch (e) {
      print('Error GetAttendance: $e');
      return [];
    }
  }

  // Ambil jumlah presensi hari ini (untuk dashboard admin)
  Future<int> getTodayAttendanceCount() async {
    try {
      final response = await http.get(_buildUri('/attendance/today'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['count'] ?? 0) as int;
      }
      return 0;
    } catch (e) {
      print('Error GetTodayAttendance: $e');
      return 0;
    }
  }

  // Ambil riwayat absensi per user
  Future<List<dynamic>> getUserAttendance(int userId) async {
    try {
      final response = await http.get(_buildUri('/attendance/$userId'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load user attendance');
      }
    } catch (e) {
      print('Error GetUserAttendance: $e');
      return [];
    }
  }

  // Ambil pengaturan presensi
  Future<Map<String, dynamic>?> getSettings() async {
    try {
      final response = await http.get(_buildUri('/settings'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error GetSettings: $e');
      return null;
    }
  }

  // Update pengaturan presensi
  Future<bool> updateSettings(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        _buildUri('/settings'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error UpdateSettings: $e');
      return false;
    }
  }
}
