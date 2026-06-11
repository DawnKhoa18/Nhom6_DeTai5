class AdminReturnDevice {
  final int id;
  final int deviceId;
  final String assetCode;
  final String deviceName;
  final String? returnCondition;
  final String status;

  const AdminReturnDevice({
    required this.id,
    required this.deviceId,
    required this.assetCode,
    required this.deviceName,
    required this.returnCondition,
    required this.status,
  });

  factory AdminReturnDevice.fromJson(Map<String, dynamic> json) {
    return AdminReturnDevice(
      id: json['id'] as int? ?? 0,
      deviceId: json['mayTinhId'] as int? ?? 0,
      assetCode: json['maTaiSan'] as String? ?? 'Không mã tài sản',
      deviceName: json['tenMay'] as String? ?? 'Thiết bị',
      returnCondition: json['tinhTrangTraMay'] as String?,
      status: json['trangThai'] as String? ?? '',
    );
  }
}

class AdminReturnRequest {
  final int id;
  final int rentalOrderId;
  final String rentalOrderCode;
  final String companyName;
  final String rentalOrderStatus;
  final DateTime? startDate;
  final DateTime? expectedEndDate;
  final DateTime requestedAt;
  final String? reason;
  final String? note;
  final String status;
  final String? processorName;
  final DateTime? processedAt;
  final List<AdminReturnDevice> devices;

  const AdminReturnRequest({
    required this.id,
    required this.rentalOrderId,
    required this.rentalOrderCode,
    required this.companyName,
    required this.rentalOrderStatus,
    required this.startDate,
    required this.expectedEndDate,
    required this.requestedAt,
    required this.reason,
    required this.note,
    required this.status,
    required this.processorName,
    required this.processedAt,
    required this.devices,
  });

  factory AdminReturnRequest.fromJson(Map<String, dynamic> json) {
    final devicesJson = json['devices'] as List<dynamic>? ?? const [];
    return AdminReturnRequest(
      id: json['id'] as int? ?? 0,
      rentalOrderId: json['donThueId'] as int? ?? 0,
      rentalOrderCode: json['maDonThue'] as String? ?? 'Không mã đơn',
      companyName: json['tenDonVi'] as String? ?? 'Không rõ đơn vị',
      rentalOrderStatus: json['trangThaiDonThue'] as String? ?? '',
      startDate: DateTime.tryParse(json['ngayBatDau']?.toString() ?? ''),
      expectedEndDate:
          DateTime.tryParse(json['ngayKetThucDuKien']?.toString() ?? ''),
      requestedAt:
          DateTime.tryParse(json['ngayYeuCau']?.toString() ?? '') ??
              DateTime.now(),
      reason: json['lyDo'] as String?,
      note: json['ghiChu'] as String?,
      status: json['trangThai'] as String? ?? '',
      processorName: json['nguoiXuLy'] as String?,
      processedAt: DateTime.tryParse(json['ngayXuLy']?.toString() ?? ''),
      devices: devicesJson
          .whereType<Map<String, dynamic>>()
          .map(AdminReturnDevice.fromJson)
          .toList(),
    );
  }
}
