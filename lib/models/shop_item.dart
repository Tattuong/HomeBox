import 'package:flutter/material.dart';

enum ShopItemType {
  theme,
  background,
  skin,
  feature,
  removeAds,
}

enum ShopItemCategory {
  themes,
  backgrounds,
  skins,
  features,
  premium,
}

class ShopItem {
  final String id;
  final String nameKey;
  final String descKey;
  final int price;
  final ShopItemType type;
  final ShopItemCategory category;
  final IconData icon;
  final bool oneTime;

  const ShopItem({
    required this.id,
    required this.nameKey,
    required this.descKey,
    required this.price,
    required this.type,
    required this.category,
    required this.icon,
    this.oneTime = true,
  });
}

class ShopCatalog {
  ShopCatalog._();

  static const String defaultThemeId = 'theme_default';
  static const String defaultBackgroundId = 'bg_default';
  static const String defaultSkinId = 'skin_default';

  static const List<ShopItem> items = [
    ShopItem(
      id: 'remove_ads',
      nameKey: 'shopRemoveAds',
      descKey: 'shopRemoveAdsDesc',
      price: 500,
      type: ShopItemType.removeAds,
      category: ShopItemCategory.premium,
      icon: Icons.block_outlined,
    ),
    ShopItem(
      id: 'theme_ocean',
      nameKey: 'shopThemeOcean',
      descKey: 'shopThemeOceanDesc',
      price: 200,
      type: ShopItemType.theme,
      category: ShopItemCategory.themes,
      icon: Icons.water_outlined,
    ),
    ShopItem(
      id: 'theme_forest',
      nameKey: 'shopThemeForest',
      descKey: 'shopThemeForestDesc',
      price: 200,
      type: ShopItemType.theme,
      category: ShopItemCategory.themes,
      icon: Icons.forest_outlined,
    ),
    ShopItem(
      id: 'theme_sunset',
      nameKey: 'shopThemeSunset',
      descKey: 'shopThemeSunsetDesc',
      price: 250,
      type: ShopItemType.theme,
      category: ShopItemCategory.themes,
      icon: Icons.wb_twilight_outlined,
    ),
    ShopItem(
      id: 'theme_lavender',
      nameKey: 'shopThemeLavender',
      descKey: 'shopThemeLavenderDesc',
      price: 250,
      type: ShopItemType.theme,
      category: ShopItemCategory.themes,
      icon: Icons.nightlight_round,
    ),
    ShopItem(
      id: 'bg_clouds',
      nameKey: 'shopBgClouds',
      descKey: 'shopBgCloudsDesc',
      price: 150,
      type: ShopItemType.background,
      category: ShopItemCategory.backgrounds,
      icon: Icons.cloud_outlined,
    ),
    ShopItem(
      id: 'bg_stars',
      nameKey: 'shopBgStars',
      descKey: 'shopBgStarsDesc',
      price: 150,
      type: ShopItemType.background,
      category: ShopItemCategory.backgrounds,
      icon: Icons.star_outline,
    ),
    ShopItem(
      id: 'bg_rainbow',
      nameKey: 'shopBgRainbow',
      descKey: 'shopBgRainbowDesc',
      price: 200,
      type: ShopItemType.background,
      category: ShopItemCategory.backgrounds,
      icon: Icons.auto_awesome_outlined,
    ),
    ShopItem(
      id: 'bg_aurora',
      nameKey: 'shopBgAurora',
      descKey: 'shopBgAuroraDesc',
      price: 200,
      type: ShopItemType.background,
      category: ShopItemCategory.backgrounds,
      icon: Icons.gradient_outlined,
    ),
    ShopItem(
      id: 'skin_soft',
      nameKey: 'shopSkinSoft',
      descKey: 'shopSkinSoftDesc',
      price: 150,
      type: ShopItemType.skin,
      category: ShopItemCategory.skins,
      icon: Icons.circle_outlined,
    ),
    ShopItem(
      id: 'skin_glass',
      nameKey: 'shopSkinGlass',
      descKey: 'shopSkinGlassDesc',
      price: 180,
      type: ShopItemType.skin,
      category: ShopItemCategory.skins,
      icon: Icons.blur_on_outlined,
    ),
    ShopItem(
      id: 'skin_bold',
      nameKey: 'shopSkinBold',
      descKey: 'shopSkinBoldDesc',
      price: 200,
      type: ShopItemType.skin,
      category: ShopItemCategory.skins,
      icon: Icons.border_style_outlined,
    ),
    ShopItem(
      id: 'feat_export',
      nameKey: 'shopFeatExport',
      descKey: 'shopFeatExportDesc',
      price: 200,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.file_download_outlined,
    ),
    ShopItem(
      id: 'feat_unlimited_items',
      nameKey: 'shopFeatUnlimited',
      descKey: 'shopFeatUnlimitedDesc',
      price: 300,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.all_inbox_outlined,
    ),
    ShopItem(
      id: 'feat_premium_stats',
      nameKey: 'shopFeatStats',
      descKey: 'shopFeatStatsDesc',
      price: 250,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.show_chart_outlined,
    ),
    ShopItem(
      id: 'feat_bill_reminder',
      nameKey: 'shopFeatBillReminder',
      descKey: 'shopFeatBillReminderDesc',
      price: 200,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.notifications_active_outlined,
    ),
    ShopItem(
      id: 'feat_pdf_pro',
      nameKey: 'shopFeatPdfPro',
      descKey: 'shopFeatPdfProDesc',
      price: 180,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.picture_as_pdf_outlined,
    ),
    ShopItem(
      id: 'feat_photo_album',
      nameKey: 'shopFeatPhotoAlbum',
      descKey: 'shopFeatPhotoAlbumDesc',
      price: 250,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.collections_rounded,
    ),
  ];

  static ShopItem? find(String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }
}
