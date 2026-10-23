import 'package:flutter/material.dart';
import 'package:my_app/database/app_database_service.dart';
import 'package:my_app/models/models.dart';
import 'package:my_app/screens/barang_page.dart';
import 'package:my_app/screens/dashboard_page.dart';
import 'package:my_app/screens/laporan_page.dart';
import 'package:my_app/screens/pembelian_page.dart';
import 'package:my_app/screens/penjualan_page.dart';
import 'package:my_app/utils/app_constants.dart';
import 'package:my_app/widgets/barang_dialog.dart';
import 'package:my_app/widgets/transaction_detail_dialog.dart';
import 'package:my_app/widgets/transaction_dialog.dart';

class InventoryApp extends StatefulWidget {
  const InventoryApp({
    super.key,
    required this.databaseService,
    required this.currentUser,
    required this.onLogout,
  });

  final AppDatabaseService databaseService;
  final AppUser currentUser;
  final VoidCallback onLogout;

  @override
  State<InventoryApp> createState() => _InventoryAppState();
}

class _InventoryAppState extends State<InventoryApp> {
  int _selectedIndex = 0;
  late Future<AppSnapshot> _snapshotFuture;

  @override
  void initState() {
    super.initState();
    _snapshotFuture = widget.databaseService.loadSnapshot();
  }

  Future<void> _refresh() async {
    setState(() {
      _snapshotFuture = widget.databaseService.loadSnapshot();
    });
    await _snapshotFuture;
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.currentUser.role;
    final pages = <_NavPage>[
      _NavPage(
        title: 'Dashboard',
        label: 'Home',
        icon: Icons.dashboard_outlined,
        builder: (data) => DashboardPage(snapshot: data, onRefresh: _refresh),
      ),
      _NavPage(
        title: 'Data Barang',
        label: 'Barang',
        icon: Icons.inventory_2_outlined,
        builder: (data) => BarangPage(
          items: data.items,
          onAdd: role.canManageItems ? () => _openBarangDialog() : null,
          onEdit: role.canManageItems
              ? (item) => _openBarangDialog(item: item)
              : null,
          onDelete: role.canManageItems ? _deleteBarang : null,
          onRefresh: _refresh,
          canManageItems: role.canManageItems,
        ),
      ),
      if (role.canManagePurchases)
        _NavPage(
          title: 'Pembelian',
          label: 'Beli',
          icon: Icons.shopping_cart_outlined,
          builder: (data) => PembelianPage(
            items: data.items,
            purchases: data.purchases,
            onCreatePurchase: _openPembelianDialog,
            onOpenPurchaseDetail: _openPurchaseDetail,
          ),
        ),
      if (role.canSellItems)
        _NavPage(
          title: 'Penjualan',
          label: 'Jual',
          icon: Icons.point_of_sale_outlined,
          builder: (data) => PenjualanPage(
            items: data.items,
            sales: data.sales,
            onCreateSale: _openPenjualanDialog,
            onOpenSaleDetail: _openSaleDetail,
          ),
        ),
      if (role.canViewReports)
        _NavPage(
          title: 'Laporan',
          label: 'Laporan',
          icon: Icons.receipt_long_outlined,
          builder: (data) => LaporanPage(report: data.report, snapshot: data),
        ),
    ];

    if (_selectedIndex >= pages.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('$appTitle - ${pages[_selectedIndex].title}'),
        backgroundColor: const Color(0xFF7F1D1D),
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w900,
        ),
        scrolledUnderElevation: 0,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                '${widget.currentUser.name} • ${role.label}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: FutureBuilder<AppSnapshot>(
        future: _snapshotFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Terjadi kesalahan saat memuat data:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final data = snapshot.data!;
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: pages[_selectedIndex].builder(data),
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFFFFF7F5),
        indicatorColor: const Color(0xFFFECACA),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: selected ? const Color(0xFF7F1D1D) : const Color(0xFF9A3412),
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          );
        }),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: pages
            .map(
              (page) => NavigationDestination(
                icon: Icon(page.icon),
                label: page.label,
              ),
            )
            .toList(),
      ),
    );
  }

  Future<void> _openBarangDialog({InventoryItem? item}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => BarangDialog(
        item: item,
        onSave: (payload) async {
          if (item == null) {
            await widget.databaseService.addItem(payload);
          } else {
            await widget.databaseService.updateItem(item.id!, payload);
          }
        },
      ),
    );

    if (result == true) {
      await _refresh();
    }
  }

  Future<void> _deleteBarang(InventoryItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus barang'),
        content: Text('Yakin ingin menghapus "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await widget.databaseService.deleteItem(item.id!);
        await _refresh();
      } catch (error) {
        _showSnack(error.toString());
      }
    }
  }

  Future<void> _openPembelianDialog() async {
    final items = await widget.databaseService.getItems();
    if (!mounted) {
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => TransactionDialog(
        title: 'Form Pembelian',
        items: items,
        mode: TransactionMode.purchase,
        onSave: widget.databaseService.createPurchase,
      ),
    );

    if (result == true) {
      await _refresh();
    }
  }

  Future<void> _openPenjualanDialog() async {
    final items = await widget.databaseService.getItems();
    if (!mounted) {
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => TransactionDialog(
        title: 'Form Penjualan',
        items: items,
        mode: TransactionMode.sale,
        onSave: widget.databaseService.createSale,
      ),
    );

    if (result == true) {
      await _refresh();
    }
  }

  Future<void> _openPurchaseDetail(TransactionSummary summary) async {
    await showDialog<void>(
      context: context,
      builder: (context) => TransactionDetailDialog(
        summary: summary,
        detailsFuture: widget.databaseService.getPurchaseDetails(summary.id),
        isSale: false,
      ),
    );
  }

  Future<void> _openSaleDetail(TransactionSummary summary) async {
    await showDialog<void>(
      context: context,
      builder: (context) => TransactionDetailDialog(
        summary: summary,
        detailsFuture: widget.databaseService.getSaleDetails(summary.id),
        isSale: true,
      ),
    );
  }

  void _showSnack(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _NavPage {
  const _NavPage({
    required this.title,
    required this.label,
    required this.icon,
    required this.builder,
  });

  final String title;
  final String label;
  final IconData icon;
  final Widget Function(AppSnapshot data) builder;
}
