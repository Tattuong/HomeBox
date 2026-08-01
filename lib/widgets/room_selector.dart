import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../models/home_room.dart';

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

  @override
  Widget build(BuildContext context) {
    final room = HomeRoom.byId(roomId);
    if (room.imageAsset == null) return const SizedBox.shrink();

    return Container(
      height: 140,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(image: AssetImage(room.imageAsset!), fit: BoxFit.cover),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withValues(alpha: 0.4), Colors.transparent],
          ),
        ),
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.all(16),
        child: Text(
          AppStrings.t(context, room.nameKey),
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
