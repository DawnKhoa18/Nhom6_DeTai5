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
    double totalThue = CartManager.cartItems.fold(0, (sum, item) => sum + (item['price'] ?? item['giaThueNgay'] ?? 0));
    double totalCoc = CartManager.cartItems.fold(0, (sum, item) => sum + (item['tienDatCocDuKien'] ?? ((item['price'] ?? 0) * 10))); // Dự phòng tính toán

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
}