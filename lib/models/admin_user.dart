class AdminUser {
  final int id;
  final int? companyId;
  final String fullName;
  final String username;
  final String? email;
  final String? phone;
  final String role;
  final String status;
  final DateTime createdAt;
  final String? companyName;

  const AdminUser({
    required this.id,
    required this.companyId,
    required this.fullName,
    required this.username,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    required this.createdAt,
    required this.companyName,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] as int? ?? 0,
      companyId: json['donViId'] as int?,
      fullName: json['hoTen'] as String? ?? '',
      username: json['tenDangNhap'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['soDienThoai'] as String?,
      role: json['vaiTro'] as String? ?? '',
      status: json['trangThai'] as String? ?? '',
      createdAt: DateTime.tryParse(json['ngayTao']?.toString() ?? '') ??
          DateTime.now(),
      companyName: json['tenDonVi'] as String?,
    );
  }
}
