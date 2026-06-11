import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'cart_manager.dart';
import 'booking_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final formatCurrency = NumberFormat.decimalPattern('vi');

  @override
  Widget build(BuildContext context) {
    final totalThue = CartManager.cartItems.fold<double>(
      0,
      (sum, item) =>
          sum + _number(item['price'] ?? item['giaThueNgay']),
    );
    final totalCoc = CartManager.cartItems.fold<double>(
      0,
      (sum, item) => sum + _depositAmount(item),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Giỏ thuê thiết bị')),
      body: CartManager.cartItems.isEmpty
          ? const Center(child: Text('Giỏ hàng trống. Vui lòng quay lại chọn máy.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: CartManager.cartItems.length,
              itemBuilder: (context, index) {
                final item = CartManager.cartItems[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.laptop, color: Colors.teal),
                    title: Text(item['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Thuê: ${formatCurrency.format(item['price'] ?? item['giaThueNgay'])} đ/ngày'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          CartManager.removeFromCart(item['id']);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: CartManager.cartItems.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.black12))),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tổng tiền thuê/ngày:', style: TextStyle(color: Colors.grey)),
                        Text('${formatCurrency.format(totalThue)} đ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tổng tiền đặt cọc:',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          '${formatCurrency.format(totalCoc)} đ',
                          style: const TextStyle(
                            color: Color(0xFFB45309),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const BookingScreen()));
                        },
                        child: const Text('TIẾP TỤC ĐẶT THUÊ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  double _depositAmount(Map<String, dynamic> item) {
    final amount = _number(item['tienDatCocDuKien']);
    if (amount > 0) return amount;

    final machineValue =
        _number(item['machineValue'] ?? item['giaTriMay']);
    final depositRate =
        _number(item['depositRate'] ?? item['tiLeDatCoc']);
    return machineValue * depositRate / 100;
  }

  double _number(dynamic value) => (value as num?)?.toDouble() ?? 0;
}
