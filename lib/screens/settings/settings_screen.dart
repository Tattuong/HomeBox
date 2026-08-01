import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/home_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/shop_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/app_ui.dart';
import '../../widgets/coin_balance_chip.dart';
import '../../widgets/coin_purchase_sheet.dart';
import '../privacy_policy_screen.dart';
import '../shop/shop_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final theme = context.watch<ThemeProvider>();
    final locale = context.watch<LocaleProvider>();

    return AppPageScaffold(
      title: AppStrings.t(context, 'settings'),
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: CoinBalanceChip(onTap: shop.isBillingDisabled ? null : () => CoinPurchaseSheet.show(context)),
        ),
      ],
      children: [
        AppSectionHeader(AppStrings.t(context, 'darkMode'), icon: Icons.dark_mode_outlined),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppGlassCard(
            padding: EdgeInsets.zero,
            child: SwitchListTile(
              title: Text(AppStrings.t(context, 'darkMode')),
              value: theme.isDarkMode,
              onChanged: (_) => theme.toggleTheme(),
            ),
          ),
        ),
        AppSectionHeader(AppStrings.t(context, 'language'), icon: Icons.language_outlined),
        AppSettingTile(
          icon: Icons.language_outlined,
          title: AppStrings.t(context, 'language'),
          subtitle: locale.isVietnamese ? 'Tiếng Việt' : 'English',
          onTap: () => _pickLanguage(context, locale),
        ),
        AppSectionHeader(AppStrings.t(context, 'navShop'), icon: Icons.storefront_outlined),
        AppSettingTile(
          icon: Icons.stars_rounded,
          title: AppStrings.t(context, 'navShop'),
          subtitle: '${shop.coins} ${AppStrings.t(context, 'coins')}',
          iconColor: AppColors.coin,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen())),
        ),
        if (!shop.isBillingDisabled)
          AppSettingTile(
            icon: Icons.restore_outlined,
            title: AppStrings.t(context, 'restorePurchases'),
            onTap: () async {
              await shop.billing.restorePurchases();
              if (context.mounted) AppToast.show(context, title: AppStrings.t(context, 'restorePurchases'));
            },
          ),
        AppSettingTile(
          icon: Icons.file_download_outlined,
          title: AppStrings.t(context, 'shopFeatExport'),
          subtitle: shop.hasExportData ? null : AppStrings.t(context, 'buyWithCoins'),
          onTap: shop.hasExportData ? () => _exportData(context) : () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen(initialTab: ShopRewardsTab.features)));
          },
        ),
        AppSettingTile(
          icon: Icons.privacy_tip_outlined,
          title: AppStrings.t(context, 'privacyPolicy'),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
        ),
        AppSettingTile(
          icon: Icons.info_outline,
          title: AppStrings.t(context, 'about'),
          subtitle: '${AppStrings.t(context, 'version')} 1.0.0',
        ),
      ],
    );
  }

  Future<void> _exportData(BuildContext context) async {
    final data = context.read<HomeProvider>().exportAllData();
    final json = const JsonEncoder.withIndent('  ').convert(data);
    await Share.share(json, subject: 'HomeBox Export');
    if (context.mounted) AppToast.show(context, title: AppStrings.t(context, 'shopFeatExport'));
  }

  Future<void> _pickLanguage(BuildContext context, LocaleProvider locale) async {
    await showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              trailing: !locale.isVietnamese ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () {
                locale.setEnglish();
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('Tiếng Việt'),
              trailing: locale.isVietnamese ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () {
                locale.setVietnamese();
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}
