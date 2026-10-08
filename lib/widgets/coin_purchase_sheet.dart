import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/iap_constants.dart';
import '../core/services/iap_config_service.dart';
import '../providers/shop_provider.dart';
import 'app_toast.dart';
import 'app_ui.dart';

class CoinPurchaseSheet {
  static Future<void> show(BuildContext context) async {
    final shop = context.read<ShopProvider>();
    if (shop.isBillingDisabled) return;

    shop.releasePurchaseUi();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurface
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        final maxHeight = MediaQuery.sizeOf(ctx).height * 0.72;
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: const _CoinPurchaseSheet(),
        );
      },
    );
    shop.releasePurchaseUi();
  }
}

class _CoinPurchaseSheet extends StatefulWidget {
  const _CoinPurchaseSheet();

  @override
  State<_CoinPurchaseSheet> createState() => _CoinPurchaseSheetState();
}

class _CoinPurchaseSheetState extends State<_CoinPurchaseSheet> {
  ShopProvider? _shop;
  bool _closedAfterPurchase = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final shop = context.read<ShopProvider>();
    if (_shop != shop) {
      _shop?.removeListener(_onShopChanged);
      _shop = shop;
      _shop!.addListener(_onShopChanged);
    }
  }

  @override
  void dispose() {
    _shop?.removeListener(_onShopChanged);
    super.dispose();
  }

  void _onShopChanged() {
    if (_closedAfterPurchase || !mounted) return;
    final shop = _shop;
    if (shop == null) return;

    if (!shop.isPurchasing && shop.lastMessage == 'coinsAdded') {
      _closedAfterPurchase = true;
      shop.clearLastMessage();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final products = shop.billing.products;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.star_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.t(context, 'buyCoins'),
                        style: AppTypography.titleLarge()),
                    Text(
                      AppStrings.t(context, 'buyCoinsDesc'),
                      style: const TextStyle(
                          color: AppColors.onSurfaceVariant, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.coin.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.coin.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: AppColors.coin, size: 20),
                const SizedBox(width: 8),
                Text(
                  AppStrings.t(
                      context, 'yourCoins', {'count': shop.coins.toString()}),
                  style: AppTypography.labelBold(size: 14),
                ),
              ],
            ),
          ),
          if (shop.configStatus == IapConfigStatus.networkError ||
              shop.configStatus == IapConfigStatus.timeout) ...[
            const SizedBox(height: 12),
            _StatusBanner(
              icon: Icons.wifi_off_outlined,
              text: shop.configStatus == IapConfigStatus.timeout
                  ? AppStrings.t(context, 'configTimeout')
                  : AppStrings.t(context, 'configNetworkError'),
              color: AppColors.warning,
            ),
          ],
          if (shop.isPurchasing) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text(
                  AppStrings.t(context, 'processingPurchase'),
                  style: const TextStyle(
                      color: AppColors.onSurfaceVariant, fontSize: 12),
                ),
              ],
            ),
          ],
          if (!shop.billing.isAvailable) ...[
            const SizedBox(height: 16),
            _StatusBanner(
              icon: Icons.storefront_outlined,
              text: AppStrings.t(context, 'billingUnavailable'),
              color: AppColors.onSurfaceVariant,
            ),
          ] else if (products.isEmpty) ...[
            const SizedBox(height: 16),
            _StatusBanner(
              icon: Icons.inventory_2_outlined,
              text: AppStrings.t(context, 'productsNotFound'),
              color: AppColors.onSurfaceVariant,
            ),
          ] else ...[
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) =>
                    _PackTile(product: products[i], index: i),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            AppStrings.t(context, 'earnCoinsHint'),
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: AppColors.onSurfaceVariant, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _PackTile extends StatelessWidget {
  final ProductDetails product;
  final int index;

  const _PackTile({required this.product, required this.index});

  @override
  Widget build(BuildContext context) {
    final shop = context.read<ShopProvider>();
    final packIndex = IapConstants.coinPackIds.indexOf(product.id);
    final base = IapConstants.coinsForProduct(product.id);
    final total = shop.effectiveCoinsForPackIndex(packIndex);
    final bonus = total - base;
    final packNum = packIndex + 1;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isHotDeal = packIndex == shop.weeklyHotDealPackIndex;
    final isBestValue = packIndex == IapConstants.bestValuePackIndex;

    return Material(
      color: isDark ? AppColors.darkBackground : AppColors.surfaceVariant,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: shop.isPurchasing ? null : () => _buy(context, shop),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: isHotDeal || isBestValue
                ? Border.all(
                    color: isHotDeal ? AppColors.coin : AppColors.primaryBlue,
                    width: 2)
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.coin.withValues(alpha: 0.25),
                      AppColors.accent.withValues(alpha: 0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.star_rounded, color: AppColors.coin),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          AppStrings.t(
                              context, 'coinPack', {'num': packNum.toString()}),
                          style: AppTypography.labelBold(size: 15),
                        ),
                        if (isHotDeal)
                          _Badge(
                            label: AppStrings.t(context, 'hotDealBadge'),
                            color: AppColors.coin,
                          ),
                        if (isBestValue)
                          _Badge(
                            label: AppStrings.t(context, 'bestValueBadge'),
                            color: AppColors.primaryBlue,
                          ),
                        if (shop.firstPurchaseBonusAvailable)
                          _Badge(
                            label: AppStrings.t(context, 'firstPurchaseBadge'),
                            color: const Color(0xFFFF6B6B),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.t(context, 'coinAmountTotal',
                          {'count': total.toString()}),
                      style: const TextStyle(
                          color: AppColors.onSurfaceVariant, fontSize: 12),
                    ),
                    if (bonus > 0)
                      Text(
                        AppStrings.t(context, 'coinBonusExtra', {
                          'base': base.toString(),
                          'bonus': bonus.toString(),
                        }),
                        style: const TextStyle(
                            color: AppColors.success,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: shop.isPurchasing ? null : () => _buy(context, shop),
                child: Text(product.price),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _buy(BuildContext context, ShopProvider shop) async {
    final ok = await shop.buyCoinPack(product);
    if (!context.mounted) return;
    if (ok) {
      AppToast.show(context, title: AppStrings.t(context, 'openingBilling'));
    } else if (shop.lastMessage != null) {
      AppToast.show(context, title: AppStrings.t(context, shop.lastMessage!));
    }
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 9),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _StatusBanner(
      {required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
              child: Text(text, style: TextStyle(color: color, fontSize: 13))),
        ],
      ),
    );
  }
}
