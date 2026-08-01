import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/home_item.dart';
import '../../providers/home_provider.dart';
import '../../providers/shop_provider.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/app_ui.dart';
import 'item_form_screen.dart';

class ItemListScreen extends StatelessWidget {
  final HomeItemCategory category;

  const ItemListScreen({super.key, required this.category});

  String _title(BuildContext context) {
    return switch (category) {
      HomeItemCategory.storage => AppStrings.t(context, 'modStorage'),
      HomeItemCategory.furniture => AppStrings.t(context, 'modFurniture'),
      HomeItemCategory.electrical => AppStrings.t(context, 'modElectrical'),
      HomeItemCategory.bill => AppStrings.t(context, 'modBills'),
      HomeItemCategory.warranty => AppStrings.t(context, 'modWarranty'),
      HomeItemCategory.pdfGuide => AppStrings.t(context, 'modPdf'),
      HomeItemCategory.repair => AppStrings.t(context, 'modRepair'),
    };
  }

  String _addLabel(BuildContext context) {
    return switch (category) {
      HomeItemCategory.storage => AppStrings.t(context, 'addStorage'),
      HomeItemCategory.furniture => AppStrings.t(context, 'addFurniture'),
      HomeItemCategory.electrical => AppStrings.t(context, 'addDevice'),
      HomeItemCategory.bill => AppStrings.t(context, 'addBill'),
      HomeItemCategory.warranty => AppStrings.t(context, 'addWarranty'),
      HomeItemCategory.pdfGuide => AppStrings.t(context, 'addPdf'),
      HomeItemCategory.repair => AppStrings.t(context, 'addRepair'),
    };
  }

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeProvider>();
    final shop = context.watch<ShopProvider>();
    final items = home.itemsForCategory(category);

    return Scaffold(
      appBar: AppBar(
        title: Text(_title(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _addItem(context, shop, items.length),
          ),
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(AppStrings.t(context, 'emptyList'), textAlign: TextAlign.center),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) => _ItemTile(
                item: items[i],
                onTap: () => _onTap(context, items[i]),
                onDelete: () => home.deleteItem(items[i].id),
                onMarkPaid: category == HomeItemCategory.bill
                    ? () => home.markBillPaid(items[i].id)
                    : null,
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addItem(context, shop, items.length),
        backgroundColor: AppColors.primaryCoral,
        icon: const Icon(Icons.add_rounded),
        label: Text(_addLabel(context)),
      ),
    );
  }

  Future<void> _addItem(BuildContext context, ShopProvider shop, int count) async {
    if (!shop.canAddItem(count)) {
      AppToast.show(context, title: AppStrings.t(context, 'limitReached'));
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ItemFormScreen(category: category)),
    );
  }

  Future<void> _onTap(BuildContext context, HomeItem item) async {
    if (category == HomeItemCategory.pdfGuide && item.filePath != null) {
      final uri = Uri.file(item.filePath!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          AppToast.show(context, title: AppStrings.t(context, 'noPdfFile'));
        }
      }
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ItemFormScreen(category: category, existing: item)),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final HomeItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback? onMarkPaid;

  const _ItemTile({
    required this.item,
    required this.onTap,
    required this.onDelete,
    this.onMarkPaid,
  });

  @override
  Widget build(BuildContext context) {
    final df = DateFormat.yMMMd();

    return AppGlassCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        leading: item.photoPaths.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(item.photoPaths.first), width: 52, height: 52, fit: BoxFit.cover),
              )
            : Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primaryCoral.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.image_outlined, color: AppColors.primaryCoral),
              ),
        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(_subtitle(context, df)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onMarkPaid != null && item.isPaid != true)
              IconButton(
                icon: const Icon(Icons.check_circle_outline, color: AppColors.success),
                onPressed: onMarkPaid,
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  String _subtitle(BuildContext context, DateFormat df) {
    return switch (item.category) {
      HomeItemCategory.storage => '${item.location ?? ''} · x${item.quantity ?? 1}',
      HomeItemCategory.furniture => item.location ?? item.description ?? '',
      HomeItemCategory.electrical => item.isOn == true ? AppStrings.t(context, 'on') : AppStrings.t(context, 'off'),
      HomeItemCategory.bill =>
        '${item.amount?.toStringAsFixed(0) ?? 0} · ${item.isPaid == true ? AppStrings.t(context, 'paid') : AppStrings.t(context, 'unpaid')}${item.dueDate != null ? ' · ${df.format(item.dueDate!)}' : ''}',
      HomeItemCategory.warranty =>
        item.expiryDate != null ? df.format(item.expiryDate!) : item.serialNumber ?? '',
      HomeItemCategory.pdfGuide => item.fileName ?? AppStrings.t(context, 'noPdfFile'),
      HomeItemCategory.repair =>
        '${item.repairCost?.toStringAsFixed(0) ?? 0} · ${item.repairDate != null ? df.format(item.repairDate!) : ''}',
    };
  }
}
