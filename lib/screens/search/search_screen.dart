import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/home_item.dart';
import '../../providers/home_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _categoryLabel(BuildContext context, HomeItemCategory category) => switch (category) {
        HomeItemCategory.storage => AppStrings.t(context, 'modStorage'),
        HomeItemCategory.furniture => AppStrings.t(context, 'modFurniture'),
        HomeItemCategory.electrical => AppStrings.t(context, 'smartDevices'),
        HomeItemCategory.bill => AppStrings.t(context, 'modBills'),
        HomeItemCategory.warranty => AppStrings.t(context, 'modWarranty'),
        HomeItemCategory.pdfGuide => AppStrings.t(context, 'modPdf'),
        HomeItemCategory.repair => AppStrings.t(context, 'modRepair'),
      };

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeProvider>();
    final results = home.search(_query);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Text(
              AppStrings.t(context, 'tabSearch'),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _controller,
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
              cursorColor: AppColors.primaryCoral,
              decoration: InputDecoration(
                hintText: AppStrings.t(context, 'searchHint'),
                hintStyle: const TextStyle(color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _query.isEmpty
                ? Center(
                    child: Text(
                      AppStrings.t(context, 'searchHint'),
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : results.isEmpty
                    ? Center(
                        child: Text(
                          AppStrings.t(context, 'searchEmpty'),
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: results.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (ctx, i) {
                          final item = results[i];
                          return ListTile(
                            tileColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: AppColors.surfaceVariant),
                            ),
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primaryCoral.withValues(alpha: 0.12),
                              child: const Icon(Icons.home_outlined, color: AppColors.primaryCoral, size: 20),
                            ),
                            title: Text(
                              item.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              _categoryLabel(context, item.category),
                              style: const TextStyle(color: AppColors.textSecondary),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
