import 'package:flutter/material.dart';

class HistoryAllPage extends StatefulWidget {
  final VoidCallback onHome;
  final bool isDarkMode;

  HistoryAllPage({required this.onHome, required this.isDarkMode});

  @override
  State<HistoryAllPage> createState() => _HistoryAllPageState();
}

class _HistoryAllPageState extends State<HistoryAllPage> {
  final List<Map<String, dynamic>> allHistoryData = [
    {
      'user': 'User A',
      'date': '2024-03-26',
      'status': 'Hadir',
      'time': '08:30',
      'location': 'Kantor Pusat',
    },
    {
      'user': 'User B',
      'date': '2024-03-26',
      'status': 'Izin',
      'time': '-',
      'location': '-',
    },
    {
      'user': 'User C',
      'date': '2024-03-25',
      'status': 'Hadir',
      'time': '08:15',
      'location': 'Kantor Pusat',
    },
    {
      'user': 'User A',
      'date': '2024-03-25',
      'status': 'Hadir',
      'time': '08:45',
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
        title: Text("Riwayat Semua Presensi"),
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
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari user...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: allHistoryData.length,
                itemBuilder: (context, index) {
                  final item = allHistoryData[index];
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
                        '${item['user']} - ${item['date']}',
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
          ],
        ),
      ),
    );
  }
}  