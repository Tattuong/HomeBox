import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../providers/home_provider.dart';
import '../screens/notifications/notifications_screen.dart';

class NotificationIconButton extends StatelessWidget {
  const NotificationIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    final count = context.watch<HomeProvider>().notifications.length;

    return IconButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
      ),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.primaryCoral.withValues(alpha: 0.1),
      ),
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text(
          count > 99 ? '99+' : '$count',
          style: const TextStyle(fontSize: 10),
        ),
        backgroundColor: AppColors.error,
        child: const Icon(Icons.notifications_outlined, color: AppColors.primaryCoral),
      ),
    );
  }
}
