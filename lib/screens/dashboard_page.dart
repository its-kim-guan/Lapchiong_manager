import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_app/models/models.dart';
import 'package:my_app/utils/app_constants.dart';
import 'package:my_app/utils/formatters.dart';
import 'package:my_app/widgets/widgets.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.snapshot,
    required this.onRefresh,
  });

  final AppSnapshot snapshot;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final lowStockItems =
        snapshot.items.where((item) => item.isLowStock).toList()
          ..sort((a, b) => a.stock.compareTo(b.stock));
    final bestMarginItem = snapshot.items.isEmpty
        ? null
        : (snapshot.items.toList()
                ..sort((a, b) => b.margin.compareTo(a.margin)))
              .first;

    final summaryCards = [
      SummaryCard(
        title: 'Jumlah Barang',
        value: '${snapshot.totalItems} item',
        icon: Icons.inventory_2,
        color: Colors.white.withValues(alpha: 0.20),
        subtitle: 'SKU aktif di katalog',
        backgroundColor: const Color(0xFFD62828),
        titleColor: Colors.white,
        valueColor: Colors.white,
        subtitleColor: const Color(0xFFFFE7E2),
        iconTintColor: Colors.white, // icon — white
      ),
      SummaryCard(
        title: 'Total Stok',
        value: '${snapshot.totalStock} unit',
        icon: Icons.warehouse,
        color: Colors.white.withValues(alpha: 0.20),
        subtitle: 'Siap dijual hari ini',
        backgroundColor: const Color(0xFFB91C1C),
        titleColor: Colors.white,
        valueColor: Colors.white,
        subtitleColor: const Color(0xFFFFE7E2),
        iconTintColor: Colors.white,
      ),
      SummaryCard(
        title: 'Nilai Persediaan',
        value: formatCurrency(snapshot.totalInventoryValue),
        icon: Icons.savings_outlined,
        color: Colors.white.withValues(alpha: 0.20),
        subtitle: 'Berdasarkan harga beli',
        backgroundColor: const Color(0xFF9F1239),
        titleColor: Colors.white,
        valueColor: Colors.white,
        subtitleColor: const Color(0xFFFFE7E2),
        iconTintColor: Colors.white,
      ),
      SummaryCard(
        title: 'Total Penjualan',
        value: formatCurrency(snapshot.totalSales),
        icon: Icons.trending_up,
        color: Colors.white.withValues(alpha: 0.20),
        subtitle: 'Akumulasi seluruh transaksi',
        backgroundColor: const Color(0xFFEA580C),
        titleColor: Colors.white,
        valueColor: Colors.white,
        subtitleColor: const Color(0xFFFFF0E8),
        iconTintColor: Colors.white,
      ),
      SummaryCard(
        title: 'Estimasi Laba',
        value: formatCurrency(snapshot.totalProfit),
        icon: Icons.payments_outlined,
        color: Colors.white.withValues(alpha: 0.20),
        subtitle: 'Penjualan dikurangi HPP',
        backgroundColor: const Color(0xFFDC2626),
        titleColor: Colors.white,
        valueColor: Colors.white,
        subtitleColor: const Color(0xFFFFF1E6),
        iconTintColor: Colors.white,
      ),
      SummaryCard(
        title: 'Stok Menipis',
        value: '${snapshot.lowStockCount} item',
        icon: Icons.warning_amber_rounded,
        color: Colors.white.withValues(alpha: 0.20),
        subtitle: 'Batas aman <= $lowStockThreshold unit',
        backgroundColor: const Color(0xFF7F1D1D),
        titleColor: Colors.white,
        valueColor: Colors.white,
        subtitleColor: const Color(0xFFFFE7E2),
        iconTintColor: Colors.white,
      ),
    ];

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
        onRefresh: onRefresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _AnimatedReveal(delay: 0, child: _DashboardHeroCard()),
            const SizedBox(height: 20),
            const _AnimatedReveal(
              delay: 80,
              child: Text(
                'Ringkasan Lapchiong',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Color(0xCC7F1D1D),
                      blurRadius: 18,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(
                summaryCards.length,
                (index) => _AnimatedReveal(
                  delay: 120 + (index * 70),
                  child: summaryCards[index],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _AnimatedReveal(
              delay: 560,
              child: SectionCard(
                title: 'Insight Operasional',
                backgroundColor: Colors.white.withAlpha(232),
                titleColor: const Color(0xFF7F1D1D),
                child: Column(
                  children: [
                    ReportTile(
                      label: 'Produk margin tertinggi',
                      value: bestMarginItem == null
                          ? '-'
                          : '${bestMarginItem.name} (${formatCurrency(bestMarginItem.margin)})',
                    ),
                    ReportTile(
                      label: 'Produk perlu restock',
                      value: lowStockItems.isEmpty
                          ? 'Semua stok aman'
                          : lowStockItems
                                .take(3)
                                .map((item) => '${item.name} (${item.stock})')
                                .join(', '),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _AnimatedReveal(
              delay: 660,
              child: SectionCard(
                title: 'Laporan Periode Aktif',
                backgroundColor: Colors.white.withAlpha(232),
                titleColor: const Color(0xFF7F1D1D),
                child: Column(
                  children: [
                    ReportTile(
                      label: 'Periode',
                      value:
                          '${formatDate(snapshot.report.startDate)} - ${formatDate(snapshot.report.endDate)}',
                    ),
                    ReportTile(
                      label: 'Total Penjualan',
                      value: formatCurrency(snapshot.report.totalSales),
                    ),
                    ReportTile(
                      label: 'Total Pembelian',
                      value: formatCurrency(snapshot.report.totalPurchases),
                    ),
                    ReportTile(
                      label: 'HPP Penjualan',
                      value: formatCurrency(snapshot.report.hpp),
                    ),
                    ReportTile(
                      label: 'Laba Kotor',
                      value: formatCurrency(snapshot.report.grossProfit),
                      emphasize: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardHeroCard extends StatefulWidget {
  const _DashboardHeroCard();

  @override
  State<_DashboardHeroCard> createState() => _DashboardHeroCardState();
}

class _DashboardHeroCardState extends State<_DashboardHeroCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 7),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final wave = math.sin(_controller.value * math.pi * 2);
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [
                const Color(0xFFA61218),
                Color.lerp(
                  const Color(0xFFC81E1E),
                  const Color(0xFFE85D04),
                  (wave + 1) / 2,
                )!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3F060B).withAlpha(130),
                blurRadius: 28 + (wave.abs() * 8),
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: child,
        );
      },
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(36),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withAlpha(110),
                width: 2.6,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x992F0507),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'Assets/Logo_lapchiong.png',
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.lunch_dining,
                    size: 44,
                    color: Colors.white,
                  );
                },
              ),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chinese Lapchiong House',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    shadows: const [
                      Shadow(
                        color: Color(0xFFD44A4A),
                        blurRadius: 18,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Dashboard ini sekarang terhubung langsung ke katalog barang, transaksi pembelian, transaksi penjualan, dan laporan laba rugi sehingga seluruh angka bergerak bersama.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                    shadows: const [
                      Shadow(
                        color: Color(0xAA8F1C1F),
                        blurRadius: 14,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: barangCategoryOptions
                      .map(
                        (option) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x663F060B),
                                blurRadius: 14,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.local_fire_department_outlined,
                                size: 18,
                                color: Color(0xFFB91C1C),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                option,
                                style: const TextStyle(
                                  color: Color(0xFFB91C1C),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedReveal extends StatefulWidget {
  const _AnimatedReveal({required this.child, required this.delay});

  final Widget child;
  final int delay;

  @override
  State<_AnimatedReveal> createState() => _AnimatedRevealState();
}

class _AnimatedRevealState extends State<_AnimatedReveal> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        setState(() {
          _visible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: _visible ? Offset.zero : const Offset(0, 0.08),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
