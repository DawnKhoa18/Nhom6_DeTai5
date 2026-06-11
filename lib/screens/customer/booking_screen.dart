import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nhom6_detai5_doancuoiki/services/api_config.dart';
import 'package:nhom6_detai5_doancuoiki/services/auth_service.dart';
import 'cart_manager.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _purpose = TextEditingController();
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now().add(const Duration(days: 7));
  bool _saving = false;

  @override
  void dispose() {
    _purpose.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool start) async {
    final value = await showDatePicker(
      context: context,
      initialDate: start ? _start : _end,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 1095)),
    );
    if (value == null) return;
    setState(() {
      if (start) {
        _start = value;
        if (!_end.isAfter(_start)) _end = _start.add(const Duration(days: 1));
      } else {
        _end = value;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (CartManager.cartItems.isEmpty) return;
    final organizationId = SessionManager.organizationId;
    if (organizationId == null || SessionManager.userId <= 0) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phiên đăng nhập không có thông tin đơn vị.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/user/UserOrders/booking'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'donViId': organizationId,
          'nguoiTaoId': SessionManager.userId,
          'ngayBatDau': _start.toIso8601String(),
          'ngayKetThucDuKien': _end.toIso8601String(),
          'mucDichSuDung': _purpose.text.trim(),
          'mayTinhIds': CartManager.cartItems.map((x) => x['id']).toList(),
        }),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(response.body);
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      CartManager.clearCart();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Đã gửi đơn thuê'),
          content: Text('Mã đơn: ${data['code'] ?? ''}'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng'))],
        ),
      );
      if (mounted) Navigator.popUntil(context, (route) => route.isFirst);
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$error')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gửi yêu cầu thuê')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('${CartManager.cartItems.length} thiết bị đã chọn', style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.event_available),
              title: const Text('Ngày bắt đầu'),
              subtitle: Text('${_start.day}/${_start.month}/${_start.year}'),
              onTap: () => _pickDate(true),
            ),
            ListTile(
              leading: const Icon(Icons.event_busy),
              title: const Text('Ngày kết thúc dự kiến'),
              subtitle: Text('${_end.day}/${_end.month}/${_end.year}'),
              onTap: () => _pickDate(false),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _purpose,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Mục đích sử dụng', border: OutlineInputBorder()),
              validator: (value) {
                if ((value ?? '').trim().isEmpty) return 'Vui lòng nhập mục đích sử dụng';
                if (!_end.isAfter(_start)) return 'Ngày kết thúc phải sau ngày bắt đầu';
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _submit,
              icon: const Icon(Icons.send_rounded),
              label: Text(_saving ? 'Đang gửi...' : 'Gửi đơn thuê'),
            ),
          ],
        ),
      ),
    );
  }
}
