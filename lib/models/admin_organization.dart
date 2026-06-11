class AdminOrganization {
  final int id;
  final String name;
  final String? address;
  final String? taxCode;
  final String? representative;
  final String? email;
  final String? phone;
  final String status;
  final DateTime? createdAt;
  final int userCount;
  final int orderCount;

  const AdminOrganization({
    required this.id,
    required this.name,
    required this.address,
    required this.taxCode,
    required this.representative,
    required this.email,
    required this.phone,
    required this.status,
    required this.createdAt,
    required this.userCount,
    required this.orderCount,
  });

  bool get isActive => status == 'hoat_dong';
  bool get canDelete => userCount == 0 && orderCount == 0;

  factory AdminOrganization.fromJson(Map<String, dynamic> json) {
    return AdminOrganization(
      id: json['id'] as int? ?? 0,
      name: json['tenDonVi'] as String? ?? '',
      address: json['diaChi'] as String?,
      taxCode: json['maSoThue'] as String?,
      representative: json['nguoiDaiDien'] as String?,
      email: json['email'] as String?,
      phone: json['soDienThoai'] as String?,
      status: json['trangThai'] as String? ?? '',
      createdAt: DateTime.tryParse(json['ngayTao'] as String? ?? ''),
      userCount: json['soNguoiDung'] as int? ?? 0,
      orderCount: json['soDonThue'] as int? ?? 0,
    );
  }
}
