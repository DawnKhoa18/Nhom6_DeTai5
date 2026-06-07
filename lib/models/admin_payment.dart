class AdminPayment {
  final int id;
  final int invoiceId;
  final String? invoiceCode;
  final String? rentalOrderCode;
  final String? companyName;
  final double amount;
  final String method;
  final String? transactionCode;
  final String? note;
  final DateTime paidAt;

  const AdminPayment({
    required this.id,
    required this.invoiceId,
    required this.invoiceCode,
    required this.rentalOrderCode,
    required this.companyName,
    required this.amount,
    required this.method,
    required this.transactionCode,
    required this.note,
    required this.paidAt,
  });

  factory AdminPayment.fromJson(Map<String, dynamic> json) {
    return AdminPayment(
      id: json['id'] as int? ?? 0,
      invoiceId: json['hoaDonId'] as int? ?? 0,
      invoiceCode: json['maHoaDon'] as String?,
      rentalOrderCode: json['maDonThue'] as String?,
      companyName: json['tenDonVi'] as String?,
      amount: _toDouble(json['soTien']),
      method: json['phuongThuc'] as String? ?? '',
      transactionCode: json['maGiaoDich'] as String?,
      note: json['ghiChu'] as String?,
      paidAt: DateTime.tryParse(json['ngayThanhToan']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
