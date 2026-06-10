import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyAssetsScreen extends StatefulWidget {
  const MyAssetsScreen({super.key});

  @override
  State<MyAssetsScreen> createState() => _MyAssetsScreenState();
}

class _MyAssetsScreenState extends State<MyAssetsScreen> {
  final List<Map<String, dynamic>> activeAssets = [
    {"chiTietId": 1, "maTaiSan": "LT-LEN-T14-001", "name": "Lenovo ThinkPad T14", "status": "Hoạt động tốt"},
    {"chiTietId": 2, "maTaiSan": "LT-APP-MBP-001", "name": "Apple MacBook Pro M2", "status": "Hoạt động tốt"},
  ];

  void _openReportDamageSheet(int chiTietId, String name) {
    final moTaController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Báo hỏng máy: $name', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 12),
            TextField(
              controller: moTaController,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Mô tả tình trạng lỗi/hư hỏng thực tế...', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  if (moTaController.text.trim().isEmpty) return;
                  Navigator.pop(context);

                  try {
                    final response = await http.post(
                      Uri.parse('http://10.0.2.2:5135/api/user/UserDamages/report'),
                      headers: {"Content-Type": "application/json"},
                      body: json.encode({
                        "chiTietDonThueId": chiTietId,
                        "nguoiBaoCaoId": 3,
                        "moTa": moTaController.text,
                        "hinhAnhUrl": "assets/images/error_sample.jpg"
                      }),
                    );

                    // FIXED: Kiem tra mounted de xoa canh bao Async Gaps
                    if (!mounted) return;

                    if (response.statusCode == 200) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã gửi báo cáo sự cố! Kỹ thuật viên sẽ liên hệ xử lý.')),
                      );
                    }
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi kết nối server: $e')),
                    );
                  }
                },
                child: const Text('GỬI BÁO CÁO HỎNG', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thiết bị đang sử dụng')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: activeAssets.length,
        itemBuilder: (context, index) {
          final asset = activeAssets[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.computer, color: Colors.teal, size: 36),
              title: Text(asset['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Mã TS: ${asset['maTaiSan']}\nTrạng thái: ${asset['status']}'),
              isThreeLine: true,
              trailing: ElevatedButton.icon(
                // FIXED: Doi Colors.orangeDeep thanh Colors.deepOrange, xoa bot const bi loi constant value
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade100, elevation: 0),
                onPressed: () => _openReportDamageSheet(asset['chiTietId'], asset['name']),
                icon: const Icon(Icons.build, size: 14, color: Colors.deepOrange),
                label: const Text('Báo hỏng', style: TextStyle(color: Colors.deepOrange, fontSize: 12)),
              ),
            ),
          );
        },
      ),
    );
  }
}