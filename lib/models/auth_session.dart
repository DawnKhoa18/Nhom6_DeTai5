class AuthSession {
  final int userId;
  final int? organizationId;
  final String fullName;
  final String username;
  final String role;
  final String token;

  const AuthSession({
    required this.userId,
    required this.organizationId,
    required this.fullName,
    required this.username,
    required this.role,
    required this.token,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      userId: json['userId'] as int? ?? 0,
      organizationId: json['donViId'] as int?,
      fullName: json['hoTen'] as String? ?? '',
      username: json['tenDangNhap'] as String? ?? '',
      role: json['vaiTro'] as String? ?? '',
      token: json['token'] as String? ?? '',
    );
  }
}
