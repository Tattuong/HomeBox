import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/iap_constants.dart';
import '../providers/shop_provider.dart';
import 'app_toast.dart';
import 'coin_purchase_sheet.dart';

/// Engagement widgets to encourage coin purchases & daily retention.
class CoinEngagementSection extends StatelessWidget {
  const CoinEngagementSection({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();

    return Column(
      children: [
        if (shop.firstPurchaseBonusAvailable && !shop.isBillingDisabled)
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _FirstPurchaseBanner(),
          ),
        if (!shop.isBillingDisabled)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _HotDealBanner(shop: shop),
          ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: _DailySpinCard(),
        ),
        if (shop.nextUnlockItem != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _UnlockProgressCard(shop: shop),
          ),
      ],
    );
  }
}

class _EngagementCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final Gradient? gradient;

  const _EngagementCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderColor,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? Colors.white : null,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor ?? AppColors.surfaceVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _FirstPurchaseBanner extends StatelessWidget {
  const _FirstPurchaseBanner();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => CoinPurchaseSheet.show(context),
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryCoral, AppColors.primaryCoralDark],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryCoral.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.t(context, 'firstPurchaseTitle'),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.t(context, 'firstPurchaseDesc', {
                        'percent': '${IapConstants.firstPurchaseBonusPercent}',
                      }),
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _HotDealBanner extends StatelessWidget {
  final ShopProvider shop;

  const _HotDealBanner({required this.shop});

  @override
  Widget build(BuildContext context) {
    final packNum = shop.weeklyHotDealPackNumber;
    final base = IapConstants.coinPackAmounts[shop.weeklyHotDealPackIndex];
    final bonus = (base * IapConstants.weeklyDealBonusPercent / 100).round();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => CoinPurchaseSheet.show(context),
        borderRadius: BorderRadius.circular(20),
        child: _EngagementCard(
          borderColor: AppColors.coin.withValues(alpha: 0.35),
          gradient: LinearGradient(
            colors: [
              AppColors.primaryCoralLight.withValues(alpha: 0.35),
              AppColors.coin.withValues(alpha: 0.15),
            ],
          ),
          child: Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.t(context, 'hotDealTitle'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.t(context, 'hotDealDesc', {
                        'pack': '$packNum',
                        'bonus': '$bonus',
                        'percent': '${IapConstants.weeklyDealBonusPercent}',
                      }),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.coin,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  AppStrings.t(context, 'hotDealBadge'),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailySpinCard extends StatefulWidget {
  const _DailySpinCard();

  @override
  State<_DailySpinCard> createState() => _DailySpinCardState();
}

class _DailySpinCardState extends State<_DailySpinCard> with SingleTickerProviderStateMixin {
  late AnimationController _spinCtrl;
  bool _spinning = false;
  int? _lastPrize;

  @override
  void initState() {
    super.initState();
    _spinCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    super.dispose();
  }

  Future<void> _spin() async {
    if (_spinning) return;
    final shop = context.read<ShopProvider>();
    if (await shop.hasSpunToday()) {
      if (mounted) {
        AppToast.show(context, title: AppStrings.t(context, 'spinAlreadyDone'), icon: Icons.info_outline);
      }
      return;
    }

    setState(() {
      _spinning = true;
      _lastPrize = null;
    });

    _spinCtrl.forward(from: 0);
    final prize = await shop.spinDailyWheel();

    if (!mounted) return;
    setState(() {
      _spinning = false;
      _lastPrize = prize;
    });

    if (prize > 0) {
      AppToast.show(
        context,
        title: AppStrings.t(context, 'spinWinTitle', {'coins': '$prize'}),
        icon: Icons.celebration_rounded,
        color: AppColors.coin,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();

    return _EngagementCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _spinCtrl,
                builder: (_, child) => Transform.rotate(
                  angle: _spinCtrl.value * math.pi * 8,
                  child: child,
                ),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.coin, Color(0xFFFFB347)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.casino_rounded, color: Colors.white, size: 28),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.t(context, 'dailySpinTitle'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      shop.loginStreak > 1
                          ? AppStrings.t(context, 'loginStreak', {'days': '${shop.loginStreak}'})
                          : AppStrings.t(context, 'dailySpinDesc'),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FutureBuilder<bool>(
            future: shop.hasSpunToday(),
            builder: (context, snap) {
              final done = snap.data ?? false;
              return SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: (_spinning || done) ? null : _spin,
                  icon: _spinning
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Icon(done ? Icons.check_rounded : Icons.autorenew_rounded),
                  label: Text(
                    _spinning
                        ? AppStrings.t(context, 'spinning')
                        : done
                            ? AppStrings.t(context, 'spinComeBack')
                            : AppStrings.t(context, 'spinNow'),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: done ? AppColors.textMuted : AppColors.primaryCoral,
                    disabledBackgroundColor: AppColors.textMuted,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              );
            },
          ),
          if (_lastPrize != null && _lastPrize! > 0) ...[
            const SizedBox(height: 10),
            Text(
              AppStrings.t(context, 'spinWinTitle', {'coins': '$_lastPrize'}),
              style: const TextStyle(color: AppColors.coin, fontWeight: FontWeight.w700),
            ),
          ],
          if (!shop.isBillingDisabled) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => CoinPurchaseSheet.show(context),
              child: Text(
                AppStrings.t(context, 'wantMoreCoins'),
                style: const TextStyle(
                  color: AppColors.primaryCoral,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _UnlockProgressCard extends StatelessWidget {
  final ShopProvider shop;

  const _UnlockProgressCard({required this.shop});

  @override
  Widget build(BuildContext context) {
    final item = shop.nextUnlockItem!;
    final name = AppStrings.t(context, item.nameKey);
    final needed = shop.coinsToNextUnlock;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: needed > 0 && !shop.isBillingDisabled ? () => CoinPurchaseSheet.show(context) : null,
        borderRadius: BorderRadius.circular(20),
        child: _EngagementCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(item.icon, color: AppColors.primaryCoral, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      needed > 0
                          ? AppStrings.t(context, 'unlockProgressTitle', {'item': name})
                          : AppStrings.t(context, 'unlockReadyTitle', {'item': name}),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (needed > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.coin.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        AppStrings.t(context, 'coinsNeeded', {'count': '$needed'}),
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppColors.coin),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: shop.unlockProgress,
                  minHeight: 10,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primaryCoral),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${shop.coins} / ${item.price} ${AppStrings.t(context, 'coins')}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact teaser for Home screen.
class CoinUnlockTeaser extends StatelessWidget {
  const CoinUnlockTeaser({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final item = shop.nextUnlockItem;
    if (item == null || shop.hasAffordableUnlock || shop.isBillingDisabled) {
      return const SizedBox.shrink();
    }

    final needed = shop.coinsToNextUnlock;
    if (needed <= 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => CoinPurchaseSheet.show(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryCoral.withValues(alpha: 0.25)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_open_rounded, color: AppColors.primaryCoral, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppStrings.t(context, 'homeUnlockTeaser', {
                      'item': AppStrings.t(context, item.nameKey),
                      'coins': '$needed',
                    }),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.primaryCoral),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
