class AdminContractDevice {
  final int deviceId;
  final String assetCode;
  final String deviceName;

  const AdminContractDevice({
    required this.deviceId,
    required this.assetCode,
    required this.deviceName,
  });

  factory AdminContractDevice.fromJson(Map<String, dynamic> json) {
    return AdminContractDevice(
      deviceId: json['mayTinhId'] as int? ?? 0,
      assetCode: json['maTaiSan'] as String? ?? 'Không mã tài sản',
      deviceName: json['tenMay'] as String? ?? 'Thiết bị',
    );
  }
}

class AdminContract {
  final int id;
  final int rentalOrderId;
  final String code;
  final DateTime createdDate;
  final String? content;
  final String? fileUrl;
  final String status;
  final String rentalOrderCode;
  final String companyName;
  final DateTime? startDate;
  final DateTime? endDate;
  final double rentalAmount;
  final double depositAmount;
  final double compensationAmount;
  final List<AdminContractDevice> devices;

  const AdminContract({
    required this.id,
    required this.rentalOrderId,
    required this.code,
    required this.createdDate,
    required this.content,
    required this.fileUrl,
    required this.status,
    required this.rentalOrderCode,
    required this.companyName,
    required this.startDate,
    required this.endDate,
    required this.rentalAmount,
    required this.depositAmount,
    required this.compensationAmount,
    required this.devices,
  });

  factory AdminContract.fromJson(Map<String, dynamic> json) {
    final devicesJson = json['devices'] as List<dynamic>? ?? const [];
    return AdminContract(
      id: json['id'] as int? ?? 0,
      rentalOrderId: json['donThueId'] as int? ?? 0,
      code: json['maHopDong'] as String? ?? '',
      createdDate: DateTime.tryParse(json['ngayLap']?.toString() ?? '') ??
          DateTime.now(),
      content: json['noiDung'] as String?,
      fileUrl: json['fileUrl'] as String?,
      status: json['trangThai'] as String? ?? '',
      rentalOrderCode: json['maDonThue'] as String? ?? 'Không mã đơn',
      companyName: json['tenDonVi'] as String? ?? 'Không rõ đơn vị',
      startDate: DateTime.tryParse(json['ngayBatDau']?.toString() ?? ''),
      endDate: DateTime.tryParse(json['ngayKetThuc']?.toString() ?? ''),
      rentalAmount: _toDouble(json['tienThue']),
      depositAmount: _toDouble(json['tienDatCoc']),
      compensationAmount: _toDouble(json['tienDenBu']),
      devices: devicesJson
          .whereType<Map<String, dynamic>>()
          .map(AdminContractDevice.fromJson)
          .toList(),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
