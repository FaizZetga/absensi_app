import 'package:flutter/material.dart';

class DaftarUserPage extends StatefulWidget {
  final VoidCallback onHome;
  final bool isDarkMode;

  DaftarUserPage({required this.onHome, required this.isDarkMode});

  @override
  State<DaftarUserPage> createState() => _DaftarUserPageState();
}

class _DaftarUserPageState extends State<DaftarUserPage> {
  final List<Map<String, dynamic>> userList = [
    {
      'id': 1,
      'nama': 'Andi Wijaya',
      'email': 'andi@email.com',
      'phone': '+62 812-3456-7890',
      'department': 'IT Department',
      'username': 'andi.wijaya',
      'status': 'Aktif',
    },
    {
      'id': 2,
      'nama': 'Budi Santoso',
      'email': 'budi@email.com',
      'phone': '+62 812-3456-7891',
      'department': 'HR Department',
      'username': 'budi.santoso',
      'status': 'Aktif',
    },
    {
      'id': 3,
      'nama': 'Citra Dewi',
      'email': 'citra@email.com',
      'phone': '+62 812-3456-7892',
      'department': 'Finance Department',
      'username': 'citra.dewi',
      'status': 'Aktif',
    },
    {
      'id': 4,
      'nama': 'Doni Hermawan',
      'email': 'doni@email.com',
      'phone': '+62 812-3456-7893',
      'department': 'Operations',
      'username': 'doni.hermawan',
      'status': 'Inaktif',
    },
    {
      'id': 5,
      'nama': 'Eka Putri',
      'email': 'eka@email.com',
      'phone': '+62 812-3456-7894',
      'department': 'Marketing',
      'username': 'eka.putri',
      'status': 'Aktif',
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
        title: Text("Daftar User"),
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
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: userList.length,
          itemBuilder: (context, index) {
            final user = userList[index];
            return Card(
              elevation: 4,
              margin: EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user['nama'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                user['department'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: user['status'] == 'Aktif'
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            user['status'],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: user['status'] == 'Aktif'
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Divider(),
                    SizedBox(height: 12),
                    _buildInfoRow(
                      icon: Icons.email,
                      label: 'Email',
                      value: user['email'],
                    ),
                    SizedBox(height: 8),
                    _buildInfoRow(
                      icon: Icons.phone,
                      label: 'Telepon',
                      value: user['phone'],
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _editUser(user),
                          icon: Icon(Icons.edit),
                          label: Text('Edit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _deleteUser(user['id']),
                          icon: Icon(Icons.delete),
                          label: Text('Hapus'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
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

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey.shade600,
        ),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _editUser(Map<String, dynamic> user) {
    final namaController = TextEditingController(text: user['nama']);
    final emailController = TextEditingController(text: user['email']);
    final phoneController = TextEditingController(text: user['phone']);
    final departmentController = TextEditingController(text: user['department']);
    final usernameController = TextEditingController(text: user['username']);
    String selectedStatus = user['status'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: namaController,
                  decoration: InputDecoration(
                    labelText: 'Nama',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Telepon',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: departmentController,
                  decoration: InputDecoration(
                    labelText: 'Departemen',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: [
                    DropdownMenuItem(value: 'Aktif', child: Text('Aktif')),
                    DropdownMenuItem(value: 'Inaktif', child: Text('Inaktif')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        selectedStatus = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  final index = userList.indexWhere((u) => u['id'] == user['id']);
                  if (index != -1) {
                    userList[index] = {
                      'id': user['id'],
                      'nama': namaController.text,
                      'email': emailController.text,
                      'phone': phoneController.text,
                      'department': departmentController.text,
                      'username': usernameController.text,
                      'status': selectedStatus,
                    };
                  }
                });
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('User berhasil diperbarui')),
                );
              },
              child: Text(
                'Simpan',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteUser(int userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus user ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                userList.removeWhere((u) => u['id'] == userId);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('User berhasil dihapus')),
              );
            },
            child: Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
