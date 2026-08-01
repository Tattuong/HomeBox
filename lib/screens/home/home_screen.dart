import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/home_item.dart';
import '../../models/home_room.dart';
import '../../providers/home_provider.dart';
import '../../widgets/notification_icon_button.dart';
import '../../widgets/room_selector.dart';
import '../modules/item_list_screen.dart';

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

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 4),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primaryCoral.withValues(alpha: 0.15),
                    child: const Icon(Icons.home_rounded, color: AppColors.primaryCoral),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _welcomeText(context, home),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        Text(
                          AppStrings.t(context, 'homeSubtitle'),
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const NotificationIconButton(),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: RoomSelector(selected: room, onChanged: home.selectRoom),
          ),
          if (room != HomeRoomId.all)
            SliverToBoxAdapter(child: RoomImageHeader(roomId: room)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                AppStrings.t(context, 'homeModulesTitle'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.25,
              ),
              delegate: SliverChildListDelegate([
                _ModuleCard(
                  icon: Icons.inventory_2_outlined,
                  color: AppColors.primaryCoral,
                  title: AppStrings.t(context, 'modStorage'),
                  subtitle: AppStrings.t(context, 'itemsCount', {
                    'count': '${home.countForCategoryInRoom(HomeItemCategory.storage, room)}',
                  }),
                  onTap: () => _openModule(context, HomeItemCategory.storage),
                ),
                _ModuleCard(
                  icon: Icons.chair_outlined,
                  color: const Color(0xFF5AC8FA),
                  title: AppStrings.t(context, 'modFurniture'),
                  subtitle: AppStrings.t(context, 'itemsCount', {
                    'count': '${home.countForCategoryInRoom(HomeItemCategory.furniture, room)}',
                  }),
                  onTap: () => _openModule(context, HomeItemCategory.furniture),
                ),
                _ModuleCard(
                  icon: Icons.devices_outlined,
                  color: const Color(0xFF5856D6),
                  title: AppStrings.t(context, 'modElectrical'),
                  subtitle: AppStrings.t(context, 'devicesCount', {
                    'count': '${home.countForCategoryInRoom(HomeItemCategory.electrical, room)}',
                  }),
                  onTap: () => _openModule(context, HomeItemCategory.electrical),
                ),
                _ModuleCard(
                  icon: Icons.receipt_long_outlined,
                  color: const Color(0xFFFF9500),
                  title: AppStrings.t(context, 'modBills'),
                  subtitle: AppStrings.t(context, 'billsDue', {
                    'count': '${home.upcomingBillsFor(room).length}',
                  }),
                  onTap: () => _openModule(context, HomeItemCategory.bill),
                ),
                _ModuleCard(
                  icon: Icons.verified_outlined,
                  color: const Color(0xFF34C759),
                  title: AppStrings.t(context, 'modWarranty'),
                  subtitle: AppStrings.t(context, 'warrantyExpiring', {
                    'count': '${home.expiringWarrantiesFor(room).length}',
                  }),
                  onTap: () => _openModule(context, HomeItemCategory.warranty),
                ),
                _ModuleCard(
                  icon: Icons.picture_as_pdf_outlined,
                  color: const Color(0xFF007AFF),
                  title: AppStrings.t(context, 'modPdf'),
                  subtitle: AppStrings.t(context, 'itemsCount', {
                    'count': '${home.countForCategoryInRoom(HomeItemCategory.pdfGuide, room)}',
                  }),
                  onTap: () => _openModule(context, HomeItemCategory.pdfGuide),
                ),
                _ModuleCard(
                  icon: Icons.build_outlined,
                  color: AppColors.error,
                  title: AppStrings.t(context, 'modRepair'),
                  subtitle: '${home.repairCostsFor(room).toStringAsFixed(0)}đ',
                  onTap: () => _openModule(context, HomeItemCategory.repair),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _openModule(BuildContext context, HomeItemCategory category) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ItemListScreen(category: category)));
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.surfaceVariant),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
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
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
