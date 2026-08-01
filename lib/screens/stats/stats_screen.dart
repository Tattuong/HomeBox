import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/home_item.dart';
import '../../providers/home_provider.dart';
import '../../providers/shop_provider.dart';
import '../shop/shop_screen.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeProvider>();
    final shop = context.watch<ShopProvider>();
    final premium = shop.hasPremiumStats;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                AppStrings.t(context, 'statsOverview'),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.15,
              ),
              delegate: SliverChildListDelegate([
                _StatCard(
                  label: AppStrings.t(context, 'totalDevices'),
                  value: '${home.totalDevices}',
                  icon: Icons.devices_outlined,
                  color: AppColors.primaryCoral,
                ),
                _StatCard(
                  label: AppStrings.t(context, 'activeDevices'),
                  value: '${home.activeDevices}',
                  icon: Icons.power_settings_new_rounded,
                  color: AppColors.success,
                ),
                _StatCard(
                  label: AppStrings.t(context, 'unpaidBills'),
                  value: '${home.totalUnpaidBills.toStringAsFixed(0)}',
                  icon: Icons.receipt_long_outlined,
                  color: AppColors.warning,
                ),
                _StatCard(
                  label: AppStrings.t(context, 'totalRepair'),
                  value: '${home.totalRepairCosts.toStringAsFixed(0)}',
                  icon: Icons.build_outlined,
                  color: AppColors.error,
                ),
              ]),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Text(
                AppStrings.t(context, 'weeklyOverview'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 220,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: premium
                    ? _CategoryChart(home: home)
                    : _LockedChart(onUnlock: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen(initialTab: ShopRewardsTab.features)));
                      }),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                label,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryChart extends StatelessWidget {
  final HomeProvider home;

  const _CategoryChart({required this.home});

  @override
  Widget build(BuildContext context) {
    final categories = HomeItemCategory.values;
    final counts = categories.map((c) => home.countForCategory(c).toDouble()).toList();
    final max = counts.reduce((a, b) => a > b ? a : b);
    final safeMax = max > 0 ? max : 1;

    return BarChart(
      BarChartData(
        maxY: safeMax + 1,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= categories.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('${i + 1}', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(categories.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: counts[i],
                color: AppColors.categoryPalette[i % AppColors.categoryPalette.length],
                width: 14,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _LockedChart extends StatelessWidget {
  final VoidCallback onUnlock;

  const _LockedChart({required this.onUnlock});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline, size: 40, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(AppStrings.t(context, 'premiumChartsLocked'), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onUnlock,
            style: FilledButton.styleFrom(backgroundColor: AppColors.primaryCoral),
            child: Text(AppStrings.t(context, 'navShop')),
          ),
        ],
      ),
    );
  }
}
