import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:nhom6_detai5_doancuoiki/services/api_config.dart';
import 'package:nhom6_detai5_doancuoiki/services/auth_service.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});
  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  List<dynamic> _orders = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/user/UserOrders/my-orders/${SessionManager.userId}'));
    if (!mounted) return;
    setState(() {
      _orders = response.statusCode == 200 ? jsonDecode(response.body) as List<dynamic> : [];
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đơn thuê của tôi'), actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded))]),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text('Bạn chưa có đơn thuê.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index] as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(order['maDonThue'] ?? '', style: const TextStyle(fontWeight: FontWeight.w800)),
                        subtitle: Text('Trạng thái: ${order['trangThai']}\nTiền thuê: ${NumberFormat.decimalPattern('vi').format(order['tongTien'])} đ'),
                        isThreeLine: true,
                        trailing: const Icon(Icons.more_vert_rounded),
                        onTap: () => _showActions(order),
                      ),
                    );
                  },
                ),
    );
  }

  void _showActions(Map<String, dynamic> order) {
    final status = order['trangThai'];
    final allowed = status == 'dang_thue' || status == 'qua_han';
    showModalBottomSheet(context: context, builder: (context) => SafeArea(child: Wrap(children: [
      ListTile(leading: const Icon(Icons.update_rounded), title: const Text('Yêu cầu gia hạn'), enabled: allowed, onTap: allowed ? () { Navigator.pop(context); _extend(order['id'] as int); } : null),
      ListTile(leading: const Icon(Icons.assignment_return_rounded), title: const Text('Yêu cầu trả máy'), enabled: allowed, onTap: allowed ? () { Navigator.pop(context); _returnOrder(order['id'] as int); } : null),
    ])));
  }

  Future<void> _extend(int orderId) async {
    final reason = TextEditingController();
    DateTime date = DateTime.now().add(const Duration(days: 7));
    final accepted = await showDialog<bool>(context: context, builder: (context) => StatefulBuilder(builder: (context, update) => AlertDialog(
      title: const Text('Yêu cầu gia hạn'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(title: const Text('Ngày kết thúc mới'), subtitle: Text(DateFormat('dd/MM/yyyy').format(date)), onTap: () async { final value = await showDatePicker(context: context, initialDate: date, firstDate: DateTime.now().add(const Duration(days: 1)), lastDate: DateTime.now().add(const Duration(days: 1095))); if (value != null) update(() => date = value); }),
        TextField(controller: reason, maxLines: 3, decoration: const InputDecoration(labelText: 'Lý do', border: OutlineInputBorder())),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Gửi'))],
    )));
    if (accepted == true) await _post('extend', {'donThueId': orderId, 'ngayKetThucMoi': date.toIso8601String(), 'lyDo': reason.text.trim()});
  }

  Future<void> _returnOrder(int orderId) async {
    final reason = TextEditingController();
    final note = TextEditingController();
    final accepted = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: const Text('Yêu cầu trả máy'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: reason, decoration: const InputDecoration(labelText: 'Lý do', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: note, maxLines: 3, decoration: const InputDecoration(labelText: 'Ghi chú tình trạng máy', border: OutlineInputBorder())),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Gửi'))],
    ));
    if (accepted == true) await _post('return', {'donThueId': orderId, 'lyDo': reason.text.trim(), 'ghiChu': note.text.trim()});
  }

  Future<void> _post(String action, Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse('${ApiConfig.baseUrl}/api/user/UserOrders/$action'), headers: {'Content-Type': 'application/json'}, body: jsonEncode(data));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.statusCode >= 200 && response.statusCode < 300 ? 'Đã gửi yêu cầu.' : response.body)));
    if (response.statusCode >= 200 && response.statusCode < 300) _load();
  }
}
