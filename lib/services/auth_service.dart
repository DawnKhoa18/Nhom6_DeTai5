import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nhom6_detai5_doancuoiki/models/auth_session.dart';
import 'package:nhom6_detai5_doancuoiki/services/api_config.dart';

class AuthService {
  const AuthService();

  Future<List<RegistrationOrganization>> getRegistrationOrganizations() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/organizations'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('API ${response.statusCode}: ${response.body}');
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .whereType<Map<String, dynamic>>()
        .map(RegistrationOrganization.fromJson)
        .toList();
  }

  Future<AuthSession> register({
    required String fullName,
    required String username,
    required String email,
    required String password,
    String? phone,
    int? organizationId,
    Map<String, dynamic>? newOrganization,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'hoTen': fullName,
        'tenDangNhap': username,
        'email': email,
        'soDienThoai': phone,
        'matKhau': password,
        'donViId': organizationId,
        'donViMoi': newOrganization,
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('API ${response.statusCode}: ${response.body}');
    }
    final session = AuthSession.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
    SessionManager.setSession(session);
    return session;
  }

  Future<AuthSession> login({
    required String account,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'account': account,
        'password': password,
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('API ${response.statusCode}: ${response.body}');
    }

    final session = AuthSession.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
    SessionManager.setSession(session);
    return session;
  }

  Future<void> resetPassword({
    required String account,
    required String email,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'account': account,
        'email': email,
        'newPassword': newPassword,
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('API ${response.statusCode}: ${response.body}');
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/change-password'),
      headers: {
        'Content-Type': 'application/json',
        if (SessionManager.token != null)
          'Authorization': 'Bearer ${SessionManager.token}',
      },
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('API ${response.statusCode}: ${response.body}');
    }
  }

  Future<CustomerProfile> getCustomerProfile(int userId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/user/profile/$userId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('API ${response.statusCode}: ${response.body}');
    }
    return CustomerProfile.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<CustomerProfile> updateCustomerProfile({
    required int userId,
    required String fullName,
    required String username,
    String? email,
    String? phone,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/user/profile/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'hoTen': fullName,
        'tenDangNhap': username,
        'email': email,
        'soDienThoai': phone,
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('API ${response.statusCode}: ${response.body}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final profile = CustomerProfile.fromJson(
      data['profile'] as Map<String, dynamic>,
    );
    SessionManager.updateIdentity(
      fullName: profile.fullName,
      username: profile.username,
    );
    return profile;
  }
}

class CustomerProfile {
  final int id;
  final int? organizationId;
  final String fullName;
  final String username;
  final String? email;
  final String? phone;
  final String role;
  final String status;
  final String? organizationName;

  const CustomerProfile({
    required this.id,
    required this.organizationId,
    required this.fullName,
    required this.username,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    required this.organizationName,
  });

  factory CustomerProfile.fromJson(Map<String, dynamic> json) {
    return CustomerProfile(
      id: json['id'] as int? ?? 0,
      organizationId: json['donViId'] as int?,
      fullName: json['hoTen'] as String? ?? '',
      username: json['tenDangNhap'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['soDienThoai'] as String?,
      role: json['vaiTro'] as String? ?? '',
      status: json['trangThai'] as String? ?? '',
      organizationName: json['tenDonVi'] as String?,
    );
  }
}

class RegistrationOrganization {
  final int id;
  final String name;
  final String? address;
  final String? taxCode;

  const RegistrationOrganization({
    required this.id,
    required this.name,
    this.address,
    this.taxCode,
  });

  factory RegistrationOrganization.fromJson(Map<String, dynamic> json) {
    return RegistrationOrganization(
      id: json['id'] as int? ?? 0,
      name: json['tenDonVi'] as String? ?? '',
      address: json['diaChi'] as String?,
      taxCode: json['maSoThue'] as String?,
    );
  }
}

class SessionManager {
  static AuthSession? _session;

  static AuthSession? get current => _session;
  static String? get token => _session?.token;
  static int get userId => _session?.userId ?? 0;
  static int? get organizationId => _session?.organizationId;
  static String get role => _session?.role ?? '';
  static bool get isAdmin => role == 'admin';
  static bool get isStaff => role == 'nhan_vien';

  static void setSession(AuthSession session) {
    _session = session;
  }

  static void updateIdentity({
    required String fullName,
    required String username,
  }) {
    final session = _session;
    if (session == null) return;
    _session = AuthSession(
      userId: session.userId,
      organizationId: session.organizationId,
      fullName: fullName,
      username: username,
      role: session.role,
      token: session.token,
    );
  }

  static void clear() {
    _session = null;
  }
}
