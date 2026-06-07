import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nhom6_detai5_doancuoiki/models/admin_dashboard.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_computer_line.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_damage_level.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_device.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_invoice.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_maintenance.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_payment.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_rental_order.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_user.dart';

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

  Future<void> updateRentalOrderStatus(int orderId, String status) async {
    final uri = Uri.parse('$baseUrl/api/admin/rental-orders/$orderId/status');
    final response = await http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('API ${response.statusCode}: ${response.body}');
    }
  }

  Future<List<AdminUser>> getUsers() async {
    final response = await _get('/api/admin/users');
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.whereType<Map<String, dynamic>>().map(AdminUser.fromJson).toList();
  }

  Future<List<AdminComputerLine>> getComputerLines() async {
    final response = await _get('/api/admin/computer-lines');
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .whereType<Map<String, dynamic>>()
        .map(AdminComputerLine.fromJson)
        .toList();
  }

  Future<List<AdminMaintenance>> getMaintenances() async {
    final response = await _get('/api/admin/maintenances');
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .whereType<Map<String, dynamic>>()
        .map(AdminMaintenance.fromJson)
        .toList();
  }

  Future<void> updateMaintenanceStatus(int maintenanceId, String status) async {
    final uri = Uri.parse('$baseUrl/api/admin/maintenances/$maintenanceId/status');
    final response = await http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('API ${response.statusCode}: ${response.body}');
    }
  }

  Future<void> createMaintenance({
    required int deviceId,
    required DateTime startDate,
    required String content,
    required double cost,
  }) async {
    final uri = Uri.parse('$baseUrl/api/admin/maintenances');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mayTinhId': deviceId,
        'ngayBatDau': startDate.toIso8601String(),
        'noiDung': content,
        'chiPhi': cost,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('API ${response.statusCode}: ${response.body}');
    }
  }

  Future<List<AdminInvoice>> getInvoices() async {
    final response = await _get('/api/admin/invoices');
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .whereType<Map<String, dynamic>>()
        .map(AdminInvoice.fromJson)
        .toList();
  }

  Future<List<AdminPayment>> getPayments() async {
    final response = await _get('/api/admin/payments');
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .whereType<Map<String, dynamic>>()
        .map(AdminPayment.fromJson)
        .toList();
  }

  Future<List<AdminDamageLevel>> getDamageLevels() async {
    final response = await _get('/api/admin/damage-levels');
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .whereType<Map<String, dynamic>>()
        .map(AdminDamageLevel.fromJson)
        .toList();
  }

  Future<void> createPayment({
    required int invoiceId,
    required double amount,
    required String method,
    String? transactionCode,
    String? note,
  }) async {
    final uri = Uri.parse('$baseUrl/api/admin/payments');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'hoaDonId': invoiceId,
        'soTien': amount,
        'phuongThuc': method,
        'maGiaoDich': transactionCode,
        'ghiChu': note,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('API ${response.statusCode}: ${response.body}');
    }
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
