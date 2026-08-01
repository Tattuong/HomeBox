import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/navigation/app_navigator.dart';
import '../models/shop_coin_event.dart';
import 'app_toast.dart';

class CoinNotification {
  static void show({
    BuildContext? context,
    required ShopCoinEvent event,
    required int balance,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = rootNavigatorKey.currentContext ?? context;
      if (ctx == null || !ctx.mounted) return;

      final amountText = '+${event.amount}';
      final title = AppStrings.t(ctx, event.messageKey, {'amount': event.amount.toString()});
      final message = AppStrings.t(ctx, 'coinRewardSub', {'balance': balance.toString()});

      AppToast.show(
        ctx,
        title: title,
        message: message,
        icon: Icons.star_rounded,
        color: AppColors.coin,
        amountBadge: amountText,
      );
    });
  }
}
