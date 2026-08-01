import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/home_item.dart';
import '../../models/home_room.dart';
import '../../providers/home_provider.dart';
import '../../widgets/app_ui.dart';
import '../modules/item_form_screen.dart';

/// Inventory detail for an electrical appliance — not a live IoT controller.
class DeviceDetailScreen extends StatelessWidget {
  final HomeItem item;

  const DeviceDetailScreen({super.key, required this.item});

  String _roomLabel(BuildContext context) {
    final room = HomeRoom.all.firstWhere(
      (r) => r.id.name == item.roomId,
      orElse: () => HomeRoom.all.first,
    );
    return AppStrings.t(context, room.nameKey);
  }

  Future<void> _edit(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ItemFormScreen(category: HomeItemCategory.electrical, existing: item),
      ),
    );
    if (context.mounted) Navigator.pop(context);
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.t(context, 'deleteConfirm', {'title': item.title})),
        content: Text(AppStrings.t(context, 'deleteConfirmBody')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.t(context, 'cancel'))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(AppStrings.t(context, 'delete')),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await context.read<HomeProvider>().deleteItem(item.id);
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppLightShellTheme(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700)),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
              onSelected: (v) {
                switch (v) {
                  case 'edit':
                    _edit(context);
                  case 'delete':
                    _confirmDelete(context);
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(value: 'edit', child: Text(AppStrings.t(context, 'edit'))),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(AppStrings.t(context, 'delete'), style: const TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (item.photoPaths.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Image.file(File(item.photoPaths.first), fit: BoxFit.cover),
                ),
              ),
            if (item.photoPaths.isNotEmpty) const SizedBox(height: 20),
            _InfoCard(
              children: [
                _InfoRow(icon: Icons.meeting_room_outlined, label: AppStrings.t(context, 'room'), value: _roomLabel(context)),
                if (item.location != null && item.location!.isNotEmpty)
                  _InfoRow(icon: Icons.place_outlined, label: AppStrings.t(context, 'location'), value: item.location!),
                if (item.serialNumber != null && item.serialNumber!.isNotEmpty)
                  _InfoRow(icon: Icons.tag_outlined, label: AppStrings.t(context, 'serialNumber'), value: item.serialNumber!),
              ],
            ),
            if (item.description != null && item.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _InfoCard(
                children: [
                  Text(AppStrings.t(context, 'description'), style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(item.description!, style: const TextStyle(color: AppColors.textSecondary, height: 1.45)),
                ],
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _edit(context),
              icon: const Icon(Icons.edit_outlined),
              label: Text(AppStrings.t(context, 'edit')),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryCoral,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primaryCoral),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
