class AdminExtensionDevice {
  final int deviceId;
  final String assetCode;
  final String deviceName;

  const AdminExtensionDevice({
    required this.deviceId,
    required this.assetCode,
    required this.deviceName,
  });

  factory AdminExtensionDevice.fromJson(Map<String, dynamic> json) {
    return AdminExtensionDevice(
      deviceId: json['mayTinhId'] as int? ?? 0,
      assetCode: json['maTaiSan'] as String? ?? 'Không mã tài sản',
      deviceName: json['tenMay'] as String? ?? 'Thiết bị',
    );
  }
}

class AdminExtensionRequest {
  final int id;
  final int rentalOrderId;
  final String rentalOrderCode;
  final String companyName;
  final String rentalOrderStatus;
  final DateTime? currentEndDate;
  final DateTime newEndDate;
  final String? reason;
  final String status;
  final DateTime createdAt;
  final String? approverName;
  final DateTime? approvedAt;
  final List<AdminExtensionDevice> devices;

  const AdminExtensionRequest({
    required this.id,
    required this.rentalOrderId,
    required this.rentalOrderCode,
    required this.companyName,
    required this.rentalOrderStatus,
    required this.currentEndDate,
    required this.newEndDate,
    required this.reason,
    required this.status,
    required this.createdAt,
    required this.approverName,
    required this.approvedAt,
    required this.devices,
  });

  factory AdminExtensionRequest.fromJson(Map<String, dynamic> json) {
    final devicesJson = json['devices'] as List<dynamic>? ?? const [];
    return AdminExtensionRequest(
      id: json['id'] as int? ?? 0,
      rentalOrderId: json['donThueId'] as int? ?? 0,
      rentalOrderCode: json['maDonThue'] as String? ?? 'Không mã đơn',
      companyName: json['tenDonVi'] as String? ?? 'Không rõ đơn vị',
      rentalOrderStatus: json['trangThaiDonThue'] as String? ?? '',
      currentEndDate:
          DateTime.tryParse(json['ngayKetThucHienTai']?.toString() ?? ''),
      newEndDate:
          DateTime.tryParse(json['ngayKetThucMoi']?.toString() ?? '') ??
              DateTime.now(),
      reason: json['lyDo'] as String?,
      status: json['trangThai'] as String? ?? '',
      createdAt: DateTime.tryParse(json['ngayTao']?.toString() ?? '') ??
          DateTime.now(),
      approverName: json['nguoiDuyet'] as String?,
      approvedAt: DateTime.tryParse(json['ngayDuyet']?.toString() ?? ''),
      devices: devicesJson
          .whereType<Map<String, dynamic>>()
          .map(AdminExtensionDevice.fromJson)
          .toList(),
    );
  }
}
