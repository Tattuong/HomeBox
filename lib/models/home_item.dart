enum HomeItemCategory {
  storage,
  furniture,
  electrical,
  bill,
  warranty,
  pdfGuide,
  repair,
}

class HomeItem {
  final String id;
  final String title;
  final String? description;
  final String roomId;
  final HomeItemCategory category;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Storage / Furniture
  final String? location;
  final int? quantity;

  // Electrical
  final bool? isOn;
  final double? value;
  final String? unit;

  // Bill
  final double? amount;
  final DateTime? dueDate;
  final bool? isPaid;

  // Warranty
  final DateTime? purchaseDate;
  final DateTime? expiryDate;
  final String? serialNumber;

  // PDF
  final String? filePath;
  final String? fileName;

  // Repair
  final double? repairCost;
  final DateTime? repairDate;
  final String? contractor;

  // Photos
  final List<String> photoPaths;

  const HomeItem({
    required this.id,
    required this.title,
    this.description,
    required this.roomId,
    required this.category,
    required this.createdAt,
    this.updatedAt,
    this.location,
    this.quantity,
    this.isOn,
    this.value,
    this.unit,
    this.amount,
    this.dueDate,
    this.isPaid,
    this.purchaseDate,
    this.expiryDate,
    this.serialNumber,
    this.filePath,
    this.fileName,
    this.repairCost,
    this.repairDate,
    this.contractor,
    this.photoPaths = const [],
  });

  HomeItem copyWith({
    String? title,
    String? description,
    String? roomId,
    DateTime? updatedAt,
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
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      roomId: roomId ?? this.roomId,
      category: category,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      location: location ?? this.location,
      quantity: quantity ?? this.quantity,
      isOn: isOn ?? this.isOn,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      isPaid: isPaid ?? this.isPaid,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      expiryDate: expiryDate ?? this.expiryDate,
      serialNumber: serialNumber ?? this.serialNumber,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      repairCost: repairCost ?? this.repairCost,
      repairDate: repairDate ?? this.repairDate,
      contractor: contractor ?? this.contractor,
      photoPaths: photoPaths ?? this.photoPaths,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'roomId': roomId,
        'category': category.name,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'location': location,
        'quantity': quantity,
        'isOn': isOn,
        'value': value,
        'unit': unit,
        'amount': amount,
        'dueDate': dueDate?.toIso8601String(),
        'isPaid': isPaid,
        'purchaseDate': purchaseDate?.toIso8601String(),
        'expiryDate': expiryDate?.toIso8601String(),
        'serialNumber': serialNumber,
        'filePath': filePath,
        'fileName': fileName,
        'repairCost': repairCost,
        'repairDate': repairDate?.toIso8601String(),
        'contractor': contractor,
        'photoPaths': photoPaths,
      };

  factory HomeItem.fromJson(Map<String, dynamic> json) {
    return HomeItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      roomId: json['roomId'] as String? ?? 'all',
      category: HomeItemCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => HomeItemCategory.storage,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      location: json['location'] as String?,
      quantity: json['quantity'] as int?,
      isOn: json['isOn'] as bool?,
      value: (json['value'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
      isPaid: json['isPaid'] as bool?,
      purchaseDate: json['purchaseDate'] != null ? DateTime.parse(json['purchaseDate'] as String) : null,
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate'] as String) : null,
      serialNumber: json['serialNumber'] as String?,
      filePath: json['filePath'] as String?,
      fileName: json['fileName'] as String?,
      repairCost: (json['repairCost'] as num?)?.toDouble(),
      repairDate: json['repairDate'] != null ? DateTime.parse(json['repairDate'] as String) : null,
      contractor: json['contractor'] as String?,
      photoPaths: (json['photoPaths'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }
}
