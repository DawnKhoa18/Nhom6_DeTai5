import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  List<dynamic> orders = [];
  bool isLoading = true;
  final formatCurrency = NumberFormat.decimalPattern('vi');

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      // Khách hàng Nguyễn Văn An có ID = 3 theo DB mẫu anh cung cấp
      final response = await http.get(Uri.parse('http://10.0.2.2:5135/api/user/UserOrders/my-orders/3'));
      if (response.statusCode == 200) {
        setState(() {
          orders = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Đơn thuê của tôi'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Tất cả'),
              Tab(text: 'Chờ duyệt'),
              Tab(text: 'Đang thuê'),
              Tab(text: 'Đã hoàn thành'),
            ],
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.teal))
            : TabBarView(
                children: [
                  _buildOrderList('all'),
                  _buildOrderList('cho_duyet'),
                  _buildOrderList('dang_thue'),
                  _buildOrderList('hoan_thanh'),
                ],
              ),
      ),
    );
  }

  Widget _buildOrderList(String filterStatus) {
    List<dynamic> filtered = [];
    if (filterStatus == 'all') {
      filtered = orders;
    } else {
      filtered = orders.where((o) => o['trangThai'] == filterStatus).toList();
    }

    if (filtered.isEmpty) {
      return const Center(child: Text('Không có đơn hàng nào ở trạng thái này.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final order = filtered[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Mã đơn: ${order['maDonThue']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('${order['trangThai']}'.toUpperCase(), style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const Divider(height: 20),
                Text('Tổng tiền thuê: ${formatCurrency.format(order['tongTien'])} đ'),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade50, elevation: 0),
                      onPressed: () => _showActionSheet(order['id']),
                      child: const Text('Tác vụ nghiệp vụ', style: TextStyle(color: Colors.teal)),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showActionSheet(int orderId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.history, color: Colors.blue),
            title: const Text('Gửi yêu cầu Gia hạn hợp đồng'),
            onTap: () async {
              Navigator.pop(context);
              final response = await http.post(
                Uri.parse('http://10.0.2.2:5135/api/user/UserOrders/extend'),
                headers: {"Content-Type": "application/json"},
                body: json.encode({"donThueId": orderId, "ngayKetThucMoi": "2026-08-30", "lyDo": "Gia hạn chạy tiếp dự án HUIT"}),
              );
              if (response.statusCode == 200) _showSnackbar('Đã gửi yêu cầu gia hạn thuê!');
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment_return, color: Colors.purple),
            title: const Text('Gửi yêu cầu Trả máy thiết bị'),
            onTap: () async {
              Navigator.pop(context);
              final response = await http.post(
                Uri.parse('http://10.0.2.2:5135/api/user/UserOrders/return'),
                headers: {"Content-Type": "application/json"},
                body: json.encode({"donThueId": orderId, "lyDo": "Trả máy hoàn thành dự án sớm", "ghiChu": "Máy đẹp nguyên vẹn"}),
              );
              if (response.statusCode == 200) _showSnackbar('Đã đăng ký lịch hẹn trả máy!');
            },
          ),
        ],
      ),
    );
  }

  void _showSnackbar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}