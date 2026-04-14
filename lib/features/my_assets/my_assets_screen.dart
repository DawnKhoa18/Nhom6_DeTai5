import 'package:flutter/material.dart';

class MyAssetsScreen extends StatefulWidget {
  const MyAssetsScreen({super.key});

  @override
  State<MyAssetsScreen> createState() => _MyAssetsScreenState();
}

class _MyAssetsScreenState extends State<MyAssetsScreen> {
  // Hàm hiển thị Popup báo hỏng từ dưới lên (BottomSheet)
  void _showReportIssueSheet(BuildContext context, String assetName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // Đẩy lên khi bàn phím mở
            left: 16, right: 16, top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Báo hỏng thiết bị: $assetName', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Mô tả chi tiết lỗi bạn đang gặp phải...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // Đóng popup
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã gửi yêu cầu hỗ trợ thành công!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.send),
                  label: const Text('Gửi yêu cầu hỗ trợ'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  // Widget dùng chung để build danh sách máy theo trạng thái
  Widget _buildAssetList(String statusFilter) {
    // Dữ liệu giả lập
    final items = [
      {'name': 'Dell UltraSharp 27"', 'status': 'Hoạt động tốt', 'date': '10/04/2026 - 10/10/2026'},
      {'name': 'Bàn phím cơ Keychron', 'status': 'Đang báo hỏng', 'date': '15/03/2026 - 15/09/2026'},
      {'name': 'Mac mini M2', 'status': 'Hoạt động tốt', 'date': '01/01/2026 - 31/12/2026'},
    ];

    final filteredItems = statusFilter == 'Tất cả'
        ? items
        : items.where((i) => i['status'] == statusFilter).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        final isBroken = item['status'] == 'Đang báo hỏng';

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item['name']!,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isBroken ? Colors.red.shade100 : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item['status']!,
                        style: TextStyle(
                          color: isBroken ? Colors.red.shade700 : Colors.green.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.date_range, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text('Thời hạn: ${item['date']}', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: isBroken
                      ? const Text('Đang chờ IT xử lý...', style: TextStyle(color: Colors.orange, fontStyle: FontStyle.italic))
                      : OutlinedButton.icon(
                          onPressed: () => _showReportIssueSheet(context, item['name']!),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent),
                          ),
                          icon: const Icon(Icons.build_circle_outlined),
                          label: const Text('Báo hỏng'),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Máy đang sử dụng', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: Colors.teal,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.teal,
            tabs: [
              Tab(text: 'Tất cả'),
              Tab(text: 'Hoạt động tốt'),
              Tab(text: 'Đang báo hỏng'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAssetList('Tất cả'),
            _buildAssetList('Hoạt động tốt'),
            _buildAssetList('Đang báo hỏng'),
          ],
        ),
      ),
    );
  }
}