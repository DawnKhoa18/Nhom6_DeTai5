import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nguoiDaiDienController = TextEditingController();
  final _phongBanController = TextEditingController();
  final _mucDichController = TextEditingController();

  DateTime _ngayBatDau = DateTime.now();
  DateTime _ngayKetThuc = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = false;

  // Giả lập danh sách ID máy được truyền từ giỏ hàng sang (Ví dụ máy ID 1 và 2)
  final List<int> selectedMachineIds = [1, 2]; 

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Điền IP máy tính hoặc 10.0.2.2 cho máy ảo Android
    const String apiUrl = 'http://10.0.2.2:5135/api/user/UserOrders/booking';

    final Map<String, dynamic> bookingData = {
      "donViId": 1, // Giả lập ID Công ty ABC đã insert ở dữ liệu mẫu
      "nguoiTaoId": 3, // Giả lập ID tài khoản khách hàng Nguyễn Văn An
      "ngayBatDau": _ngayBatDau.toIso8601String(),
      "ngayKetThucDuKien": _ngayKetThuc.toIso8601String(),
      "mucDichSuDung": "${_nguoiDaiDienController.text} - ${_phongBanController.text}: ${_mucDichController.text}",
      "mayTinhIds": selectedMachineIds
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(bookingData),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        _showSuccessDialog(result['code'] ?? 'DT-SUCCESS');
      } else {
        _showSnackBar('Lỗi hệ thống: ${response.body}');
      }
    } catch (e) {
      _showSnackBar('Không thể kết nối đến máy chủ API: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(stringCode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [Icon(Icons.check_circle, color: Colors.green), SizedBox(width: 8), Text('Thành công')],
        ),
        content: Text('Đơn thuê $stringCode đã được gửi lên hệ thống và đang chờ duyệt.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Đóng Dialog
              Navigator.pop(context); // Quay về màn hình trước
            },
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thông tin gửi yêu cầu thuê')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _nguoiDaiDienController,
                    decoration: const InputDecoration(labelText: 'Người đại diện nhận máy', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Vui lòng nhập tên người nhận' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phongBanController,
                    decoration: const InputDecoration(labelText: 'Phòng ban / Đơn vị yêu cầu', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Vui lòng nhập tên phòng ban' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _mucDichController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Mục đích sử dụng thiết bị', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Vui lòng nhập mục đích thuê' : null,
                  ),
                  const SizedBox(height: 24),
                  Card(
                    color: Colors.teal.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.date_range, color: Colors.teal),
                            title: const Text('Ngày bắt đầu thuê'),
                            trailing: Text('${_ngayBatDau.day}/${_ngayBatDau.month}/${_ngayBatDau.year}'),
                          ),
                          ListTile(
                            leading: const Icon(Icons.update, color: Colors.orange),
                            title: const Text('Ngày trả dự kiến'),
                            trailing: Text('${_ngayKetThuc.day}/${_ngayKetThuc.month}/${_ngayKetThuc.year}'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submitBooking,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                      child: const Text('GỬI ĐƠN XÁC NHẬN THUÊ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}