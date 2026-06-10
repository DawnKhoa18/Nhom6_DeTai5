class AdminInvoice {
  final int id;
  final int rentalOrderId;
  final String code;
  final String? rentalOrderCode;
  final String? companyName;
  final double rentalAmount;
  final double depositAmount;
  final double compensationAmount;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final String status;
  final DateTime createdAt;

  const AdminInvoice({
    required this.id,
    required this.rentalOrderId,
    required this.code,
    required this.rentalOrderCode,
    required this.companyName,
    required this.rentalAmount,
    required this.depositAmount,
    required this.compensationAmount,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.status,
    required this.createdAt,
  });

  factory AdminInvoice.fromJson(Map<String, dynamic> json) {
    return AdminInvoice(
      id: json['id'] as int? ?? 0,
      rentalOrderId: json['donThueId'] as int? ?? 0,
      code: json['maHoaDon'] as String? ?? '',
      rentalOrderCode: json['maDonThue'] as String?,
      companyName: json['tenDonVi'] as String?,
      rentalAmount: _toDouble(json['tienThue']),
      depositAmount: _toDouble(json['tienDatCoc']),
      compensationAmount: _toDouble(json['tienDenBu']),
      totalAmount: _toDouble(json['tongThanhToan']),
      paidAmount: _toDouble(json['soTienDaThanhToan']),
      remainingAmount: _toDouble(json['soTienConLai']),
      status: json['trangThai'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['ngayLap']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
