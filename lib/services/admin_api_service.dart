import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nhom6_detai5_doancuoiki/models/admin_dashboard.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_device.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_rental_order.dart';

class AdminApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5135',
  );

  const AdminApiService();

  Future<AdminDashboard> getDashboard() async {
    final response = await _get('/api/admin/dashboard');
    return AdminDashboard.fromJson(jsonDecode(response.body));
  }

  Future<List<AdminDevice>> getDevices() async {
    final response = await _get('/api/admin/devices');
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .whereType<Map<String, dynamic>>()
        .map(AdminDevice.fromJson)
        .toList();
  }

  Future<List<AdminRentalOrder>> getRentalOrders() async {
    final response = await _get('/api/admin/rental-orders');
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .whereType<Map<String, dynamic>>()
        .map(AdminRentalOrder.fromJson)
        .toList();
  }

  Future<http.Response> _get(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('API ${response.statusCode}: ${response.body}');
    }

    return response;
  }
}
