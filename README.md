# Panduan Menjalankan Aplikasi Absensi

Proyek ini terdiri dari dua bagian utama:
1. **Server (Backend)** - Menggunakan Node.js, Express, dan MySQL.
2. **Client (Mobile App)** - Menggunakan Flutter.

---

## 🛠️ 1. Persiapan & Menjalankan Server (Backend)

Ikuti langkah-langkah berikut untuk setup database dan menjalankan server:

### Langkah A: Konfigurasi Environment (`.env`)
1. Buka file [server/.env](file:///D:/Paiz/absensi_app/server/.env).
2. Sesuaikan konfigurasi database dengan MySQL di komputer Anda:
   * **Host**: `DB_HOST=localhost`
   * **User**: `DB_USER=root`
   * **Password**: Isi dengan password MySQL Anda. Jika menggunakan **XAMPP** atau **Laragon** (default tanpa password), silakan dikosongkan:
     ```env
     DB_PASSWORD=
     ```
3. Tekan **`Ctrl + S`** untuk menyimpan file `.env`.

### Langkah B: Instalasi dan Migrasi Database
1. Buka terminal baru dan masuk ke direktori server:
   ```bash
   cd server
   ```
2. Instal semua dependensi Node.js:
   ```bash
   npm install
   ```
3. Jalankan migrasi untuk membuat database `absensi_app` dan tabel-tabel di dalamnya secara otomatis:
   ```bash
   npm run migrate
   ```
4. Jalankan server backend:
   ```bash
   npm start
   ```
   *Backend Anda sekarang berjalan (biasanya di port `5000`).*

---

## 📱 2. Menjalankan Client (Flutter)

Ikuti langkah-langkah berikut untuk menjalankan aplikasi mobile:

1. Buka terminal baru (buka tab terminal terpisah) dan masuk ke direktori client:
   ```bash
   cd client
   ```
2. Unduh paket/dependensi Flutter yang dibutuhkan:
   ```bash
   flutter pub get
   ```
3. Jalankan aplikasi Flutter:
   ```bash
   flutter run
   ```
   *Pilih perangkat emulator atau real device Anda untuk mulai debugging.*
