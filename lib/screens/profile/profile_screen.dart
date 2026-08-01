import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/app_theme_preset.dart';
import '../../models/shop_item.dart';
import '../../providers/home_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/shop_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/coin_balance_chip.dart';
import '../../widgets/coin_purchase_sheet.dart';
import '../settings/settings_screen.dart';
import '../shop/shop_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameCtrl;
  bool _claimedToday = false;
  bool _loadingClaim = true;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _checkDailyReward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final name = context.read<HomeProvider>().userName;
    if (_nameCtrl.text.isEmpty) _nameCtrl.text = name;
  }

  Future<void> _checkDailyReward() async {
    final claimed = await context.read<ShopProvider>().hasClaimedDailyToday();
    if (mounted) {
      setState(() {
        _claimedToday = claimed;
        _loadingClaim = false;
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    await context.read<HomeProvider>().setUserName(name);
    if (mounted) AppToast.show(context, title: AppStrings.t(context, 'save'));
  }

  Future<void> _claimDaily() async {
    final ok = await context.read<ShopProvider>().claimDailyReward();
    if (!mounted) return;
    setState(() => _claimedToday = ok || _claimedToday);
  }

  List<_CustomizationOption> _customizationOptions(ShopProvider shop, ShopItemType type, String defaultId) {
    final options = <_CustomizationOption>[
      _CustomizationOption(id: defaultId, labelKey: 'resetDefault'),
    ];
    for (final item in ShopCatalog.items) {
      if (item.type == type && shop.ownsItem(item.id)) {
        options.add(_CustomizationOption(id: item.id, labelKey: item.nameKey));
      }
    }
    return options;
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final theme = context.watch<ThemeProvider>();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      AppStrings.t(context, 'profile'),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                  ),
                  CoinBalanceChip(
                    onTap: shop.isBillingDisabled ? null : () => CoinPurchaseSheet.show(context),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _ProfileCard(
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primaryCoral.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(Icons.person_rounded, color: AppColors.primaryCoral, size: 32),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: TextField(
                          controller: _nameCtrl,
                          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            labelText: AppStrings.t(context, 'userName'),
                            labelStyle: const TextStyle(color: AppColors.textSecondary),
                            filled: true,
                            fillColor: AppColors.surfaceVariant,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.check_rounded, color: AppColors.primaryCoral),
                              onPressed: _saveName,
                            ),
                          ),
                          onSubmitted: (_) => _saveName(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _ProfileCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.t(context, 'coins'),
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, color: AppColors.coin, size: 22),
                                const SizedBox(width: 6),
                                Text(
                                  '${shop.coins}',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.coin,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: _loadingClaim || _claimedToday ? null : _claimDaily,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryCoral,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.surfaceVariant,
                          disabledForegroundColor: AppColors.textMuted,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: Icon(_claimedToday ? Icons.check_rounded : Icons.card_giftcard_rounded, size: 18),
                        label: Text(_claimedToday ? AppStrings.t(context, 'claimed') : AppStrings.t(context, 'claim')),
                      ),
                    ],
                  ),
                ),
                _SectionTitle(AppStrings.t(context, 'navShop'), Icons.storefront_outlined),
                _ProfileMenuTile(
                  icon: Icons.storefront_outlined,
                  title: AppStrings.t(context, 'myShop'),
                  subtitle: AppStrings.t(context, 'earnCoinsDesc'),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen())),
                ),
                _ProfileMenuTile(
                  icon: Icons.settings_outlined,
                  title: AppStrings.t(context, 'settings'),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                ),
                _SectionTitle(AppStrings.t(context, 'themes'), Icons.palette_outlined),
                _CustomizationSelector(
                  options: _customizationOptions(shop, ShopItemType.theme, ShopCatalog.defaultThemeId),
                  activeId: shop.activeThemeId,
                  defaultId: ShopCatalog.defaultThemeId,
                  onSelect: shop.selectTheme,
                  onReset: shop.resetThemeToDefault,
                  previewBuilder: (id) {
                    final preset = AppThemePresets.get(id);
                    return Container(
                      decoration: BoxDecoration(
                        gradient: preset.headerGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    );
                  },
                ),
                _SectionTitle(AppStrings.t(context, 'backgrounds'), Icons.wallpaper_outlined),
                _CustomizationSelector(
                  options: _customizationOptions(shop, ShopItemType.background, ShopCatalog.defaultBackgroundId),
                  activeId: shop.activeBackgroundId,
                  defaultId: ShopCatalog.defaultBackgroundId,
                  onSelect: shop.selectBackground,
                  onReset: shop.resetBackgroundToDefault,
                  previewBuilder: (id) {
                    final bg = AppBackground.get(id);
                    return Container(
                      decoration: BoxDecoration(
                        gradient: bg.gradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    );
                  },
                ),
                _SectionTitle(AppStrings.t(context, 'skins'), Icons.style_outlined),
                _CustomizationSelector(
                  options: _customizationOptions(shop, ShopItemType.skin, ShopCatalog.defaultSkinId),
                  activeId: shop.activeSkinId,
                  defaultId: ShopCatalog.defaultSkinId,
                  onSelect: shop.selectSkin,
                  onReset: shop.resetSkinToDefault,
                  previewBuilder: (id) {
                    final style = CardStyle.get(id);
                    return Container(
                      decoration: BoxDecoration(
                        color: style.accentColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(style.borderRadius / 2),
                        border: style.borderWidth > 0 ? Border.all(color: style.borderColor, width: style.borderWidth) : null,
                      ),
                    );
                  },
                ),
                _SectionTitle(AppStrings.t(context, 'about'), Icons.info_outline),
                _ProfileCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.t(context, 'appName'),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.t(context, 'appTagline'),
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${AppStrings.t(context, 'version')} 1.0.0',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        theme.isDarkMode ? AppStrings.t(context, 'darkMode') : 'Light Mode',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      Text(
                        context.watch<LocaleProvider>().isVietnamese ? 'Tiếng Việt' : 'English',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final Widget child;

  const _ProfileCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceVariant),
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

class _SectionTitle extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SectionTitle(this.label, this.icon);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 10, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primaryCoral),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.surfaceVariant),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryCoral.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primaryCoral, size: 20),
              ),
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
              subtitle: subtitle != null
                  ? Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))
                  : null,
              trailing: Icon(Icons.chevron_right_rounded, color: AppColors.textMuted.withValues(alpha: 0.6)),
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomizationOption {
  final String id;
  final String labelKey;

  const _CustomizationOption({required this.id, required this.labelKey});
}

class _CustomizationSelector extends StatelessWidget {
  final List<_CustomizationOption> options;
  final String activeId;
  final String defaultId;
  final Future<void> Function(String) onSelect;
  final Future<void> Function() onReset;
  final Widget Function(String id) previewBuilder;

  const _CustomizationSelector({
    required this.options,
    required this.activeId,
    required this.defaultId,
    required this.onSelect,
    required this.onReset,
    required this.previewBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return _ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 88,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: options.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (ctx, i) {
                final option = options[i];
                final selected = activeId == option.id;
                return GestureDetector(
                  onTap: () => onSelect(option.id),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 64,
                        height: 64,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected ? AppColors.primaryCoral : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: previewBuilder(option.id),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 72,
                        child: Text(
                          AppStrings.t(context, option.labelKey),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            color: selected ? AppColors.primaryCoral : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (activeId != defaultId) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onReset,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryCoral,
                side: const BorderSide(color: AppColors.primaryCoral),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.restore_rounded, size: 18),
              label: Text(AppStrings.t(context, 'resetDefault')),
            ),
          ],
        ],
      ),
    );
  }
}
