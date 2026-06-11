import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nhom6_detai5_doancuoiki/services/api_config.dart';
import 'package:nhom6_detai5_doancuoiki/services/auth_service.dart';

class MyAssetsScreen extends StatefulWidget {
  const MyAssetsScreen({super.key});
  @override
  State<MyAssetsScreen> createState() => _MyAssetsScreenState();
}

class _MyAssetsScreenState extends State<MyAssetsScreen> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<dynamic>> _load() async {
    final response = await http.get(Uri.parse(
      '${ApiConfig.baseUrl}/api/user/UserDevices/my-assets/${SessionManager.userId}',
    ));
    if (response.statusCode != 200) throw Exception(response.body);
    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<void> _report(Map<String, dynamic> asset) async {
    final description = TextEditingController();
    final submit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Báo hỏng ${asset['name'] ?? ''}'),
        content: TextField(
          controller: description,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(labelText: 'Mô tả hư hỏng', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Gửi')),
        ],
      ),
    );
    if (submit != true || description.text.trim().isEmpty) return;
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/user/UserDamages/report'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'chiTietDonThueId': asset['chiTietId'],
        'nguoiBaoCaoId': SessionManager.userId,
        'moTa': description.text.trim(),
        'hinhAnhUrl': '',
      }),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(response.statusCode == 200 ? 'Đã gửi báo cáo hư hỏng.' : response.body),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Máy của tôi')),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Không tải được thiết bị: ${snapshot.error}'));
          final assets = snapshot.data ?? const [];
          if (assets.isEmpty) return const Center(child: Text('Bạn chưa có thiết bị đang thuê.'));
          return RefreshIndicator(
            onRefresh: () async => setState(() => _future = _load()),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: assets.length,
              itemBuilder: (context, index) {
                final asset = assets[index] as Map<String, dynamic>;
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.computer_rounded),
                    title: Text(asset['name'] ?? 'Thiết bị'),
                    subtitle: Text('${asset['maTaiSan'] ?? ''}\nĐơn thuê: ${asset['maDonThue'] ?? ''}'),
                    isThreeLine: true,
                    trailing: IconButton(
                      tooltip: 'Báo hỏng',
                      onPressed: () => _report(asset),
                      icon: const Icon(Icons.build_circle_outlined, color: Colors.deepOrange),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
