import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  final VoidCallback onHome;
  final bool isDarkMode;

  HistoryPage({required this.onHome, required this.isDarkMode});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final List<Map<String, dynamic>> historyData = [
    {
      'date': '2024-03-26',
      'status': 'Hadir',
      'time': '08:30',
      'location': 'Kantor Pusat',
    },
    {
      'date': '2024-03-25',
      'status': 'Izin',
      'time': '-',
      'location': '-',
    },
    {
      'date': '2024-03-24',
      'status': 'Hadir',
      'time': '08:15',
      'location': 'Kantor Pusat',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: widget.onHome,
        ),
        title: Text("Riwayat Presensi"),
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
                    Color(0xFF10B981),
                    Color(0xFF059669),
                    Color(0xFF06B6D4),
                    Color(0xFF0891B2),
                  ],
            stops: widget.isDarkMode ? null : [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: historyData.length,
          itemBuilder: (context, index) {
            final item = historyData[index];
            return Card(
              elevation: 4,
              margin: EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: item['status'] == 'Hadir' ? Colors.green : Colors.orange,
                  child: Icon(
                    item['status'] == 'Hadir' ? Icons.check : Icons.warning,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  item['date'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status: ${item['status']}'),
                    Text('Waktu: ${item['time']}'),
                    Text('Lokasi: ${item['location']}'),
                  ],
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
              ),
            );
          },
        ),
      ),
    );
  }
}