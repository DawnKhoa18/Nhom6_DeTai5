import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/equipment_model.dart'; // Thêm dòng import liên quan đến Model

class EquipmentCard extends StatelessWidget {
  final EquipmentModel equipment; // Thay thế các biến dữ liệu bằng Model
  final VoidCallback onDetailsPressed;
  final VoidCallback onAddToCart;

  const EquipmentCard({
    super.key,
    required this.equipment, // Nhận vào duy nhất đối tượng Model cho phần dữ liệu
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
      child: InkWell(
        // CHỈNH SỬA: Bấm vào bất kỳ đâu trên card cũng kích hoạt hàm xem chi tiết
        onTap: onDetailsPressed,
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
                    equipment.imagePath, // Chỉnh sửa liên quan: lấy từ model
                    fit: BoxFit.cover,
                    // Nếu ảnh Lap1.jpg chưa load được, nó sẽ hiện icon màu xám thay vì báo lỗi đỏ
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.laptop_mac,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Sẵn sàng',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
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
                      equipment.name, // Chỉnh sửa liên quan: lấy từ model
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Hiển thị cấu hình: CPU | RAM | SSD
                    Text(
                      '${equipment.cpu} | ${equipment.ram} | ${equipment.ssd}', // Chỉnh sửa liên quan: lấy từ model
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    // Hiển thị cấu hình: Màn hình | GPU
                    Text(
                      '${equipment.display} | ${equipment.gpu}', // Chỉnh sửa liên quan: lấy từ model
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(), // Tự động đẩy phần giá tiền xuống dưới cùng của block này

                    Text(
                      '${formatCurrency.format(equipment.price)} đ/ngày', // Chỉnh sửa liên quan: lấy từ model
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
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 8.0,
              ),
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
                      child: const Text(
                        'Xem chi tiết',
                        style: TextStyle(
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Nút Thêm vào giỏ
                  Container(
                    width: double.infinity,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF1E88E5),
                          Color(0xFF0D47A1),
                        ], // Dải màu từ trang Welcome
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E88E5).withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: onAddToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.add_shopping_cart, size: 16),
                      label: const Text(
                        'Thêm',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
