import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../widgets/ad_banner_slot.dart';
import '../widgets/app_ui.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import 'search/search_screen.dart';
import 'shop/shop_screen.dart';
import 'stats/stats_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 2;

  @override
  Widget build(BuildContext context) {
    return AppLightShellTheme(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: _index,
          children: [
            const SearchScreen(),
            const StatsScreen(),
            const HomeScreen(),
            ShopScreen(embedded: true, isActive: _index == 3),
            const ProfileScreen(),
          ],
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AdBannerSlot(),
            _BottomNav(
              index: _index,
              onChanged: (i) => setState(() => _index = i),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const _BottomNav({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(8, 10, 8, bottom > 0 ? bottom : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            label: AppStrings.t(context, 'tabSearch'),
            active: index == 0,
            icon: Icons.search_rounded,
            onTap: () => onChanged(0),
          ),
          _NavItem(
            label: AppStrings.t(context, 'tabStats'),
            active: index == 1,
            icon: Icons.bar_chart_rounded,
            onTap: () => onChanged(1),
          ),
          _NavItem(
            label: AppStrings.t(context, 'tabHome'),
            active: index == 2,
            icon: Icons.home_rounded,
            onTap: () => onChanged(2),
            isHome: true,
          ),
          _NavItem(
            label: AppStrings.t(context, 'tabShop'),
            active: index == 3,
            icon: Icons.storefront_outlined,
            onTap: () => onChanged(3),
          ),
          _NavItem(
            label: AppStrings.t(context, 'tabProfile'),
            active: index == 4,
            icon: Icons.person_outline_rounded,
            onTap: () => onChanged(4),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final bool active;
  final IconData icon;
  final VoidCallback onTap;
  final bool isHome;

  const _NavItem({
    required this.label,
    required this.active,
    required this.icon,
    required this.onTap,
    this.isHome = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primaryCoral : AppColors.textMuted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: color),
              if (active && isHome)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryCoral,
                    shape: BoxShape.circle,
                  ),
                )
              else
                const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
