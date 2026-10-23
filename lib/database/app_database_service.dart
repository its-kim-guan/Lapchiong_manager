import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:my_app/models/models.dart';
import 'package:my_app/utils/formatters.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AppDatabaseService {
  Database? _database;

  Future<void> init() async {
    final path = await _resolveDatabasePath();

    if (!kIsWeb && Platform.isWindows) {
      final dbPath = await databaseFactory.getDatabasesPath();
      await Directory(dbPath).create(recursive: true);
    }

    _database = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: (db, version) async {
          await _createSchema(db);
        },
      ),
    );

    await _ensureSeedData();
  }

  Future<String> _resolveDatabasePath() async {
    if (kIsWeb) {
      return 'inventory_app.db';
    }

    final dbPath = await databaseFactory.getDatabasesPath();
    return p.join(dbPath, 'inventory_app.db');
  }

  Database get _db {
    final db = _database;
    if (db == null) {
      throw StateError('Database belum diinisialisasi.');
    }
    return db;
  }

  Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE barang (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        kategori TEXT NOT NULL,
        harga_beli INTEGER NOT NULL,
        harga_jual INTEGER NOT NULL,
        stok INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE pembelian (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tanggal TEXT NOT NULL,
        supplier TEXT NOT NULL,
        total INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE detail_pembelian (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pembelian_id INTEGER NOT NULL,
        barang_id INTEGER NOT NULL,
        jumlah INTEGER NOT NULL,
        harga_beli INTEGER NOT NULL,
        subtotal INTEGER NOT NULL,
        FOREIGN KEY (pembelian_id) REFERENCES pembelian(id) ON DELETE CASCADE,
        FOREIGN KEY (barang_id) REFERENCES barang(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE penjualan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tanggal TEXT NOT NULL,
        pelanggan TEXT NOT NULL,
        total INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE detail_penjualan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        penjualan_id INTEGER NOT NULL,
        barang_id INTEGER NOT NULL,
        jumlah INTEGER NOT NULL,
        harga_beli INTEGER NOT NULL,
        harga_jual INTEGER NOT NULL,
        subtotal INTEGER NOT NULL,
        laba INTEGER NOT NULL,
        FOREIGN KEY (penjualan_id) REFERENCES penjualan(id) ON DELETE CASCADE,
        FOREIGN KEY (barang_id) REFERENCES barang(id)
      )
    ''');
  }

  Future<void> _ensureSeedData() async {
    final itemCount =
        firstIntValue(await _db.rawQuery('SELECT COUNT(*) FROM barang')) ?? 0;

    if (itemCount == 0) {
      await _seedCatalog(_db);
    }

    final purchaseCount =
        firstIntValue(await _db.rawQuery('SELECT COUNT(*) FROM pembelian')) ??
        0;
    final salesCount =
        firstIntValue(await _db.rawQuery('SELECT COUNT(*) FROM penjualan')) ??
        0;

    if (purchaseCount == 0 && salesCount == 0) {
      await _seedTransactions(_db);
    }
  }

  Future<void> _seedCatalog(DatabaseExecutor db) async {
    final createdAt = DateTime.now().toIso8601String();
    final seeds = <ItemPayload>[
      const ItemPayload(
        name: 'Lapchiong Original',
        category: 'Original',
        purchasePrice: 85000,
        salePrice: 98000,
        stock: 18,
      ),
      const ItemPayload(
        name: 'Lapchiong Five Spice',
        category: 'Five Spice',
        purchasePrice: 92000,
        salePrice: 108000,
        stock: 14,
      ),
      const ItemPayload(
        name: 'Lapchiong Chili Garlic',
        category: 'Chili Garlic',
        purchasePrice: 96000,
        salePrice: 114000,
        stock: 12,
      ),
      const ItemPayload(
        name: 'Lapchiong Premium Gift Pack',
        category: 'Premium Gift Pack',
        purchasePrice: 145000,
        salePrice: 169000,
        stock: 10,
      ),
    ];

    for (final item in seeds) {
      await db.insert('barang', {
        'nama': item.name,
        'kategori': item.category,
        'harga_beli': item.purchasePrice,
        'harga_jual': item.salePrice,
        'stok': item.stock,
        'created_at': createdAt,
      });
    }
  }

  Future<void> _seedTransactions(DatabaseExecutor db) async {
    final rows = await db.query('barang', orderBy: 'id ASC');
    if (rows.length < 3) {
      return;
    }

    final items = {
      for (final row in rows)
        (row['nama'] as String): InventoryItem.fromMap(row),
    };

    final original = items['Lapchiong Original'];
    final fiveSpice = items['Lapchiong Five Spice'];
    final chiliGarlic = items['Lapchiong Chili Garlic'];

    if (original == null || fiveSpice == null || chiliGarlic == null) {
      return;
    }

    await _insertPurchase(
      db,
      TransactionPayload(
        partnerName: 'Golden Dragon Supplier',
        date: DateTime.now().subtract(const Duration(days: 10)),
        details: [
          TransactionDetailPayload(
            item: original,
            quantity: 8,
            unitPrice: 83000,
          ),
          TransactionDetailPayload(
            item: fiveSpice,
            quantity: 6,
            unitPrice: 90000,
          ),
        ],
      ),
    );

    await _insertSale(
      db,
      TransactionPayload(
        partnerName: 'Toko Oriental Sejahtera',
        date: DateTime.now().subtract(const Duration(days: 4)),
        details: [
          TransactionDetailPayload(
            item: original,
            quantity: 5,
            unitPrice: 99000,
          ),
          TransactionDetailPayload(
            item: chiliGarlic,
            quantity: 3,
            unitPrice: 116000,
          ),
        ],
      ),
    );
  }

  Future<List<InventoryItem>> getItems() async {
    final rows = await _db.query('barang', orderBy: 'nama ASC');
    return rows.map(InventoryItem.fromMap).toList();
  }

  Future<void> addItem(ItemPayload payload) async {
    await _db.insert('barang', {
      'nama': payload.name,
      'kategori': payload.category,
      'harga_beli': payload.purchasePrice,
      'harga_jual': payload.salePrice,
      'stok': payload.stock,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateItem(int id, ItemPayload payload) async {
    await _db.update(
      'barang',
      {
        'nama': payload.name,
        'kategori': payload.category,
        'harga_beli': payload.purchasePrice,
        'harga_jual': payload.salePrice,
        'stok': payload.stock,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteItem(int id) async {
    final purchaseCount = firstIntValue(
      await _db.rawQuery(
        'SELECT COUNT(*) FROM detail_pembelian WHERE barang_id = ?',
        [id],
      ),
    );
    final salesCount = firstIntValue(
      await _db.rawQuery(
        'SELECT COUNT(*) FROM detail_penjualan WHERE barang_id = ?',
        [id],
      ),
    );

    if ((purchaseCount ?? 0) > 0 || (salesCount ?? 0) > 0) {
      throw Exception(
        'Barang sudah dipakai pada transaksi dan tidak bisa dihapus.',
      );
    }

    await _db.delete('barang', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> createPurchase(TransactionPayload payload) async {
    _validateTransactionPayload(payload);
    await _db.transaction((txn) async {
      await _insertPurchase(txn, payload);
    });
  }

  Future<void> createSale(TransactionPayload payload) async {
    _validateTransactionPayload(payload);
    await _db.transaction((txn) async {
      await _insertSale(txn, payload);
    });
  }

  void _validateTransactionPayload(TransactionPayload payload) {
    if (payload.partnerName.trim().isEmpty) {
      throw ArgumentError('Nama supplier atau pelanggan wajib diisi.');
    }
    if (payload.details.isEmpty) {
      throw ArgumentError('Transaksi harus memiliki minimal satu detail.');
    }

    for (final detail in payload.details) {
      if (detail.item.id == null) {
        throw ArgumentError('Barang transaksi belum tersimpan.');
      }
      if (detail.quantity <= 0 || detail.unitPrice <= 0) {
        throw ArgumentError('Jumlah dan harga harus lebih dari 0.');
      }
    }
  }

  Future<List<TransactionDetailRecord>> getPurchaseDetails(
    int purchaseId,
  ) async {
    final rows = await _db.rawQuery(
      '''
      SELECT d.jumlah, d.harga_beli, d.subtotal, b.nama, b.kategori
      FROM detail_pembelian d
      INNER JOIN barang b ON b.id = d.barang_id
      WHERE d.pembelian_id = ?
      ORDER BY d.id ASC
      ''',
      [purchaseId],
    );

    return rows.map(TransactionDetailRecord.fromPurchaseMap).toList();
  }

  Future<List<TransactionDetailRecord>> getSaleDetails(int saleId) async {
    final rows = await _db.rawQuery(
      '''
      SELECT d.jumlah, d.harga_beli, d.harga_jual, d.subtotal, d.laba, b.nama, b.kategori
      FROM detail_penjualan d
      INNER JOIN barang b ON b.id = d.barang_id
      WHERE d.penjualan_id = ?
      ORDER BY d.id ASC
      ''',
      [saleId],
    );

    return rows.map(TransactionDetailRecord.fromSaleMap).toList();
  }

  Future<void> _insertPurchase(
    DatabaseExecutor db,
    TransactionPayload payload,
  ) async {
    final total = payload.details.fold<int>(
      0,
      (sum, item) => sum + item.subtotal,
    );

    final purchaseId = await db.insert('pembelian', {
      'tanggal': payload.date.toIso8601String(),
      'supplier': payload.partnerName,
      'total': total,
    });

    for (final detail in payload.details) {
      await db.insert('detail_pembelian', {
        'pembelian_id': purchaseId,
        'barang_id': detail.item.id,
        'jumlah': detail.quantity,
        'harga_beli': detail.unitPrice,
        'subtotal': detail.subtotal,
      });

      await db.rawUpdate(
        '''
        UPDATE barang
        SET stok = stok + ?, harga_beli = ?
        WHERE id = ?
        ''',
        [detail.quantity, detail.unitPrice, detail.item.id],
      );
    }
  }

  Future<void> _insertSale(
    DatabaseExecutor db,
    TransactionPayload payload,
  ) async {
    final total = payload.details.fold<int>(
      0,
      (sum, item) => sum + item.subtotal,
    );

    final requestedQuantities = <int, int>{};
    for (final detail in payload.details) {
      final itemId = detail.item.id!;
      requestedQuantities.update(
        itemId,
        (quantity) => quantity + detail.quantity,
        ifAbsent: () => detail.quantity,
      );
    }

    for (final entry in requestedQuantities.entries) {
      final currentStock = firstIntValue(
        await db.rawQuery('SELECT stok FROM barang WHERE id = ?', [entry.key]),
      );

      if (currentStock == null) {
        throw StateError('Barang dengan ID ${entry.key} tidak ditemukan.');
      }

      if (currentStock < entry.value) {
        final itemName = payload.details
            .firstWhere((detail) => detail.item.id == entry.key)
            .item
            .name;
        throw StateError('Stok $itemName tidak mencukupi.');
      }
    }

    final saleId = await db.insert('penjualan', {
      'tanggal': payload.date.toIso8601String(),
      'pelanggan': payload.partnerName,
      'total': total,
    });

    for (final detail in payload.details) {
      final purchasePrice =
          firstIntValue(
            await db.rawQuery('SELECT harga_beli FROM barang WHERE id = ?', [
              detail.item.id,
            ]),
          ) ??
          0;

      final profit = (detail.unitPrice - purchasePrice) * detail.quantity;

      await db.insert('detail_penjualan', {
        'penjualan_id': saleId,
        'barang_id': detail.item.id,
        'jumlah': detail.quantity,
        'harga_beli': purchasePrice,
        'harga_jual': detail.unitPrice,
        'subtotal': detail.subtotal,
        'laba': profit,
      });

      await db.rawUpdate(
        'UPDATE barang SET stok = stok - ?, harga_jual = ? WHERE id = ?',
        [detail.quantity, detail.unitPrice, detail.item.id],
      );
    }
  }

  Future<AppSnapshot> loadSnapshot() async {
    final items = await getItems();
    final purchases = await _db.rawQuery('''
      SELECT p.id, p.tanggal, p.supplier, p.total, COUNT(d.id) AS jumlah_item
      FROM pembelian p
      LEFT JOIN detail_pembelian d ON d.pembelian_id = p.id
      GROUP BY p.id, p.tanggal, p.supplier, p.total
      ORDER BY p.tanggal DESC
    ''');

    final sales = await _db.rawQuery('''
      SELECT p.id, p.tanggal, p.pelanggan, p.total, COUNT(d.id) AS jumlah_item
      FROM penjualan p
      LEFT JOIN detail_penjualan d ON d.penjualan_id = p.id
      GROUP BY p.id, p.tanggal, p.pelanggan, p.total
      ORDER BY p.tanggal DESC
    ''');

    final totalStock =
        firstIntValue(await _db.rawQuery('SELECT SUM(stok) FROM barang')) ?? 0;
    final totalItems =
        firstIntValue(await _db.rawQuery('SELECT COUNT(*) FROM barang')) ?? 0;
    final totalSales =
        firstIntValue(await _db.rawQuery('SELECT SUM(total) FROM penjualan')) ??
        0;
    final totalPurchases =
        firstIntValue(await _db.rawQuery('SELECT SUM(total) FROM pembelian')) ??
        0;
    final totalHpp =
        firstIntValue(
          await _db.rawQuery(
            'SELECT SUM(harga_beli * jumlah) FROM detail_penjualan',
          ),
        ) ??
        0;
    final totalInventoryValue =
        firstIntValue(
          await _db.rawQuery('SELECT SUM(harga_beli * stok) FROM barang'),
        ) ??
        0;
    final lowStockCount =
        firstIntValue(
          await _db.rawQuery('SELECT COUNT(*) FROM barang WHERE stok <= 10'),
        ) ??
        0;

    final report = await getReport();

    return AppSnapshot(
      items: items,
      purchases: purchases.map(TransactionSummary.fromPurchaseMap).toList(),
      sales: sales.map(TransactionSummary.fromSaleMap).toList(),
      report: report,
      totalItems: totalItems,
      totalStock: totalStock,
      totalSales: totalSales,
      totalPurchases: totalPurchases,
      totalProfit: totalSales - totalHpp,
      totalInventoryValue: totalInventoryValue,
      lowStockCount: lowStockCount,
    );
  }

  Future<ProfitLossReport> getReport({DateTime? start, DateTime? end}) async {
    final startDate =
        start ?? DateTime(DateTime.now().year, DateTime.now().month, 1);
    final endDate = end ?? DateTime.now();
    final startIso = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    ).toIso8601String();
    final endIso = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      23,
      59,
      59,
    ).toIso8601String();

    final saleRows = await _db.rawQuery(
      'SELECT SUM(total) FROM penjualan WHERE tanggal BETWEEN ? AND ?',
      [startIso, endIso],
    );
    final purchaseRows = await _db.rawQuery(
      'SELECT SUM(total) FROM pembelian WHERE tanggal BETWEEN ? AND ?',
      [startIso, endIso],
    );
    final hppRows = await _db.rawQuery(
      '''
      SELECT SUM(harga_beli * jumlah)
      FROM detail_penjualan dp
      INNER JOIN penjualan p ON p.id = dp.penjualan_id
      WHERE p.tanggal BETWEEN ? AND ?
      ''',
      [startIso, endIso],
    );

    return ProfitLossReport(
      startDate: startDate,
      endDate: endDate,
      totalSales: firstIntValue(saleRows) ?? 0,
      totalPurchases: firstIntValue(purchaseRows) ?? 0,
      hpp: firstIntValue(hppRows) ?? 0,
    );
  }
}
