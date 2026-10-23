# Perencanaan Sistem Penjualan Barang

## A. Proses dan Perencanaan

### 1. Persiapan Alat dan Bahan
- Perangkat keras: laptop/PC, keyboard, mouse.
- Perangkat lunak: Flutter SDK, Dart SDK, editor VS Code/Android Studio, emulator atau Windows desktop runner.
- Database lokal: SQLite melalui `sqflite_common_ffi`.
- Referensi: dokumentasi Flutter, dokumentasi SQLite, dan rubrik penilaian tugas.

### 2. Analisis Kebutuhan
Fitur utama yang dibutuhkan:
- Manajemen barang: tambah, lihat, ubah, hapus data barang.
- Transaksi pembelian: input supplier, pilih barang, jumlah, harga beli, lalu stok bertambah.
- Transaksi penjualan: input pelanggan, pilih barang, jumlah, harga jual, total otomatis, lalu stok berkurang.
- Laporan laba rugi: menampilkan total penjualan, total pembelian, HPP, dan laba kotor.

Entitas data yang digunakan:
- `barang`
- `pembelian`
- `detail_pembelian`
- `penjualan`
- `detail_penjualan`

### 3. Desain Sistem

#### ERD Sederhana
```text
barang (1) --------< detail_pembelian >-------- (1) pembelian
barang (1) --------< detail_penjualan >-------- (1) penjualan

barang
- id (PK)
- nama
- kategori
- harga_beli
- harga_jual
- stok
- created_at

pembelian
- id (PK)
- tanggal
- supplier
- total

detail_pembelian
- id (PK)
- pembelian_id (FK)
- barang_id (FK)
- jumlah
- harga_beli
- subtotal

penjualan
- id (PK)
- tanggal
- pelanggan
- total

detail_penjualan
- id (PK)
- penjualan_id (FK)
- barang_id (FK)
- jumlah
- harga_beli
- harga_jual
- subtotal
- laba
```

#### Wireframe Ringkas
```text
Dashboard
+-------------------------------------------+
| Ringkasan Usaha                           |
| [Jumlah Barang] [Total Stok]              |
| [Total Penjualan] [Estimasi Laba]         |
| Laporan Periode Aktif                     |
+-------------------------------------------+

Menu Barang
+-------------------------------------------+
| Manajemen Barang      [Tambah]            |
| - Nama barang                             |
| - Kategori                                |
| - Harga beli / jual / stok                |
| - Tombol edit dan hapus                   |
+-------------------------------------------+

Menu Pembelian/Penjualan
+-------------------------------------------+
| Form transaksi                            |
| Nama supplier / pelanggan                 |
| Pilih barang                              |
| Jumlah dan harga                          |
| Tambah detail                             |
| Total transaksi                           |
+-------------------------------------------+
```

#### Alur Kerja Sistem
1. Admin menambah data barang.
2. Saat pembelian dicatat, stok barang bertambah.
3. Saat penjualan dicatat, sistem memvalidasi stok lalu menguranginya.
4. Sistem menghitung total transaksi otomatis dari detail.
5. Laporan laba rugi dihitung dari `Total Penjualan - HPP`, dengan HPP berdasarkan harga beli pada detail penjualan.

## B. Implementasi Teknis

### Struktur Database
- Database lokal SQLite dengan relasi master-detail.
- Tabel detail digunakan agar satu transaksi dapat memiliki banyak barang.

### Logika Bisnis
- Pembelian memperbarui stok dengan operasi tambah.
- Penjualan memperbarui stok dengan operasi kurang.
- Penjualan gagal jika stok tidak mencukupi.
- Laporan menghitung laba kotor berdasarkan transaksi penjualan yang tersimpan.
