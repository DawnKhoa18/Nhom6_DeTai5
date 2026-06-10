class AdminMaintenance {
  final int id;
  final int deviceId;
  final String? assetCode;
  final String? deviceName;
  final DateTime startDate;
  final DateTime? endDate;
  final String content;
  final double cost;
  final String status;

  const AdminMaintenance({
    required this.id,
    required this.deviceId,
    required this.assetCode,
    required this.deviceName,
    required this.startDate,
    required this.endDate,
    required this.content,
    required this.cost,
    required this.status,
  });

  factory AdminMaintenance.fromJson(Map<String, dynamic> json) {
    return AdminMaintenance(
      id: json['id'] as int? ?? 0,
      deviceId: json['mayTinhId'] as int? ?? 0,
      assetCode: json['maTaiSan'] as String?,
      deviceName: json['tenMay'] as String?,
      startDate: DateTime.tryParse(json['ngayBatDau']?.toString() ?? '') ??
          DateTime.now(),
      endDate: DateTime.tryParse(json['ngayKetThuc']?.toString() ?? ''),
      content: json['noiDung'] as String? ?? '',
      cost: _toDouble(json['chiPhi']),
      status: json['trangThai'] as String? ?? '',
    );
  }

  String get displayDeviceName {
    final name = deviceName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return assetCode ?? 'Thiết bị';
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
