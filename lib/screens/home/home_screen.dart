import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/home_item.dart';
import '../../models/home_room.dart';
import '../../providers/home_provider.dart';
import '../../widgets/coin_balance_chip.dart';
import '../../widgets/coin_engagement_cards.dart';
import '../../widgets/notification_icon_button.dart';
import '../../widgets/room_selector.dart';
import '../modules/item_form_screen.dart';
import '../modules/item_list_screen.dart';
import '../electrical/device_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) return AppStrings.t(context, 'goodMorning');
    if (hour < 17) return AppStrings.t(context, 'goodAfternoon');
    return AppStrings.t(context, 'goodEvening');
  }

  String _welcomeText(BuildContext context, HomeProvider home) {
    if (home.userName.isNotEmpty) {
      return AppStrings.t(context, 'welcomeUser', {'name': home.userName});
    }
    return _greeting(context);
  }

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeProvider>();
    final room = home.selectedRoom;
    final devices = home.itemsForCategory(HomeItemCategory.electrical, room: room);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primaryCoral.withValues(alpha: 0.15),
                    child: const Icon(Icons.person_rounded, color: AppColors.primaryCoral),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _welcomeText(context, home),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const CoinBalanceChip(),
                  const NotificationIconButton(),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: RoomSelector(
              selected: room,
              onChanged: home.selectRoom,
            ),
          ),
          if (room != HomeRoomId.all)
            SliverToBoxAdapter(child: RoomImageHeader(roomId: room)),
          const SliverToBoxAdapter(child: CoinUnlockTeaser()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                AppStrings.t(context, 'smartDevices'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          if (devices.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _EmptyDeviceCard(
                  onAdd: () => _openAddDevice(context),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              sliver: SliverList.separated(
                itemCount: devices.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) => _DeviceCard(
                  item: devices[i],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DeviceDetailScreen(item: devices[i])),
                  ),
                  onToggle: () => home.toggleDevice(devices[i].id),
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
              ),
              delegate: SliverChildListDelegate([
                _ModuleCard(
                  icon: Icons.inventory_2_outlined,
                  color: AppColors.primaryCoral,
                  title: AppStrings.t(context, 'modStorage'),
                  subtitle: AppStrings.t(context, 'itemsCount', {
                    'count': '${home.countForCategory(HomeItemCategory.storage)}',
                  }),
                  onTap: () => _openModule(context, HomeItemCategory.storage),
                ),
                _ModuleCard(
                  icon: Icons.chair_outlined,
                  color: const Color(0xFF5AC8FA),
                  title: AppStrings.t(context, 'modFurniture'),
                  subtitle: AppStrings.t(context, 'itemsCount', {
                    'count': '${home.countForCategory(HomeItemCategory.furniture)}',
                  }),
                  onTap: () => _openModule(context, HomeItemCategory.furniture),
                ),
                _ModuleCard(
                  icon: Icons.receipt_long_outlined,
                  color: const Color(0xFFFF9500),
                  title: AppStrings.t(context, 'modBills'),
                  subtitle: AppStrings.t(context, 'billsDue', {
                    'count': '${home.upcomingBills.length}',
                  }),
                  onTap: () => _openModule(context, HomeItemCategory.bill),
                ),
                _ModuleCard(
                  icon: Icons.verified_outlined,
                  color: const Color(0xFF5856D6),
                  title: AppStrings.t(context, 'modWarranty'),
                  subtitle: AppStrings.t(context, 'warrantyExpiring', {
                    'count': '${home.expiringWarranties.length}',
                  }),
                  onTap: () => _openModule(context, HomeItemCategory.warranty),
                ),
                _ModuleCard(
                  icon: Icons.picture_as_pdf_outlined,
                  color: const Color(0xFF34C759),
                  title: AppStrings.t(context, 'modPdf'),
                  subtitle: AppStrings.t(context, 'itemsCount', {
                    'count': '${home.countForCategory(HomeItemCategory.pdfGuide)}',
                  }),
                  onTap: () => _openModule(context, HomeItemCategory.pdfGuide),
                ),
                _ModuleCard(
                  icon: Icons.build_outlined,
                  color: AppColors.error,
                  title: AppStrings.t(context, 'modRepair'),
                  subtitle: '${home.totalRepairCosts.toStringAsFixed(0)}đ',
                  onTap: () => _openModule(context, HomeItemCategory.repair),
                ),
              ]),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              child: FilledButton.icon(
                onPressed: () => _openAddDevice(context),
                icon: const Icon(Icons.add_rounded),
                label: Text(AppStrings.t(context, 'addNewDevice')),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryCoral,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openModule(BuildContext context, HomeItemCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ItemListScreen(category: category)),
    );
  }

  void _openAddDevice(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ItemFormScreen(category: HomeItemCategory.electrical),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const Spacer(),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final HomeItem item;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const _DeviceCard({required this.item, required this.onTap, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isOn = item.isOn ?? false;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                  image: item.photoPaths.isNotEmpty
                      ? DecorationImage(image: FileImage(File(item.photoPaths.first)), fit: BoxFit.cover)
                      : null,
                ),
                child: item.photoPaths.isEmpty
                    ? Icon(
                        item.value != null ? Icons.thermostat_outlined : Icons.lightbulb_outline_rounded,
                        color: AppColors.textPrimary,
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    Text(
                      item.value != null
                          ? '${item.value!.round()}° ${item.unit ?? 'heat'}'
                          : item.description ?? '',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Switch(
                    value: isOn,
                    onChanged: (_) => onToggle(),
                    activeColor: AppColors.toggleOn,
                  ),
                  Text(
                    AppStrings.t(context, isOn ? 'on' : 'off'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isOn ? AppColors.toggleOn : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyDeviceCard extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyDeviceCard({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.devices_outlined, size: 40, color: AppColors.textMuted),
          const SizedBox(height: 8),
          Text(AppStrings.t(context, 'emptyList'), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
