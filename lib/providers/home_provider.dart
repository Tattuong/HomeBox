import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../core/services/photo_service.dart';
import '../core/services/storage_service.dart';
import '../models/home_item.dart';
import '../models/home_room.dart';

class HomeProvider extends ChangeNotifier {
  static const _itemsKey = 'hb_items';
  static const _profileKey = 'hb_profile';
  static const _onboardingKey = 'hb_onboarding_done';

  final _uuid = const Uuid();

  List<HomeItem> _items = [];
  String _userName = '';
  HomeRoomId _selectedRoom = HomeRoomId.all;
  bool _onboardingDone = false;
  bool _initialized = false;

  List<HomeItem> get items => List.unmodifiable(_items);
  String get userName => _userName;
  HomeRoomId get selectedRoom => _selectedRoom;
  bool get onboardingDone => _onboardingDone;
  bool get isInitialized => _initialized;

  Future<void> init() async {
    if (_initialized) return;
    await _loadAll();
    _initialized = true;
    notifyListeners();
  }

  List<HomeItem> itemsForRoom(HomeRoomId room) {
    if (room == HomeRoomId.all) return _items;
    return _items.where((i) => i.roomId == room.name).toList();
  }

  List<HomeItem> itemsForCategory(HomeItemCategory category, {HomeRoomId? room}) {
    final roomFilter = room ?? _selectedRoom;
    return itemsForRoom(roomFilter).where((i) => i.category == category).toList();
  }

  int countForCategory(HomeItemCategory category) =>
      _items.where((i) => i.category == category).length;

  int countForCategoryInRoom(HomeItemCategory category, HomeRoomId room) =>
      itemsForCategory(category, room: room).length;

  List<HomeItem> upcomingBillsFor(HomeRoomId room) {
    final now = DateTime.now();
    return itemsForRoom(room)
        .where((i) =>
            i.category == HomeItemCategory.bill &&
            i.isPaid != true &&
            i.dueDate != null &&
            i.dueDate!.isAfter(now.subtract(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
  }

  List<HomeItem> expiringWarrantiesFor(HomeRoomId room) {
    final now = DateTime.now();
    final threshold = now.add(const Duration(days: 30));
    return itemsForRoom(room)
        .where((i) =>
            i.category == HomeItemCategory.warranty &&
            i.expiryDate != null &&
            i.expiryDate!.isBefore(threshold) &&
            i.expiryDate!.isAfter(now.subtract(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => a.expiryDate!.compareTo(b.expiryDate!));
  }

  double repairCostsFor(HomeRoomId room) => itemsForRoom(room)
      .where((i) => i.category == HomeItemCategory.repair)
      .fold(0.0, (sum, i) => sum + (i.repairCost ?? 0));

  List<HomeItem> search(String query) {
    if (query.trim().isEmpty) return _items;
    final q = query.toLowerCase();
    return _items.where((i) {
      return i.title.toLowerCase().contains(q) ||
          (i.description?.toLowerCase().contains(q) ?? false) ||
          (i.location?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  List<HomeItem> get upcomingBills {
    final now = DateTime.now();
    return _items
        .where((i) =>
            i.category == HomeItemCategory.bill &&
            i.isPaid != true &&
            i.dueDate != null &&
            i.dueDate!.isAfter(now.subtract(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
  }

  List<HomeItem> get expiringWarranties {
    final now = DateTime.now();
    final threshold = now.add(const Duration(days: 30));
    return _items
        .where((i) =>
            i.category == HomeItemCategory.warranty &&
            i.expiryDate != null &&
            i.expiryDate!.isBefore(threshold) &&
            i.expiryDate!.isAfter(now.subtract(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => a.expiryDate!.compareTo(b.expiryDate!));
  }

  List<HomeItem> get notifications =>
      [...upcomingBills, ...expiringWarranties];

  double get totalRepairCosts => _items
      .where((i) => i.category == HomeItemCategory.repair)
      .fold(0.0, (sum, i) => sum + (i.repairCost ?? 0));

  double get totalUnpaidBills => _items
      .where((i) => i.category == HomeItemCategory.bill && i.isPaid != true)
      .fold(0.0, (sum, i) => sum + (i.amount ?? 0));

  int get totalDevices => _items.where((i) => i.category == HomeItemCategory.electrical).length;

  int get activeDevices =>
      _items.where((i) => i.category == HomeItemCategory.electrical && i.isOn == true).length;

  int get totalPhotoCount => _items.fold<int>(0, (sum, i) => sum + i.photoPaths.length);

  void selectRoom(HomeRoomId room) {
    _selectedRoom = room;
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    _userName = name.trim();
    await _saveProfile();
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _onboardingDone = true;
    await StorageService.instance.saveBool(_onboardingKey, true);
    notifyListeners();
  }

  Future<void> addItem(HomeItem item) async {
    _items.add(item);
    await _saveItems();
    notifyListeners();
  }

  Future<void> updateItem(HomeItem item) async {
    final i = _items.indexWhere((e) => e.id == item.id);
    if (i >= 0) _items[i] = item;
    await _saveItems();
    notifyListeners();
  }

  Future<void> deleteItem(String id) async {
    final index = _items.indexWhere((e) => e.id == id);
    if (index >= 0 && _items[index].photoPaths.isNotEmpty) {
      await PhotoService.instance.deletePhotos(_items[index].photoPaths);
    }
    _items.removeWhere((e) => e.id == id);
    await _saveItems();
    notifyListeners();
  }

  Future<void> toggleDevice(String id) async {
    final i = _items.indexWhere((e) => e.id == id);
    if (i < 0) return;
    final item = _items[i];
    _items[i] = item.copyWith(isOn: !(item.isOn ?? false));
    await _saveItems();
    notifyListeners();
  }

  Future<void> markBillPaid(String id) async {
    final i = _items.indexWhere((e) => e.id == id);
    if (i < 0) return;
    _items[i] = _items[i].copyWith(isPaid: true);
    await _saveItems();
    notifyListeners();
  }

  HomeItem createItem({
    required String title,
    required HomeItemCategory category,
    String? description,
    String? roomId,
    String? location,
    int? quantity,
    bool? isOn,
    double? value,
    String? unit,
    double? amount,
    DateTime? dueDate,
    bool? isPaid,
    DateTime? purchaseDate,
    DateTime? expiryDate,
    String? serialNumber,
    String? filePath,
    String? fileName,
    double? repairCost,
    DateTime? repairDate,
    String? contractor,
    List<String>? photoPaths,
  }) {
    return HomeItem(
      id: _uuid.v4(),
      title: title,
      description: description,
      roomId: roomId ?? _selectedRoom.name,
      category: category,
      createdAt: DateTime.now(),
      location: location,
      quantity: quantity,
      isOn: isOn,
      value: value,
      unit: unit,
      amount: amount,
      dueDate: dueDate,
      isPaid: isPaid,
      purchaseDate: purchaseDate,
      expiryDate: expiryDate,
      serialNumber: serialNumber,
      filePath: filePath,
      fileName: fileName,
      repairCost: repairCost,
      repairDate: repairDate,
      contractor: contractor,
      photoPaths: photoPaths ?? const [],
    );
  }

  Future<void> _loadAll() async {
    final itemsJson = await StorageService.instance.getStringList(_itemsKey);
    if (itemsJson != null) {
      _items = itemsJson
          .map((s) => HomeItem.fromJson(jsonDecode(s) as Map<String, dynamic>))
          .toList();
    }

    final profile = await StorageService.instance.getData(_profileKey);
    if (profile != null) {
      _userName = profile['userName']?.toString() ?? '';
    }

    _onboardingDone = await StorageService.instance.getBool(_onboardingKey) ?? false;
  }

  Future<void> _saveItems() async {
    final encoded = _items.map((i) => jsonEncode(i.toJson())).toList();
    await StorageService.instance.saveStringList(_itemsKey, encoded);
  }

  Future<void> _saveProfile() async {
    await StorageService.instance.saveData(_profileKey, {'userName': _userName});
  }

  Map<String, dynamic> exportAllData() => {
        'userName': _userName,
        'items': _items.map((i) => i.toJson()).toList(),
        'exportedAt': DateTime.now().toIso8601String(),
      };
}
