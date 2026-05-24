import 'package:flutter/material.dart';

class RentalOrdersScreen extends StatefulWidget {
  const RentalOrdersScreen({super.key});

  @override
  State<RentalOrdersScreen> createState() => _RentalOrdersScreenState();
}

class _RentalOrdersScreenState extends State<RentalOrdersScreen> {
  String selectedStatus = "Chờ duyệt";

  final List<Map<String, dynamic>> orders = [
    {
      "company": "Công ty ABC",
      "devices": [
        "Laptop Asus TUF Gaming F16",
        "Laptop Lenovo Legion 5",
      ], // Cập nhật tên máy giống ảnh mẫu
      "date": "01/05 - 10/05",
      "total": "5.000.000",
      "status": "Chờ duyệt",
    },
    {
      "company": "Công ty FPT",
      "devices": ["Thinkpad X1"],
      "date": "05/05 - 12/05",
      "total": "3.500.000",
      "status": "Đang thuê",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF9F8FD,
      ), // Nền tím nhạt thanh lịch giống ảnh mẫu
      appBar: AppBar(
        title: const Text(
          "Quản lý đơn thuê",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
      ),
      body: Column(
        children: [
          /// FILTER
          Container(
            color: Colors.white,
            height: 56,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _filter("Chờ duyệt"),
                _filter("Đang thuê"),
                _filter("Hoàn thành"),
                _filter("Quá hạn"),
              ],
            ),
          ),

          /// LIST
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: orders
                  .where((e) => e["status"] == selectedStatus)
                  .map((e) => _orderCard(e))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// FILTER BUTTON
  Widget _filter(String text) {
    final bool isSelected = selectedStatus == text;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedStatus = text;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFF1F2)
              : Colors.transparent, // Nền hồng nhạt khi select (hoặc tùy biến)
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? Border.all(color: Colors.transparent)
              : Border.all(color: Colors.transparent),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  /// CARD
  Widget _orderCard(Map order) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OrderDetailScreen(order)),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 14),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ), // Bo góc tròn mịn như ảnh
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order["company"],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  _status(order["status"]),
                ],
              ),

              const SizedBox(height: 12),

              const Text(
                "Danh sách máy",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),

              // Chỉnh sửa: Hiện danh sách máy dạng text thuần không có dấu chấm tròn
              ...order["devices"]
                  .map<Widget>(
                    (d) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      child: Text(
                        d,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  )
                  .toList(),

              const SizedBox(height: 8),

              Text(
                "Ngày thuê: ${order["date"]}",
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                "Tổng tiền: ${order["total"]} đ",
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),

              const SizedBox(height: 14),

              // Hàng nút bấm bo góc đồng đều sát nhau tương tự ảnh mẫu
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 38,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFFFF4D4F,
                          ), // Màu đỏ nút Duyệt
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => _approve(order),
                        child: const Text(
                          "Duyệt",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 38,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFFFAAD14,
                          ), // Màu cam nút Thu hồi
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => _return(order),
                        child: const Text(
                          "Thu hồi",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 38,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFF52C41A,
                          ), // Màu xanh lá nút Biên bản
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Xuất biên bản")),
                          );
                        },
                        child: const Text(
                          "Biên bản",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// APPROVE
  void _approve(Map order) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Duyệt đơn"),
        content: const Text("Bạn có muốn duyệt đơn này không?"),
        actions: [
          TextButton(
            child: const Text("Hủy"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Duyệt"),
            onPressed: () {
              setState(() {
                order["status"] = "Đang thuê";
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  /// RETURN
  void _return(Map order) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Thu hồi máy"),
        content: const Text("Xác nhận đã thu hồi máy?"),
        actions: [
          TextButton(
            child: const Text("Hủy"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Xác nhận"),
            onPressed: () {
              setState(() {
                order["status"] = "Hoàn thành";
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _status(String s) {
    Color color = Colors.grey;
    if (s == "Chờ duyệt") color = const Color(0xFFFAAD14);
    if (s == "Đang thuê") color = const Color(0xFF1890FF);
    if (s == "Hoàn thành") color = const Color(0xFF52C41A);
    if (s == "Quá hạn") color = const Color(0xFFFF4D4F);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        s,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// DETAIL SCREEN
class OrderDetailScreen extends StatelessWidget {
  final Map order;

  const OrderDetailScreen(this.order, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chi tiết đơn thuê")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Đơn vị: ${order["company"]}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Thiết bị:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...order["devices"].map<Widget>((e) => Text("• $e")).toList(),
            const SizedBox(height: 10),
            Text("Thời gian: ${order["date"]}"),
            const SizedBox(height: 10),
            Text(
              "Tổng tiền: ${order["total"]} đ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
