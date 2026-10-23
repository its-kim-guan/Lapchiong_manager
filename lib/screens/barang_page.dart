import 'package:flutter/material.dart';
import 'package:my_app/models/inventory_item.dart';
import 'package:my_app/utils/app_constants.dart';
import 'package:my_app/utils/formatters.dart';
import 'package:my_app/widgets/widgets.dart';

// ---------------------------------------------------------------------------
// Scroll-triggered fade + slide animation widget
// ---------------------------------------------------------------------------
class _AnimatedListItem extends StatefulWidget {
  const _AnimatedListItem({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<_AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<_AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    // Stagger each card by 60 ms so they cascade in
    final delay = widget.index * 60;
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) _controller.forward();
    });

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// ---------------------------------------------------------------------------
// BarangPage
// ---------------------------------------------------------------------------
class BarangPage extends StatefulWidget {
  const BarangPage({
    super.key,
    required this.items,
    this.onAdd,
    this.onEdit,
    this.onDelete,
    required this.onRefresh,
    this.canManageItems = true,
  });

  final List<InventoryItem> items;
  final VoidCallback? onAdd;
  final ValueChanged<InventoryItem>? onEdit;
  final ValueChanged<InventoryItem>? onDelete;
  final Future<void> Function() onRefresh;
  final bool canManageItems;

  @override
  State<BarangPage> createState() => _BarangPageState();
}

class _BarangPageState extends State<BarangPage> {
  final _searchController = TextEditingController();
  bool _showLowStockOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final filteredItems = widget.items.where((item) {
      final matchesQuery =
          query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query);
      final matchesStock = !_showLowStockOnly || item.isLowStock;
      return matchesQuery && matchesStock;
    }).toList();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF600D12), Color(0xFF8F1218), Color(0xFFC2410C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: RefreshIndicator(
        color: const Color(0xFFD62828),
        onRefresh: widget.onRefresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Manajemen Barang',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Color(0xCC7F1D1D),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              title: 'Kontrol Stok',
              backgroundColor: Colors.white.withAlpha(236),
              titleColor: const Color(0xFF7F1D1D),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Cari, filter, dan kelola katalog lapchiong dari satu tempat.',
                          style: TextStyle(
                            color: Color(0xFF7F1D1D),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFB91C1C),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: widget.canManageItems ? widget.onAdd : null,
                        icon: Icon(
                          widget.canManageItems
                              ? Icons.add
                              : Icons.visibility_outlined,
                        ),
                        label: Text(
                          widget.canManageItems ? 'Tambah' : 'Lihat Saja',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _searchController,
                    label: 'Cari nama atau kategori',
                    prefixIcon: Icons.search,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      FilterChip(
                        label: Text('Stok menipis <= $lowStockThreshold'),
                        selected: _showLowStockOnly,
                        backgroundColor: const Color(0xFFFFE4E6),
                        selectedColor: const Color(0xFFFECACA),
                        labelStyle: const TextStyle(
                          color: Color(0xFF7F1D1D),
                          fontWeight: FontWeight.w700,
                        ),
                        side: const BorderSide(color: Color(0xFFFCA5A5)),
                        onSelected: (value) {
                          setState(() {
                            _showLowStockOnly = value;
                          });
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7F1D1D),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          '${filteredItems.length} barang',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16), // space before item list
            if (filteredItems.isEmpty)
              const EmptyState(
                message: 'Tidak ada barang yang cocok.',
                icon: Icons.search_off_rounded,
              )
            else
              ...filteredItems.asMap().entries.map(
                (entry) => Padding(
                  // ← spacing between cards
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _AnimatedListItem(
                    index: entry.key,
                    child: Card(
                      color: Colors.white.withAlpha(238),
                      elevation: 10,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        title: Text(
                          entry.value.name,
                          style: const TextStyle(
                            color: Color(0xFF7F1D1D),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Chip(
                                backgroundColor: const Color(0xFFFFE7E2),
                                label: Text(entry.value.category),
                              ),
                              Chip(
                                backgroundColor: const Color(0xFFFEE2E2),
                                label: Text('Stok ${entry.value.stock}'),
                              ),
                              Chip(
                                backgroundColor: const Color(0xFFFFEDD5),
                                label: Text(
                                  'Beli ${formatCurrency(entry.value.purchasePrice)}',
                                ),
                              ),
                              Chip(
                                backgroundColor: const Color(0xFFFFEDD5),
                                label: Text(
                                  'Jual ${formatCurrency(entry.value.salePrice)}',
                                ),
                              ),
                              Chip(
                                backgroundColor: entry.value.isLowStock
                                    ? const Color(0xFFFECACA)
                                    : const Color(0xFFFFE4E6),
                                label: Text(
                                  entry.value.isLowStock
                                      ? 'Restock segera'
                                      : 'Stok aman',
                                  style: const TextStyle(
                                    color: Color(0xFF7F1D1D),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: Wrap(
                          spacing: 8,
                          children: [
                            IconButton(
                              onPressed: widget.canManageItems
                                  ? () => widget.onEdit?.call(entry.value)
                                  : null,
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: Color(0xFFB91C1C),
                              ),
                              tooltip: 'Ubah',
                            ),
                            IconButton(
                              onPressed: widget.canManageItems
                                  ? () => widget.onDelete?.call(entry.value)
                                  : null,
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Color(0xFF7F1D1D),
                              ),
                              tooltip: 'Hapus',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
