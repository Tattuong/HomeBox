import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/home_item.dart';
import '../../models/home_room.dart';
import '../../providers/home_provider.dart';
import '../../providers/shop_provider.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/app_ui.dart';
import '../../widgets/photo_picker_section.dart';

class ItemFormScreen extends StatefulWidget {
  final HomeItemCategory category;
  final HomeItem? existing;

  const ItemFormScreen({super.key, required this.category, this.existing});

  @override
  State<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _quantityCtrl;
  late TextEditingController _amountCtrl;
  late TextEditingController _serialCtrl;
  late TextEditingController _contractorCtrl;
  late TextEditingController _repairCostCtrl;
  late TextEditingController _valueCtrl;

  String _roomId = HomeRoomId.all.name;
  DateTime? _dueDate;
  DateTime? _purchaseDate;
  DateTime? _expiryDate;
  DateTime? _repairDate;
  bool _isOn = false;
  bool _isPaid = false;
  String? _pdfPath;
  String? _pdfName;
  List<String> _photos = [];

  bool get _isEditing => widget.existing != null;

  String _normalizeRoomId(String roomId) {
    if (roomId == HomeRoomId.all.name) {
      return HomeRoomId.livingRoom.name;
    }
    final valid = HomeRoom.all.where((r) => r.id != HomeRoomId.all).map((r) => r.id.name);
    return valid.contains(roomId) ? roomId : HomeRoomId.livingRoom.name;
  }

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _locationCtrl = TextEditingController(text: e?.location ?? '');
    _quantityCtrl = TextEditingController(text: '${e?.quantity ?? 1}');
    _amountCtrl = TextEditingController(text: e?.amount?.toStringAsFixed(0) ?? '');
    _serialCtrl = TextEditingController(text: e?.serialNumber ?? '');
    _contractorCtrl = TextEditingController(text: e?.contractor ?? '');
    _repairCostCtrl = TextEditingController(text: e?.repairCost?.toStringAsFixed(0) ?? '');
    _valueCtrl = TextEditingController(text: e?.value?.toStringAsFixed(0) ?? '24');
    _roomId = _normalizeRoomId(e?.roomId ?? context.read<HomeProvider>().selectedRoom.name);
    _dueDate = e?.dueDate;
    _purchaseDate = e?.purchaseDate;
    _expiryDate = e?.expiryDate;
    _repairDate = e?.repairDate;
    _isOn = e?.isOn ?? false;
    _isPaid = e?.isPaid ?? false;
    _pdfPath = e?.filePath;
    _pdfName = e?.fileName;
    _photos = List<String>.from(e?.photoPaths ?? []);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _quantityCtrl.dispose();
    _amountCtrl.dispose();
    _serialCtrl.dispose();
    _contractorCtrl.dispose();
    _repairCostCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _pdfPath = result.files.single.path;
        _pdfName = result.files.single.name;
      });
    }
  }

  Future<void> _pickDate(ValueChanged<DateTime?> setter, DateTime? current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setter(picked);
    setState(() {});
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;

    final home = context.read<HomeProvider>();
    final shop = context.read<ShopProvider>();

    if (!_isEditing && !shop.canAddItem(home.countForCategory(widget.category))) {
      if (mounted) AppToast.show(context, title: AppStrings.t(context, 'limitReached'));
      return;
    }

    final item = home.createItem(
      title: title,
      category: widget.category,
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      roomId: _roomId,
      location: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
      quantity: int.tryParse(_quantityCtrl.text),
      isOn: _isOn,
      value: double.tryParse(_valueCtrl.text),
      unit: 'heat',
      amount: double.tryParse(_amountCtrl.text),
      dueDate: _dueDate,
      isPaid: _isPaid,
      purchaseDate: _purchaseDate,
      expiryDate: _expiryDate,
      serialNumber: _serialCtrl.text.trim().isEmpty ? null : _serialCtrl.text.trim(),
      filePath: _pdfPath,
      fileName: _pdfName,
      repairCost: double.tryParse(_repairCostCtrl.text),
      repairDate: _repairDate,
      contractor: _contractorCtrl.text.trim().isEmpty ? null : _contractorCtrl.text.trim(),
      photoPaths: _photos,
    );

    if (_isEditing) {
      await home.updateItem(widget.existing!.copyWith(
        title: title,
        description: item.description,
        roomId: _roomId,
        location: item.location,
        quantity: item.quantity,
        isOn: _isOn,
        value: item.value,
        amount: item.amount,
        dueDate: _dueDate,
        isPaid: _isPaid,
        purchaseDate: _purchaseDate,
        expiryDate: _expiryDate,
        serialNumber: item.serialNumber,
        filePath: _pdfPath,
        fileName: _pdfName,
        repairCost: item.repairCost,
        repairDate: _repairDate,
        contractor: item.contractor,
        photoPaths: _photos,
      ));
    } else {
      await home.addItem(item);
      await shop.rewardForTaskComplete();
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppLightShellTheme(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          title: Text(
            _isEditing ? AppStrings.t(context, 'edit') : AppStrings.t(context, 'addItem'),
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
          ),
          actions: [
            TextButton(
              onPressed: _save,
              child: Text(
                AppStrings.t(context, 'save'),
                style: const TextStyle(color: AppColors.primaryCoral, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(
              controller: _titleCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(labelText: AppStrings.t(context, 'title')),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(labelText: AppStrings.t(context, 'description')),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _roomId,
              style: const TextStyle(color: AppColors.textPrimary),
              dropdownColor: Colors.white,
              decoration: InputDecoration(labelText: AppStrings.t(context, 'room')),
              items: HomeRoom.all
                  .where((r) => r.id != HomeRoomId.all)
                  .map((r) => DropdownMenuItem(value: r.id.name, child: Text(AppStrings.t(context, r.nameKey))))
                  .toList(),
              onChanged: (v) => setState(() => _roomId = v ?? HomeRoomId.livingRoom.name),
            ),
            if (widget.category != HomeItemCategory.pdfGuide) ...[
              const SizedBox(height: 16),
              PhotoPickerSection(
                photos: _photos,
                onChanged: (paths) => setState(() => _photos = paths),
              ),
            ],
            ..._categoryFields(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _categoryFields(BuildContext context) {
    return switch (widget.category) {
      HomeItemCategory.storage => [
        const SizedBox(height: 12),
        TextField(controller: _locationCtrl, decoration: InputDecoration(labelText: AppStrings.t(context, 'location'))),
        const SizedBox(height: 12),
        TextField(controller: _quantityCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: AppStrings.t(context, 'quantity'))),
      ],
      HomeItemCategory.furniture => [
        const SizedBox(height: 12),
        TextField(controller: _locationCtrl, decoration: InputDecoration(labelText: AppStrings.t(context, 'location'))),
      ],
      HomeItemCategory.electrical => [
        const SizedBox(height: 12),
        TextField(controller: _valueCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Temperature °')),
        SwitchListTile(
          title: Text(AppStrings.t(context, 'power')),
          value: _isOn,
          activeColor: AppColors.toggleOn,
          onChanged: (v) => setState(() => _isOn = v),
        ),
      ],
      HomeItemCategory.bill => [
        const SizedBox(height: 12),
        TextField(controller: _amountCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: AppStrings.t(context, 'amount'))),
        ListTile(
          title: Text(AppStrings.t(context, 'dueDate')),
          subtitle: Text(_dueDate?.toString().split(' ').first ?? '-'),
          trailing: const Icon(Icons.calendar_today_outlined),
          onTap: () => _pickDate((d) => _dueDate = d, _dueDate),
        ),
        SwitchListTile(
          title: Text(AppStrings.t(context, 'isPaid')),
          value: _isPaid,
          onChanged: (v) => setState(() => _isPaid = v),
        ),
      ],
      HomeItemCategory.warranty => [
        const SizedBox(height: 12),
        TextField(controller: _serialCtrl, decoration: InputDecoration(labelText: AppStrings.t(context, 'serialNumber'))),
        ListTile(
          title: Text(AppStrings.t(context, 'purchaseDate')),
          subtitle: Text(_purchaseDate?.toString().split(' ').first ?? '-'),
          onTap: () => _pickDate((d) => _purchaseDate = d, _purchaseDate),
        ),
        ListTile(
          title: Text(AppStrings.t(context, 'expiryDate')),
          subtitle: Text(_expiryDate?.toString().split(' ').first ?? '-'),
          onTap: () => _pickDate((d) => _expiryDate = d, _expiryDate),
        ),
      ],
      HomeItemCategory.pdfGuide => [
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _pickPdf,
          icon: const Icon(Icons.upload_file_outlined),
          label: Text(_pdfName ?? AppStrings.t(context, 'selectPdf')),
        ),
      ],
      HomeItemCategory.repair => [
        const SizedBox(height: 12),
        TextField(controller: _repairCostCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: AppStrings.t(context, 'repairCost'))),
        TextField(controller: _contractorCtrl, decoration: InputDecoration(labelText: AppStrings.t(context, 'contractor'))),
        ListTile(
          title: Text(AppStrings.t(context, 'repairDate')),
          subtitle: Text(_repairDate?.toString().split(' ').first ?? '-'),
          onTap: () => _pickDate((d) => _repairDate = d, _repairDate),
        ),
      ],
    };
  }
}
