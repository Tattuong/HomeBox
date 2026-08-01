import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/services/photo_service.dart';
import '../models/home_room.dart';
import '../providers/home_provider.dart';
import 'app_toast.dart';

class RoomSelector extends StatelessWidget {
  final HomeRoomId selected;
  final ValueChanged<HomeRoomId> onChanged;
  final bool showImages;

  const RoomSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    this.showImages = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: showImages ? 100 : 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: HomeRoom.all.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (ctx, i) {
          final room = HomeRoom.all[i];
          final active = selected == room.id;
          return GestureDetector(
            onTap: () => onChanged(room.id),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: active ? AppColors.primaryCoral.withValues(alpha: 0.15) : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: active ? AppColors.primaryCoral : Colors.transparent,
                      width: 2,
                    ),
                    image: showImages && room.imageAsset != null
                        ? DecorationImage(
                            image: AssetImage(room.imageAsset!),
                            fit: BoxFit.cover,
                            colorFilter: active
                                ? null
                                : ColorFilter.mode(Colors.grey.withValues(alpha: 0.4), BlendMode.saturation),
                          )
                        : null,
                  ),
                  child: (room.imageAsset != null && showImages)
                      ? null
                      : Icon(
                          room.icon,
                          color: active ? AppColors.primaryCoral : AppColors.textSecondary,
                          size: 26,
                        ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 72,
                  child: Text(
                    AppStrings.t(context, room.nameKey),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: active ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class RoomImageHeader extends StatelessWidget {
  final HomeRoomId roomId;

  const RoomImageHeader({super.key, required this.roomId});

  ImageProvider _imageFor(HomeRoom room, HomeProvider home) {
    final custom = home.roomImagePath(roomId);
    if (custom != null && File(custom).existsSync()) {
      return FileImage(File(custom));
    }
    return AssetImage(room.imageAsset!);
  }

  Future<void> _pickPhoto(BuildContext context) async {
    final home = context.read<HomeProvider>();
    final room = HomeRoom.byId(roomId);

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final saved = await PhotoService.instance.persistPlatformFile(result.files.first);
    if (saved == null) {
      if (context.mounted) {
        AppToast.show(
          context,
          title: AppStrings.t(context, 'photoPickFailed'),
          icon: Icons.error_outline_rounded,
          color: AppColors.error,
        );
      }
      return;
    }

    await home.setRoomImage(roomId, saved);
    if (context.mounted) {
      AppToast.show(
        context,
        title: AppStrings.t(context, 'roomPhotoUpdated', {'room': AppStrings.t(context, room.nameKey)}),
        icon: Icons.check_rounded,
        color: AppColors.success,
      );
    }
  }

  void _showOptions(BuildContext context) {
    final home = context.read<HomeProvider>();
    final room = HomeRoom.byId(roomId);
    final hasCustom = home.roomImagePath(roomId) != null;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.t(context, 'changeRoomPhotoTitle', {'room': AppStrings.t(context, room.nameKey)}),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _pickPhoto(context);
                },
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(AppStrings.t(context, 'pickGallery')),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryCoral,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              if (hasCustom) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await home.resetRoomImage(roomId);
                    if (context.mounted) {
                      AppToast.show(context, title: AppStrings.t(context, 'roomPhotoReset'));
                    }
                  },
                  icon: const Icon(Icons.restore_outlined),
                  label: Text(AppStrings.t(context, 'resetRoomPhoto')),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final room = HomeRoom.byId(roomId);
    if (room.imageAsset == null) return const SizedBox.shrink();

    return Consumer<HomeProvider>(
      builder: (context, home, _) {
        return GestureDetector(
          onTap: () => _showOptions(context),
          child: Container(
            height: 140,
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(image: _imageFor(room, home), fit: BoxFit.cover),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withValues(alpha: 0.45), Colors.transparent],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      AppStrings.t(context, room.nameKey),
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.photo_camera_outlined, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          AppStrings.t(context, 'changeRoomPhoto'),
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
