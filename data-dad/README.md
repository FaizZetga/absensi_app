# DAD (Diagram Alir Data) — Sistem Informasi Absensi

Folder ini berisi **Diagram Alir Data (DAD)** atau *Data Flow Diagram (DFD)* dari Sistem Informasi Absensi, dalam 3 tingkatan detail.

---

## 📂 Isi Folder

| File | Level | Deskripsi |
|------|-------|-----------|
| `dad_level0.xml` | Level 0 (Context) | Gambaran sistem secara keseluruhan |
| `dad_level1.xml` | Level 1 | 4 proses utama + 5 data store |
| `dad_level2.xml` | Level 2 | Sub-proses detail tiap proses Level 1 |

---

## 🌐 Cara Membuka File

1. Buka browser → kunjungi **https://app.diagrams.net**
2. Klik **File → Open from → Device**
3. Pilih file `.xml` yang ingin dibuka

---

## 📊 Ringkasan Tiap Level

### Level 0 — Context Diagram
- Menampilkan sistem sebagai **1 proses utama**
- Entitas eksternal: **Karyawan** dan **Admin**
- Aliran data masuk/keluar dari sistem

### Level 1 — Proses Utama
| No | Proses | Fungsi |
|----|--------|--------|
| P1 | Autentikasi | Login untuk Karyawan & Admin |
| P2 | Presensi | Clock-in dengan validasi GPS + waktu |
| P3 | Manajemen User | CRUD data karyawan oleh Admin |
| P4 | Pengaturan Sistem | Atur lokasi, radius, dan jam presensi |

**Data Store:**
- `D1` DB Users — tabel `users`
- `D2` DB Attendances — tabel `attendances`
- `D3` DB Settings — tabel `settings`
- `D4` DB Departments — tabel `departments`
- `D5` DB Positions — tabel `positions`

### Level 2 — Sub-Proses Detail

#### Proses 1: Autentikasi
| Sub-Proses | Keterangan |
|------------|------------|
| 1.1 Terima Kredensial | Menerima input email & password |
| 1.2 Validasi Login | Query ke DB Users, cek cocok/tidak |
| 1.3 Kelola Session | Simpan session & role ke SharedPreferences |

#### Proses 2: Presensi
| Sub-Proses | Keterangan |
|------------|------------|
| 2.1 Cek Pengaturan | Baca settings (lokasi, waktu, radius, status) |
| 2.2 Validasi Lokasi & Waktu | Hitung jarak Haversine, cek jam kerja |
| 2.3 Simpan Presensi | INSERT ke DB Attendances jika valid |

#### Proses 3: Manajemen User
| Sub-Proses | Keterangan |
|------------|------------|
| 3.1 Tambah User Baru | INSERT user + baca dept & jabatan |
| 3.2 Lihat Daftar User | SELECT semua user JOIN departments |
| 3.3 Edit / Update User | UPDATE data user by ID |
| 3.4 Hapus User | DELETE user + cascade delete attendances |

#### Proses 4: Pengaturan Sistem
| Sub-Proses | Keterangan |
|------------|------------|
| 4.1 Tampilkan Pengaturan | Baca settings dari DB dan tampilkan |
| 4.2 Update Pengaturan | UPDATE settings (lat, lon, radius, jam, work_days) |

---

## 🗂️ Entitas Eksternal

| Entitas | Role | Interaksi |
|---------|------|-----------|
| **Karyawan** | Employee | Login, Clock-In, Lihat Riwayat |
| **Admin** | Administrator | Login, Kelola User, Atur Settings, Lihat Semua Laporan |

---

## 🔁 Simbol & Konvensi

| Warna Panah | Makna |
|-------------|-------|
| 🔵 Biru | Input dari Entitas ke Proses |
| 🟢 Hijau | Output dari Proses ke Entitas |
| 🟣 Ungu | Baca/Tulis ke/dari Data Store (DB) |
| 🟠 Jingga | Aliran antar sub-proses (internal) |
| 🔴 Merah (putus) | Aliran gagal / Cascade delete |
