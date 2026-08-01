import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/services/photo_service.dart';
import '../models/shop_item.dart';
import '../providers/home_provider.dart';
import '../providers/shop_provider.dart';
import '../screens/shop/shop_screen.dart';
import 'app_toast.dart';

class PhotoPickerSection extends StatefulWidget {
  final List<String> photos;
  final ValueChanged<List<String>> onChanged;
  final bool compact;

  const PhotoPickerSection({
    super.key,
    required this.photos,
    required this.onChanged,
    this.compact = false,
  });

  @override
  State<PhotoPickerSection> createState() => _PhotoPickerSectionState();
}

class _PhotoPickerSectionState extends State<PhotoPickerSection> {
  final _picker = ImagePicker();
  bool _busy = false;

  bool _canAdd(ShopProvider shop, HomeProvider home) {
    return shop.canAddMorePhotos(home.totalPhotoCount, widget.photos.length);
  }

  void _showLimitSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PhotoUpgradeSheet(),
    );
  }

  void _showPhotoError() {
    AppToast.show(
      context,
      title: AppStrings.t(context, 'photoPickFailed'),
      icon: Icons.error_outline_rounded,
      color: AppColors.error,
    );
  }

  Future<void> _pickGallery() async {
    if (_busy) return;
    final shop = context.read<ShopProvider>();
    final home = context.read<HomeProvider>();

    if (!_canAdd(shop, home)) {
      _showLimitSheet();
      return;
    }

    setState(() => _busy = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final saved = await PhotoService.instance.persistPlatformFile(result.files.first);
      if (!mounted) return;
      if (saved == null) {
        _showPhotoError();
        return;
      }
      widget.onChanged([...widget.photos, saved]);
    } catch (_) {
      if (mounted) _showPhotoError();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pick(ImageSource source) async {
    if (source != ImageSource.camera) {
      await _pickGallery();
      return;
    }

    if (_busy) return;
    final shop = context.read<ShopProvider>();
    final home = context.read<HomeProvider>();

    if (!_canAdd(shop, home)) {
      _showLimitSheet();
      return;
    }

    setState(() => _busy = true);
    try {
      final file = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85, maxWidth: 1920);
      if (file == null) return;
      final saved = await PhotoService.instance.persistXFile(file);
      if (!mounted) return;
      if (saved == null) {
        _showPhotoError();
        return;
      }
      widget.onChanged([...widget.photos, saved]);
    } catch (_) {
      if (mounted) _showPhotoError();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickMultiple() async {
    if (_busy) return;
    final shop = context.read<ShopProvider>();
    final home = context.read<HomeProvider>();

    if (!_canAdd(shop, home)) {
      _showLimitSheet();
      return;
    }

    final limit = shop.photoLimitPerItem - widget.photos.length;
    final totalRemaining = shop.remainingPhotoQuota(home.totalPhotoCount);
    final pickCount = limit.clamp(0, totalRemaining);
    if (pickCount <= 0) {
      _showLimitSheet();
      return;
    }

    setState(() => _busy = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final saved = <String>[];
      for (final f in result.files.take(pickCount)) {
        final path = await PhotoService.instance.persistPlatformFile(f);
        if (path != null) saved.add(path);
      }
      if (!mounted) return;
      if (saved.isEmpty) {
        _showPhotoError();
        return;
      }
      widget.onChanged([...widget.photos, ...saved]);
    } catch (_) {
      if (mounted) _showPhotoError();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _removePhoto(int index) {
    final path = widget.photos[index];
    PhotoService.instance.deletePhoto(path);
    widget.onChanged([...widget.photos]..removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final home = context.watch<HomeProvider>();
    final photos = widget.photos;
    final hero = photos.isNotEmpty ? photos.first : null;
    final limit = shop.photoLimitPerItem;
    final totalUsed = home.totalPhotoCount;
    final totalLimit = shop.photoLimitTotal;
    final usage = shop.photoUsageRatio(totalUsed);
    final showSoftUpgrade = shop.shouldShowPhotoUpgrade(totalUsed);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.compact) ...[
          Row(
            children: [
              const Icon(Icons.photo_camera_front_outlined, size: 18, color: AppColors.primaryCoral),
              const SizedBox(width: 6),
              Text(AppStrings.t(context, 'photos'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const Spacer(),
              Text(
                AppStrings.t(context, 'photoCount', {'current': '${photos.length}', 'max': '$limit'}),
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (!shop.hasPhotoAlbum) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: usage,
                minHeight: 5,
                backgroundColor: AppColors.surfaceVariant,
                valueColor: AlwaysStoppedAnimation(
                  usage >= 1 ? AppColors.error : usage >= 0.7 ? AppColors.warning : AppColors.primaryCoral,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppStrings.t(context, 'photoQuotaTotal', {'used': '$totalUsed', 'max': '$totalLimit'}),
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
          ],
        ],
        if (hero != null)
          GestureDetector(
            onTap: () => _openViewer(photos, 0),
            child: Container(
              height: widget.compact ? 140 : 180,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 6)),
                ],
                image: DecorationImage(image: FileImage(File(hero)), fit: BoxFit.cover),
              ),
              child: photos.length > 1
                  ? Stack(
                      children: [
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.collections_outlined, color: Colors.white, size: 14),
                                const SizedBox(width: 4),
                                Text('${photos.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
          ),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.photo_library_rounded,
                label: AppStrings.t(context, 'pickGallery'),
                color: AppColors.primaryCoral,
                loading: _busy,
                onTap: _pickGallery,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionButton(
                icon: Icons.camera_alt_rounded,
                label: AppStrings.t(context, 'takePhoto'),
                color: AppColors.primaryCoral,
                loading: _busy,
                onTap: () => _pick(ImageSource.camera),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _busy ? null : _pickMultiple,
            icon: const Icon(Icons.collections_rounded),
            label: Text(AppStrings.t(context, 'pickMultiple')),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryCoral,
              side: const BorderSide(color: AppColors.primaryCoral),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        if (showSoftUpgrade) ...[
          const SizedBox(height: 12),
          _SoftUpgradeHint(onTap: _showLimitSheet),
        ],
        if (photos.length > 1) ...[
          const SizedBox(height: 14),
          SizedBox(
            height: 88,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (ctx, i) => GestureDetector(
                onTap: () => _openViewer(photos, i),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(File(photos[i]), width: 88, height: 88, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removePhoto(i),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                          child: const Icon(Icons.close, color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ] else if (photos.length == 1) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _removePhoto(0),
              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
              label: Text(AppStrings.t(context, 'removePhoto'), style: const TextStyle(color: AppColors.error)),
            ),
          ),
        ],
      ],
    );
  }

  void _openViewer(List<String> photos, int initial) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _PhotoViewerScreen(photos: photos, initialIndex: initial)),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool loading;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.loading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 6),
              Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoftUpgradeHint extends StatelessWidget {
  final VoidCallback onTap;

  const _SoftUpgradeHint({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primaryCoral.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: AppColors.primaryCoral, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppStrings.t(context, 'photoSoftUpgradeHint'),
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
            Text(
              AppStrings.t(context, 'learnMore'),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryCoral),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown only when user hits photo limit — optional upgrade, not blocking first use.
class PhotoUpgradeSheet extends StatelessWidget {
  const PhotoUpgradeSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final home = context.watch<HomeProvider>();
    final albumItem = ShopCatalog.find('feat_photo_album');

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 20),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryCoral.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.photo_library_rounded, color: AppColors.primaryCoral, size: 36),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.t(context, 'photoLimitTitle'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.t(context, 'photoLimitBody', {
              'used': '${home.totalPhotoCount}',
              'max': '${shop.photoLimitTotal}',
            }),
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (albumItem != null && !shop.hasPhotoAlbum)
            _UpsellOption(
              item: albumItem,
              onBuy: () => _buy(context, shop, albumItem.id),
            )
          else
            FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primaryCoral),
              child: Text(AppStrings.t(context, 'ok')),
            ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.t(context, 'maybeLater')),
          ),
        ],
      ),
    );
  }

  void _buy(BuildContext context, ShopProvider shop, String id) {
    final result = shop.buyWithCoins(id);
    if (!context.mounted) return;
    if (result == ShopPurchaseResult.success) {
      Navigator.pop(context);
      AppToast.show(context, title: AppStrings.t(context, 'applied'), icon: Icons.check_rounded, color: AppColors.success);
    } else if (result == ShopPurchaseResult.insufficientCoins) {
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen(initialTab: ShopRewardsTab.features)));
    }
  }
}

class _UpsellOption extends StatelessWidget {
  final ShopItem item;
  final VoidCallback onBuy;

  const _UpsellOption({required this.item, required this.onBuy});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primaryCoral.withValues(alpha: 0.08), AppColors.coin.withValues(alpha: 0.08)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryCoral.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(item.icon, color: AppColors.primaryCoral),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.t(context, item.nameKey), style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(AppStrings.t(context, item.descKey), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onBuy,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.coin,
              foregroundColor: Colors.black87,
              minimumSize: const Size(double.infinity, 44),
            ),
            icon: const Icon(Icons.star_rounded, size: 18),
            label: Text(AppStrings.t(context, 'unlockForStars', {'price': '${item.price}'})),
          ),
        ],
      ),
    );
  }
}

class _PhotoViewerScreen extends StatelessWidget {
  final List<String> photos;
  final int initialIndex;

  const _PhotoViewerScreen({required this.photos, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${initialIndex + 1} / ${photos.length}'),
      ),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: photos.length,
        itemBuilder: (_, i) => InteractiveViewer(
          child: Center(child: Image.file(File(photos[i]), fit: BoxFit.contain)),
        ),
      ),
    );
  }
}
