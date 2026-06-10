import 'package:flutter/material.dart';

class EquipmentDetailScreen extends StatelessWidget {
  const EquipmentDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Đồng bộ dải màu xanh công nghệ từ màn hình SignIn
    const Color techBlue = Color(0xFF1E88E5);
    const Color techDarkBlue = Color(0xFF0D47A1);
    const Color techBlack = Color(0xFF1A1A1A);
    const Color bgLightGreen = Color(
      0xFFF7FBF9,
    ); // Màu nền hơi hướng xanh nhẹ như hình

    return Scaffold(
      backgroundColor: bgLightGreen,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: techBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chi tiết thiết bị',
          style: TextStyle(
            color: techBlack,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Hình ảnh thiết bị lớn ở trên cùng (Đã sửa lỗi fit nằm sai vị trí)
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      height: 220,
                      child: Image.network(
                        'https://images.unsplash.com/photo-1603302576837-37561b2e2302?w=500',
                        fit: BoxFit
                            .contain, // Đã chuyển fit vào bên trong Image.network chuẩn chỉnh
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(color: techBlue),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.laptop,
                              size: 150,
                              color: Colors.grey,
                            ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 2. Tên thiết bị và Giá thuê
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text(
                          'ThinkPad T14 Gen 3',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: techBlack,
                          ),
                        ),
                      ),
                      const Text(
                        '150.000 đ',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  const Divider(thickness: 1, color: Colors.black12),
                  const SizedBox(height: 16),

                  // 3. Tiêu đề "Cấu hình chi tiết"
                  const Text(
                    'Cấu hình chi tiết',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: techBlack,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4. Danh sách các thông số cấu hình giống hình mẫu
                  _buildConfigItem(
                    Icons.badge_outlined,
                    'Vi xử lý (CPU)',
                    'Core i7-12700H',
                    techBlue,
                  ),
                  _buildConfigItem(
                    Icons.memory,
                    'Bộ nhớ (RAM)',
                    '16GB',
                    techBlue,
                  ),
                  _buildConfigItem(
                    Icons.sd_card_outlined,
                    'Ổ cứng (SSD)',
                    '512GB SSD',
                    techBlue,
                  ),
                  _buildConfigItem(
                    Icons.monitor,
                    'Màn hình',
                    '14" FHD+',
                    techBlue,
                  ),
                  _buildConfigItem(
                    Icons.developer_board_outlined,
                    'Card đồ họa (GPU)',
                    'Iris Xe',
                    techBlue,
                  ),
                ],
              ),
            ),
          ),

          // 5. Nút bấm "THUÊ THIẾT BỊ NÀY" cố định ở dưới đáy với hiệu ứng Gradient đồng bộ app
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [techBlue, techDarkBlue],
                ),
                boxShadow: [
                  BoxShadow(
                    color: techBlue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  // Xử lý logic khi bấm nút thuê ở đây nha bồ
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'THUÊ THIẾT BỊ NÀY',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget con để build từng hàng thông số cấu hình mượt mà, đúng hàng đúng lối
  Widget _buildConfigItem(
    IconData icon,
    String title,
    String value,
    Color iconColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black12, width: 0.5),
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
