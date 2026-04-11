import 'package:flutter/material.dart';

class RentalOrdersScreen extends StatefulWidget {
  const RentalOrdersScreen({super.key});

  @override
  State<RentalOrdersScreen> createState() =>
      _RentalOrdersScreenState();
}

class _RentalOrdersScreenState
    extends State<RentalOrdersScreen> {

  String selectedStatus = "Chờ duyệt";

  final List<Map<String, dynamic>> orders = [
    {
      "company": "Công ty ABC",
      "devices": ["Dell XPS", "Macbook Pro"],
      "date": "01/05 - 10/05",
      "total": "5.000.000",
      "status": "Chờ duyệt"
    },
    {
      "company": "Công ty FPT",
      "devices": ["Thinkpad X1"],
      "date": "05/05 - 12/05",
      "total": "3.500.000",
      "status": "Đang thuê"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý đơn thuê"),
        centerTitle: true,
      ),
      body: Column(
        children: [

          /// FILTER
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
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
              padding: const EdgeInsets.all(16),
              children: orders
                  .where((e) =>
                      e["status"] == selectedStatus)
                  .map((e) => _orderCard(e))
                  .toList(),
            ),
          )
        ],
      ),
    );
  }

  /// FILTER BUTTON
  Widget _filter(String text) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedStatus = text;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selectedStatus == text
              ? Colors.blue
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selectedStatus == text
                ? Colors.white
                : Colors.black,
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
          MaterialPageRoute(
            builder: (_) => OrderDetailScreen(order),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [

                  Text(
                    order["company"],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  _status(order["status"])
                ],
              ),

              const SizedBox(height: 8),

              ...order["devices"]
                  .map<Widget>((d) => Text("• $d"))
                  .toList(),

              const SizedBox(height: 8),

              Text("Ngày thuê: ${order["date"]}"),

              Text(
                  "Tổng tiền: ${order["total"]} đ"),

              const SizedBox(height: 10),

              Row(
                children: [

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          _approve(order),
                      child: const Text("Duyệt"),
                    ),
                  ),

                  const SizedBox(width: 5),

                  Expanded(
                    child: ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.orange,
                      ),
                      onPressed: () =>
                          _return(order),
                      child: const Text("Thu hồi"),
                    ),
                  ),

                  const SizedBox(width: 5),

                  Expanded(
                    child: ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.green,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(
                                context)
                            .showSnackBar(
                          const SnackBar(
                              content: Text(
                                  "Xuất biên bản")),
                        );
                      },
                      child:
                          const Text("Biên bản"),
                    ),
                  ),

                ],
              )
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
        content: const Text(
            "Bạn có muốn duyệt đơn này không?"),
        actions: [

          TextButton(
            child: const Text("Hủy"),
            onPressed: () =>
                Navigator.pop(context),
          ),

          ElevatedButton(
            child: const Text("Duyệt"),
            onPressed: () {
              setState(() {
                order["status"] = "Đang thuê";
              });
              Navigator.pop(context);
            },
          )

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
        content: const Text(
            "Xác nhận đã thu hồi máy?"),
        actions: [

          TextButton(
            child: const Text("Hủy"),
            onPressed: () =>
                Navigator.pop(context),
          ),

          ElevatedButton(
            child: const Text("Xác nhận"),
            onPressed: () {
              setState(() {
                order["status"] =
                    "Hoàn thành";
              });
              Navigator.pop(context);
            },
          )

        ],
      ),
    );
  }

  Widget _status(String s) {
    Color color = Colors.grey;

    if (s == "Chờ duyệt") color = Colors.orange;
    if (s == "Đang thuê") color = Colors.blue;
    if (s == "Hoàn thành") color = Colors.green;
    if (s == "Quá hạn") color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Text(
        s,
        style: const TextStyle(
            color: Colors.white),
      ),
    );
  }
}

/// DETAIL SCREEN
class OrderDetailScreen extends StatelessWidget {
  final Map order;

  const OrderDetailScreen(this.order,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi tiết đơn thuê"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            Text("Đơn vị: ${order["company"]}",
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold)),

            const SizedBox(height: 10),

            const Text("Thiết bị:",
                style: TextStyle(
                    fontWeight:
                        FontWeight.bold)),

            ...order["devices"]
                .map<Widget>((e) =>
                    Text("• $e"))
                .toList(),

            const SizedBox(height: 10),

            Text("Thời gian: ${order["date"]}"),

            const SizedBox(height: 10),

            Text(
              "Tổng tiền: ${order["total"]} đ",
              style: const TextStyle(
                  fontWeight:
                      FontWeight.bold),
            ),

          ],
        ),
      ),
    );
  }
}