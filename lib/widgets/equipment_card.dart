import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EquipmentCard extends StatelessWidget {
  final int id;
  final String name;
  final double price;
  final String cpu;
  final String ram;
  final String ssd;
  final String gpu;
  final String display;
  final String imagePath;
  final VoidCallback onDetailsPressed;
  final VoidCallback onAddToCart;

  const EquipmentCard({
    super.key,
    required this.id,
    required this.name,
    required this.price,
    required this.cpu,
    required this.ram,
    required this.ssd,
    required this.gpu,
    required this.display,
    required this.imagePath,
    required this.onDetailsPressed,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.decimalPattern('vi');

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 100,
                width: double.infinity,
                child: imagePath.startsWith('http')
                    ? Image.network(imagePath, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.laptop))
                    : Image.asset(imagePath, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.laptop)),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(8)),
                  child: const Text('Sẵn sàng', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('$cpu | $ram | $ssd', style: const TextStyle(fontSize: 10, color: Colors.blueGrey), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(display, style: const TextStyle(fontSize: 10, color: Colors.blueGrey), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const Spacer(),
                  Text('${formatCurrency.format(price)} đ/ngày', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 26,
                  child: TextButton(
                    onPressed: onDetailsPressed,
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: const Text('Xem chi tiết', style: TextStyle(fontSize: 11, decoration: TextDecoration.underline)),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: ElevatedButton.icon(
                    onPressed: onAddToCart,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, padding: EdgeInsets.zero),
                    icon: const Icon(Icons.add_shopping_cart, size: 12, color: Colors.white),
                    label: const Text('Thêm', style: TextStyle(fontSize: 11, color: Colors.white)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}