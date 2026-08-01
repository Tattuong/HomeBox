import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../providers/shop_provider.dart';
import 'coin_purchase_sheet.dart';

class CoinBalanceChip extends StatelessWidget {
  final VoidCallback? onTap;

  const CoinBalanceChip({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () => CoinPurchaseSheet.show(context),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryCoral.withValues(alpha: 0.12),
                AppColors.primaryCoralLight.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primaryCoral.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.star_rounded, color: AppColors.coin, size: 16),
              const SizedBox(width: 5),
              Text(
                '${shop.coins}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.coin,
                  fontSize: 14,
                  height: 1,
                ),
              ),
              if (!shop.isBillingDisabled) ...[
                const SizedBox(width: 4),
                Icon(Icons.add_circle_outline, color: AppColors.coin.withValues(alpha: 0.85), size: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
