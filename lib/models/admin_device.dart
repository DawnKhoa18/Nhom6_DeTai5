class AdminDevice {
  final int id;
  final String assetCode;
  final String? serialNumber;
  final String? modelName;
  final String? brand;
  final String type;
  final String? cpu;
  final String? ram;
  final String? storage;
  final String? gpu;
  final String? screen;
  final String? operatingSystem;
  final double originalValue;
  final double dailyRentalPrice;
  final double depositRate;
  final String status;
  final DateTime? importedDate;
  final String? note;

  const AdminDevice({
    required this.id,
    required this.assetCode,
    required this.serialNumber,
    required this.modelName,
    required this.brand,
    required this.type,
    required this.cpu,
    required this.ram,
    required this.storage,
    required this.gpu,
    required this.screen,
    required this.operatingSystem,
    required this.originalValue,
    required this.dailyRentalPrice,
    required this.depositRate,
    required this.status,
    required this.importedDate,
    required this.note,
  });

  factory AdminDevice.fromJson(Map<String, dynamic> json) {
    return AdminDevice(
      id: json['id'] as int,
      assetCode: json['maTaiSan'] as String? ?? '',
      serialNumber: json['serialNumber'] as String?,
      modelName: json['tenDong'] as String?,
      brand: json['hang'] as String?,
      type: json['loaiMay'] as String? ?? '',
      cpu: json['cpu'] as String?,
      ram: json['ram'] as String?,
      storage: json['oCung'] as String?,
      gpu: json['gpu'] as String?,
      screen: json['manHinh'] as String?,
      operatingSystem: json['heDieuHanh'] as String?,
      originalValue: _toDouble(json['giaTriMay']),
      dailyRentalPrice: _toDouble(json['giaThueNgay']),
      depositRate: _toDouble(json['tiLeDatCoc']),
      status: json['tinhTrang'] as String? ?? '',
      importedDate: _toDate(json['ngayNhap']),
      note: json['ghiChu'] as String?,
    );
  }

  String get displayName {
    final parts = [brand, modelName]
        .where((value) => value != null && value.trim().isNotEmpty)
        .map((value) => value!)
        .toList();

    return parts.isEmpty ? assetCode : parts.join(' ');
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
