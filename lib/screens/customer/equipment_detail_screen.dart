import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'cart_manager.dart';

class EquipmentDetailScreen extends StatefulWidget {
  final int deviceId;
  const EquipmentDetailScreen({super.key, required this.deviceId});

  @override
  State<EquipmentDetailScreen> createState() => _EquipmentDetailScreenState();
}

class _EquipmentDetailScreenState extends State<EquipmentDetailScreen> {
  Map<String, dynamic>? detail;
  bool isLoading = true;
  final formatCurrency = NumberFormat.decimalPattern('vi');

  @override
  void initState() {
    super.initState();
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:5135/api/user/UserDevices/${widget.deviceId}'));
      if (response.statusCode == 200) {
        setState(() {
          detail = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết cấu hình')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : detail == null
              ? const Center(child: Text('Không tìm thấy thông tin'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset('assets/images/Lap1.jpg', height: 200, width: double.infinity, fit: BoxFit.cover),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(detail!['name'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('Giá thuê: ${formatCurrency.format(detail!['giaThueNgay'])} đ/ngày', style: const TextStyle(fontSize: 16, color: Colors.teal, fontWeight: FontWeight.bold)),
                            Text('Tiền đặt cọc dự kiến: ${formatCurrency.format(detail!['tienDatCocDuKien'])} đ (${detail!['tiLeDatCoc']}%)', style: const TextStyle(fontSize: 14, color: Colors.orange, fontWeight: FontWeight.w500)),
                            const Divider(height: 24),
                            const Text('Thông số kỹ thuật', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            _buildSpecTile(Icons.developer_board, 'Vi xử lý', detail!['cpu']),
                            _buildSpecTile(Icons.memory, 'Bộ nhớ RAM', detail!['ram']),
                            _buildSpecTile(Icons.sd_storage, 'Ổ cứng', detail!['ssd']),
                            _buildSpecTile(Icons.developer_board, 'Card đồ họa', detail!['gpu']),
                            _buildSpecTile(Icons.monitor, 'Màn hình', detail!['display']),
                            _buildSpecTile(Icons.settings, 'Hệ điều hành', detail!['heDieuHanh']),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                                onPressed: () {
                                  CartManager.addToCart(detail!);
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã thêm máy vào giỏ hàng')));
                                },
                                child: const Text('THÊM VÀO GIỎ THUÊ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
    );
  }

  Widget _buildSpecTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black)),
      dense: true,
    );
  }
}