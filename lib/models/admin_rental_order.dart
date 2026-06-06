class AdminRentalOrder {
  final int id;
  final String code;
  final String? companyName;
  final DateTime startDate;
  final DateTime expectedEndDate;
  final DateTime? actualEndDate;
  final String? purpose;
  final String status;
  final double rentalTotal;
  final double depositTotal;
  final double compensationTotal;
  final String? note;
  final List<AdminRentalOrderDevice> devices;

  const AdminRentalOrder({
    required this.id,
    required this.code,
    required this.companyName,
    required this.startDate,
    required this.expectedEndDate,
    required this.actualEndDate,
    required this.purpose,
    required this.status,
    required this.rentalTotal,
    required this.depositTotal,
    required this.compensationTotal,
    required this.note,
    required this.devices,
  });

  factory AdminRentalOrder.fromJson(Map<String, dynamic> json) {
    final deviceItems = json['devices'] as List<dynamic>? ?? const [];

    return AdminRentalOrder(
      id: json['id'] as int? ?? 0,
      code: json['maDonThue'] as String? ?? '',
      companyName: json['tenDonVi'] as String?,
      startDate: _toDate(json['ngayBatDau']) ?? DateTime.now(),
      expectedEndDate: _toDate(json['ngayKetThucDuKien']) ?? DateTime.now(),
      actualEndDate: _toDate(json['ngayKetThucThucTe']),
      purpose: json['mucDichSuDung'] as String?,
      status: json['trangThai'] as String? ?? '',
      rentalTotal: _toDouble(json['tongTienThue']),
      depositTotal: _toDouble(json['tongTienDatCoc']),
      compensationTotal: _toDouble(json['tongTienDenBu']),
      note: json['ghiChu'] as String?,
      devices: deviceItems
          .whereType<Map<String, dynamic>>()
          .map(AdminRentalOrderDevice.fromJson)
          .toList(),
    );
  }

  double get grandTotal => rentalTotal + depositTotal + compensationTotal;

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}

class AdminRentalOrderDevice {
  final int id;
  final int deviceId;
  final String? assetCode;
  final String? deviceName;
  final double dailyRentalPrice;
  final int rentalDays;
  final double lineTotal;
  final String status;

  const AdminRentalOrderDevice({
    required this.id,
    required this.deviceId,
    required this.assetCode,
    required this.deviceName,
    required this.dailyRentalPrice,
    required this.rentalDays,
    required this.lineTotal,
    required this.status,
  });

  factory AdminRentalOrderDevice.fromJson(Map<String, dynamic> json) {
    return AdminRentalOrderDevice(
      id: json['id'] as int? ?? 0,
      deviceId: json['mayTinhId'] as int? ?? 0,
      assetCode: json['maTaiSan'] as String?,
      deviceName: json['tenMay'] as String?,
      dailyRentalPrice: _toDouble(json['giaThueNgay']),
      rentalDays: json['soNgayThue'] as int? ?? 0,
      lineTotal: _toDouble(json['thanhTien']),
      status: json['trangThai'] as String? ?? '',
    );
  }

  String get displayName {
    final name = deviceName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return assetCode ?? 'Thiết bị';
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
