import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/glass_box.dart';

class HistoryAllPage extends StatefulWidget {
  final VoidCallback onHome;
  final bool isDarkMode;

  HistoryAllPage({required this.onHome, required this.isDarkMode});

  @override
  State<HistoryAllPage> createState() => _HistoryAllPageState();
}

class _HistoryAllPageState extends State<HistoryAllPage> {
  final ApiService _apiService = ApiService();
  List<dynamic> allHistoryData = [];
  List<dynamic> filteredHistoryData = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => isLoading = true);
    try {
      final data = await _apiService.getAttendance();
      setState(() {
        allHistoryData = data;
        filteredHistoryData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _filterHistory(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredHistoryData = allHistoryData;
      } else {
        filteredHistoryData = allHistoryData.where((item) {
          final userName = (item['user_name'] ?? '').toString().toLowerCase();
          return userName.contains(query.toLowerCase());
        }).toList();
      }
    });
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
          "Riwayat Presensi",
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: textColor),
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: GradientBackground(
        isDarkMode: widget.isDarkMode,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1200),
            child: Column(
              children: [
                SizedBox(height: 100),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: GlassBox(
                    isDarkMode: widget.isDarkMode,
                    borderRadius: 16,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: TextField(
                      onChanged: _filterHistory,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Cari nama karyawan...',
                        hintStyle: TextStyle(color: subTextColor),
                        prefixIcon: Icon(Icons.search_rounded, color: subTextColor),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filteredHistoryData.length} Entri',
                        style: TextStyle(
                          color: subTextColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4),
                Expanded(
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: widget.isDarkMode ? Colors.white : Color(0xFF6366F1),
                          ),
                        )
                      : filteredHistoryData.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.inbox_rounded, size: 64, color: subTextColor),
                                  SizedBox(height: 16),
                                  Text(
                                    'Belum ada data presensi',
                                    style: TextStyle(color: subTextColor, fontSize: 16),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              itemCount: filteredHistoryData.length,
                              itemBuilder: (context, index) {
                                final item = filteredHistoryData[index];
                                final userName = item['user_name'] ?? 'Unknown';

                                String dateStr = item['date'] ?? '-';
                                if (dateStr.length > 10) dateStr = dateStr.substring(0, 10);

                                final timeStr = item['clock_in'] ?? '-';
                                final statusStr = item['status'] == 'on_time'
                                    ? 'Tepat Waktu'
                                    : item['status'] == 'late'
                                        ? 'Terlambat'
                                        : item['status'] ?? '-';

                                final bool isGood = item['status'] == 'on_time';
                                final statusColor = isGood ? Color(0xFF10B981) : Color(0xFFF59E0B);

                                return Padding(
                                  padding: EdgeInsets.only(bottom: 12),
                                  child: GlassBox(
                                    isDarkMode: widget.isDarkMode,
                                    borderRadius: 18,
                                    padding: EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: statusColor.withOpacity(0.15),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            isGood
                                                ? Icons.check_circle_rounded
                                                : Icons.warning_rounded,
                                            color: statusColor,
                                            size: 26,
                                          ),
                                        ),
                                        SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                userName,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15,
                                                  color: textColor,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(Icons.calendar_today_rounded,
                                                      size: 12, color: subTextColor),
                                                  SizedBox(width: 4),
                                                  Text(dateStr,
                                                      style: TextStyle(
                                                          fontSize: 12, color: subTextColor)),
                                                  SizedBox(width: 12),
                                                  Icon(Icons.schedule_rounded,
                                                      size: 12, color: subTextColor),
                                                  SizedBox(width: 4),
                                                  Text(timeStr,
                                                      style: TextStyle(
                                                          fontSize: 12, color: subTextColor)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding:
                                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: statusColor.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            statusStr,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: statusColor,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}