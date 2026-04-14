import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EquipmentCard extends StatelessWidget {
  final String name;
  final double price;
  final String cpu;
  final String ram;
  final String ssd;
  final String display;
  final String gpu;
  final String imagePath;
  final VoidCallback onDetailsPressed;
  final VoidCallback onAddToCart;

  const EquipmentCard({
    super.key,
    required this.name,
    required this.price,
    required this.cpu,
    required this.ram,
    required this.ssd,
    required this.display,
    required this.gpu,
    required this.imagePath,
    required this.onDetailsPressed,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.decimalPattern('vi');

    return Card(
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hình ảnh thật + Badge Trạng thái
          Stack(
            children: [
              SizedBox(
                height: 110,
                width: double.infinity,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  // Nếu ảnh Lap1.jpg chưa load được, nó sẽ hiện icon màu xám thay vì báo lỗi đỏ
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.laptop_mac, size: 40, color: Colors.grey),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Sẵn sàng',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          
          // Phần thông tin thiết bị (Dùng Expanded để không bao giờ bị tràn pixel)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  
                  // Hiển thị cấu hình: CPU | RAM | SSD
                  Text(
                    '$cpu | $ram | $ssd',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  
                  // Hiển thị cấu hình: Màn hình | GPU
                  Text(
                    '$display | $gpu',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const Spacer(), // Tự động đẩy phần giá tiền xuống dưới cùng của block này
                  
                  Text(
                    '${formatCurrency.format(price)} đ/ngày',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Hai nút chức năng ở dưới đáy Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
            child: Column(
              children: [
                // Nút Xem chi tiết
                SizedBox(
                  width: double.infinity,
                  height: 28,
                  child: TextButton(
                    onPressed: onDetailsPressed,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: Colors.grey.shade800,
                    ),
                    child: const Text('Xem chi tiết', style: TextStyle(fontSize: 12, decoration: TextDecoration.underline)),
                  ),
                ),
                const SizedBox(height: 4),
                // Nút Thêm vào giỏ
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: ElevatedButton.icon(
                    onPressed: onAddToCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.add_shopping_cart, size: 16),
                    label: const Text('Thêm', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
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