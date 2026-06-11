class AdminDamageReport {
  final int id;
  final int rentalItemId;
  final String reporterName;
  final String description;
  final String? imageUrl;
  final int? damageLevelId;
  final String? damageLevelName;
  final double? compensationPercent;
  final double compensationAmount;
  final String status;
  final DateTime reportedAt;
  final String assetCode;
  final String deviceName;
  final double deviceValue;
  final String rentalOrderCode;
  final String companyName;

  const AdminDamageReport({
    required this.id,
    required this.rentalItemId,
    required this.reporterName,
    required this.description,
    required this.imageUrl,
    required this.damageLevelId,
    required this.damageLevelName,
    required this.compensationPercent,
    required this.compensationAmount,
    required this.status,
    required this.reportedAt,
    required this.assetCode,
    required this.deviceName,
    required this.deviceValue,
    required this.rentalOrderCode,
    required this.companyName,
  });

  factory AdminDamageReport.fromJson(Map<String, dynamic> json) {
    return AdminDamageReport(
      id: json['id'] as int? ?? 0,
      rentalItemId: json['chiTietDonThueId'] as int? ?? 0,
      reporterName: json['nguoiBaoCao'] as String? ?? 'Không rõ',
      description: json['moTa'] as String? ?? '',
      imageUrl: json['hinhAnhUrl'] as String?,
      damageLevelId: json['mucDoHuHongId'] as int?,
      damageLevelName: json['tenMucDo'] as String?,
      compensationPercent: json['phanTramDenBu'] == null
          ? null
          : _toDouble(json['phanTramDenBu']),
      compensationAmount: _toDouble(json['tienDenBu']),
      status: json['trangThai'] as String? ?? '',
      reportedAt: DateTime.tryParse(json['ngayBaoCao']?.toString() ?? '') ??
          DateTime.now(),
      assetCode: json['maTaiSan'] as String? ?? 'Không mã tài sản',
      deviceName: json['tenMay'] as String? ?? 'Thiết bị',
      deviceValue: _toDouble(json['giaTriMay']),
      rentalOrderCode: json['maDonThue'] as String? ?? 'Không mã đơn',
      companyName: json['tenDonVi'] as String? ?? 'Không rõ đơn vị',
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
