import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nhom6_detai5_doancuoiki/models/auth_session.dart';
import 'package:nhom6_detai5_doancuoiki/services/api_config.dart';

class AuthService {
  const AuthService();

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
}

class SessionManager {
  static AuthSession? _session;

  static AuthSession? get current => _session;
  static String? get token => _session?.token;
  static String get role => _session?.role ?? '';
  static bool get isAdmin => role == 'admin';
  static bool get isStaff => role == 'nhan_vien';

  static void setSession(AuthSession session) {
    _session = session;
  }

  static void clear() {
    _session = null;
  }
}
