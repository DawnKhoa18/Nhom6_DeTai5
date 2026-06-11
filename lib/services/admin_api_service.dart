import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nhom6_detai5_doancuoiki/models/admin_dashboard.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_computer_line.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_chat.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_contract.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_damage_level.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_damage_report.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_device.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_device_image.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_extension_request.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_invoice.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_maintenance.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_organization.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_payment.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_rental_order.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_return_request.dart';
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

  Future<void> createUser({
    required String fullName,
    required String username,
    required String password,
    required String role,
    required String status,
    int? organizationId,
    String? email,
    String? phone,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/admin/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'hoTen': fullName,
        'tenDangNhap': username,
        'matKhau': password,
        'vaiTro': role,
        'trangThai': status,
        'donViId': organizationId,
        'email': email,
        'soDienThoai': phone,
      }),
    );
    _throwIfFailed(response);
  }

  Future<void> updateUser({
    required int id,
    required String fullName,
    required String username,
    required String role,
    required String status,
    int? organizationId,
    String? email,
    String? phone,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/admin/users/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'hoTen': fullName,
        'tenDangNhap': username,
        'vaiTro': role,
        'trangThai': status,
        'donViId': organizationId,
        'email': email,
        'soDienThoai': phone,
      }),
    );
    _throwIfFailed(response);
  }

  Future<void> updateUserStatus(int id, String status) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/admin/users/$id/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );
    _throwIfFailed(response);
  }

  Future<int> createDevice({
    required int computerLineId,
    required String assetCode,
    required String type,
    required double originalValue,
    required double dailyRentalPrice,
    required double depositRate,
    required String status,
    String? serialNumber,
    String? cpu,
    String? ram,
    String? storage,
    String? gpu,
    String? screen,
    String? operatingSystem,
    DateTime? importedDate,
    String? note,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/admin/devices'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'dongMayTinhId': computerLineId,
        'maTaiSan': assetCode,
        'serialNumber': serialNumber,
        'loaiMay': type,
        'cpu': cpu,
        'ram': ram,
        'oCung': storage,
        'gpu': gpu,
        'manHinh': screen,
        'heDieuHanh': operatingSystem,
        'giaTriMay': originalValue,
        'giaThueNgay': dailyRentalPrice,
        'tiLeDatCoc': depositRate,
        'tinhTrang': status,
        'ngayNhap': importedDate?.toIso8601String(),
        'ghiChu': note,
      }),
    );
    _throwIfFailed(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['id'] as int? ?? 0;
  }

  Future<void> updateDevice({
    required int id,
    required int computerLineId,
    required String assetCode,
    required String type,
    required double originalValue,
    required double dailyRentalPrice,
    required double depositRate,
    required String status,
    String? serialNumber,
    String? cpu,
    String? ram,
    String? storage,
    String? gpu,
    String? screen,
    String? operatingSystem,
    DateTime? importedDate,
    String? note,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/admin/devices/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'dongMayTinhId': computerLineId,
        'maTaiSan': assetCode,
        'serialNumber': serialNumber,
        'loaiMay': type,
        'cpu': cpu,
        'ram': ram,
        'oCung': storage,
        'gpu': gpu,
        'manHinh': screen,
        'heDieuHanh': operatingSystem,
        'giaTriMay': originalValue,
        'giaThueNgay': dailyRentalPrice,
        'tiLeDatCoc': depositRate,
        'tinhTrang': status,
        'ngayNhap': importedDate?.toIso8601String(),
        'ghiChu': note,
      }),
    );
    _throwIfFailed(response);
  }

  Future<void> deleteDevice(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/api/admin/devices/$id'));
    _throwIfFailed(response);
  }

  Future<List<AdminDeviceImage>> getDeviceImages(int deviceId) async {
    final response = await _get('/api/admin/devices/$deviceId/images');
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .whereType<Map<String, dynamic>>()
        .map(AdminDeviceImage.fromJson)
        .toList();
  }

  Future<void> uploadDeviceImage({
    required int deviceId,
    required String filePath,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/admin/devices/$deviceId/images'),
    );
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    _throwIfFailed(response);
  }

  Future<void> setPrimaryDeviceImage({
    required int deviceId,
    required int imageId,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/admin/devices/$deviceId/images/$imageId/primary'),
    );
    _throwIfFailed(response);
  }

  Future<void> deleteDeviceImage({
    required int deviceId,
    required int imageId,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/admin/devices/$deviceId/images/$imageId'),
    );
    _throwIfFailed(response);
  }

  String resolveFileUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return path.startsWith('/') ? baseUrl + path : '$baseUrl/$path';
  }

  Future<void> createComputerLine({
    required String name,
    required String brand,
    String? description,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/admin/computer-lines'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'tenDong': name,
        'hang': brand,
        'moTa': description,
      }),
    );
    _throwIfFailed(response);
  }

  Future<void> updateComputerLine({
    required int id,
    required String name,
    required String brand,
    String? description,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/admin/computer-lines/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'tenDong': name,
        'hang': brand,
        'moTa': description,
      }),
    );
    _throwIfFailed(response);
  }

  Future<void> deleteComputerLine(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/admin/computer-lines/$id'),
    );
    _throwIfFailed(response);
  }

  Future<List<AdminOrganization>> getOrganizations() async {
    final response = await _get('/api/admin/organizations');
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .whereType<Map<String, dynamic>>()
        .map(AdminOrganization.fromJson)
        .toList();
  }

  Future<void> createOrganization({
    required String name,
    required String status,
    String? address,
    String? taxCode,
    String? representative,
    String? email,
    String? phone,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/admin/organizations'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'tenDonVi': name,
        'diaChi': address,
        'maSoThue': taxCode,
        'nguoiDaiDien': representative,
        'email': email,
        'soDienThoai': phone,
        'trangThai': status,
      }),
    );
    _throwIfFailed(response);
  }

  Future<void> updateOrganization({
    required int id,
    required String name,
    required String status,
    String? address,
    String? taxCode,
    String? representative,
    String? email,
    String? phone,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/admin/organizations/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'tenDonVi': name,
        'diaChi': address,
        'maSoThue': taxCode,
        'nguoiDaiDien': representative,
        'email': email,
        'soDienThoai': phone,
        'trangThai': status,
      }),
    );
    _throwIfFailed(response);
  }

  Future<void> deleteOrganization(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/admin/organizations/$id'),
    );
    _throwIfFailed(response);
  }

  Future<void> createDamageLevel({
    required String name,
    required String description,
    required double compensationPercent,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/admin/damage-levels'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'tenMucDo': name,
        'moTa': description,
        'phanTramDenBu': compensationPercent,
      }),
    );

    _throwIfFailed(response);
  }

  Future<void> updateDamageLevel({
    required int id,
    required String name,
    required String description,
    required double compensationPercent,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/admin/damage-levels/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'tenMucDo': name,
        'moTa': description,
        'phanTramDenBu': compensationPercent,
      }),
    );

    _throwIfFailed(response);
  }

  Future<void> deleteDamageLevel(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/admin/damage-levels/$id'),
    );

    _throwIfFailed(response);
  }

  Future<List<AdminDamageReport>> getDamageReports() async {
    final response = await _get('/api/admin/damage-reports');
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .whereType<Map<String, dynamic>>()
        .map(AdminDamageReport.fromJson)
        .toList();
  }

  Future<void> resolveDamageReport({
    required int id,
    required String status,
    int? damageLevelId,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/admin/damage-reports/$id/resolve'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'status': status,
        'mucDoHuHongId': damageLevelId,
      }),
    );

    _throwIfFailed(response);
  }

  Future<List<AdminReturnRequest>> getReturnRequests() async {
    final response = await _get('/api/admin/return-requests');
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .whereType<Map<String, dynamic>>()
        .map(AdminReturnRequest.fromJson)
        .toList();
  }

  Future<void> resolveReturnRequest({
    required int id,
    required String status,
    String? returnCondition,
    int? processorId,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/admin/return-requests/$id/resolve'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'status': status,
        'tinhTrangTraMay': returnCondition,
        'nguoiXuLyId': processorId,
      }),
    );

    _throwIfFailed(response);
  }

  Future<List<AdminExtensionRequest>> getExtensionRequests() async {
    final response = await _get('/api/admin/extension-requests');
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .whereType<Map<String, dynamic>>()
        .map(AdminExtensionRequest.fromJson)
        .toList();
  }

  Future<void> resolveExtensionRequest({
    required int id,
    required String status,
    int? approverId,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/admin/extension-requests/$id/resolve'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'status': status,
        'nguoiDuyetId': approverId,
      }),
    );

    _throwIfFailed(response);
  }

  Future<List<AdminContract>> getContracts() async {
    final response = await _get('/api/admin/contracts');
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .whereType<Map<String, dynamic>>()
        .map(AdminContract.fromJson)
        .toList();
  }

  Future<void> createContract({
    required int rentalOrderId,
    required String code,
    required DateTime createdDate,
    String? content,
    String? fileUrl,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/admin/contracts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'donThueId': rentalOrderId,
        'maHopDong': code,
        'ngayLap': createdDate.toIso8601String(),
        'noiDung': content,
        'fileUrl': fileUrl,
      }),
    );
    _throwIfFailed(response);
  }

  Future<void> updateContractStatus(int id, String status) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/admin/contracts/$id/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );
    _throwIfFailed(response);
  }

  Future<List<AdminChatConversation>> getChats() async {
    final response = await _get('/api/admin/chats');
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .whereType<Map<String, dynamic>>()
        .map(AdminChatConversation.fromJson)
        .toList();
  }

  Future<List<AdminChatMessage>> getChatMessages(int chatId) async {
    final response = await _get('/api/admin/chats/$chatId/messages');
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .whereType<Map<String, dynamic>>()
        .map(AdminChatMessage.fromJson)
        .toList();
  }

  Future<void> sendChatMessage({
    required int chatId,
    required int senderId,
    required String content,
    String type = 'text',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/admin/chats/$chatId/messages'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nguoiGuiId': senderId,
        'noiDung': content,
        'loaiTinNhan': type,
      }),
    );
    _throwIfFailed(response);
  }

  Future<void> updateChat({
    required int chatId,
    required String status,
    int? staffId,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/admin/chats/$chatId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'status': status,
        'nhanVienPhuTrachId': staffId,
      }),
    );
    _throwIfFailed(response);
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

  void _throwIfFailed(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('API ${response.statusCode}: ${response.body}');
    }
  }
}
