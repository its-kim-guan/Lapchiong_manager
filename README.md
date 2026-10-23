# Chinese Lapchiong Manager

Aplikasi Flutter untuk mengelola katalog barang, stok, pembelian, penjualan,
dan laporan laba kotor. Data disimpan secara lokal menggunakan SQLite.

## Fitur

- Login demo Admin dan Kasir dengan menu sesuai peran.
- Tambah, ubah, cari, filter, dan hapus barang.
- Catat pembelian beberapa barang dalam satu transaksi.
- Catat penjualan dengan pemeriksaan stok sebelum stok dikurangi.
- Lihat detail transaksi dan laporan laba kotor.

## Menjalankan aplikasi

Pastikan Flutter SDK sudah terpasang, lalu jalankan:

```sh
flutter pub get
flutter run -d windows
```

Untuk menjalankan versi web, gunakan perangkat Chrome yang tersedia di Flutter:

```sh
flutter run -d chrome
```

Backend SQLite untuk web masih eksperimental dan menggunakan WebAssembly.

## Akun demo

| Peran | Username | Password |
| --- | --- | --- |
| Admin | `admin` | `admin123` |
| Kasir | `cashier` | `cashier123` |

Akun ini ditanam di aplikasi untuk demo. Login lokal ini bukan mekanisme
keamanan untuk penggunaan produksi.

## Data dan laporan

Database bernama `inventory_app.db` dibuat saat aplikasi pertama kali berjalan.
Database baru diisi katalog dan transaksi contoh. Data tersimpan di perangkat
masing-masing dan tidak disinkronkan ke server.

Laporan laba kotor menghitung penjualan dikurangi HPP. HPP memakai harga beli
terakhir yang tercatat pada barang saat transaksi penjualan dibuat.
