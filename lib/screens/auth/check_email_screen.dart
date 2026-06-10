import 'package:flutter/material.dart';

class CheckEmailScreen extends StatelessWidget {
  const CheckEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color techBlue = Color(0xFF1E88E5);
    const Color techBlack = Color(0xFF1A1A1A);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: techBlack),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 60),
            // Icon Lá thư xanh lá (giống trong ảnh)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.mark_email_read_outlined,
                color: Colors.green,
                size: 48,
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              "Kiểm tra Email",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: techBlack,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Liên kết đặt lại mật khẩu đã được\ngửi đến Email của bạn.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Chưa nhận được? Hãy kiểm tra thư rác.",
              style: TextStyle(color: Colors.black38, fontSize: 13),
            ),
            const SizedBox(height: 48),
            // Nút Open Email App
            _buildButton(
              label: "Mở ứng dụng Email",
              onPressed: () {},
              isPrimary: true,
              techBlue: techBlue,
            ),
            const SizedBox(height: 16),
            // Nút Resend Link
            _buildButton(
              label: "Gửi lại liên kết",
              onPressed: () {},
              isPrimary: false,
              techBlue: techBlue,
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                // Quay về hẳn màn hình đăng nhập đầu tiên
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text(
                "Quay lại đăng nhập",
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
    required Color techBlue,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? techBlue : const Color(0xFFF5F5F5),
          foregroundColor: isPrimary ? Colors.white : Colors.black87,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
