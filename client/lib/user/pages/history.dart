import 'package:flutter/material.dart';
import '../../widgets/glass_box.dart';
import '../../widgets/gradient_background.dart';
import '../../services/api_service.dart';

class HistoryPage extends StatefulWidget {
  final VoidCallback onHome;
  final bool isDarkMode;
  final Map<String, dynamic>? userData;

  HistoryPage({
    required this.onHome,
    required this.isDarkMode,
    this.userData,
  });

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final ApiService _apiService = ApiService();
  List<dynamic> historyData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    if (widget.userData == null || widget.userData!['id'] == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    final int userId = widget.userData!['id'];

    try {
      final data = await _apiService.getUserAttendance(userId);
      setState(() {
        historyData = data;
        isLoading = false;
      });
    } catch (e) {
      print('Gagal memuat riwayat: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          "Riwayat Presensi",
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: textColor),
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: GradientBackground(
        isDarkMode: widget.isDarkMode,
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: textColor))
            : historyData.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_rounded, size: 64, color: subTextColor.withOpacity(0.5)),
                        SizedBox(height: 16),
                        Text(
                          'Anda belum memiliki riwayat presensi',
                          style: TextStyle(color: subTextColor, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 40),
                    itemCount: historyData.length,
                    itemBuilder: (context, index) {
                      final item = historyData[index];
                      
                      // Format tanggal
                      String dateStr = item['date'] ?? '-';
                      if (dateStr.length > 10) {
                        dateStr = dateStr.substring(0, 10);
                      }
                      
                      final timeStr = item['clock_in'] ?? '-';
                      final isGood = item['status'] == 'on_time';
                      final statusStr = isGood 
                          ? 'Tepat Waktu' 
                          : item['status'] == 'late' 
                              ? 'Terlambat' 
                              : item['status'] ?? '-';

                      return Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: GlassBox(
                          isDarkMode: widget.isDarkMode,
                          padding: EdgeInsets.all(16),
                          borderRadius: 20,
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isGood ? Colors.green.withOpacity(0.15) : Colors.orange.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isGood ? Icons.check_circle_rounded : Icons.warning_rounded,
                                  color: isGood ? Colors.green : Colors.orange,
                                  size: 28,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dateStr,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: textColor,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.schedule_rounded, size: 14, color: subTextColor),
                                        SizedBox(width: 4),
                                        Text(
                                          timeStr,
                                          style: TextStyle(color: subTextColor, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isGood ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: isGood ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3)),
                                ),
                                child: Text(
                                  statusStr,
                                  style: TextStyle(
                                    color: isGood ? Colors.green : Colors.orange,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}