import 'package:flutter/material.dart';
import 'package:nhom6_detai5_doancuoiki/screens/auth/signUp_screen.dart';
import 'package:nhom6_detai5_doancuoiki/screens/auth/signIn_screen.dart'; // THÊM DÒNG NÀY

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color techBlue = Color(0xFF1E88E5);
    const Color techDarkBlue = Color(0xFF0D47A1);
    const Color techBlack = Color(0xFF1A1A1A);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 300, 
                  height: 230, 
                  child: Image.asset(
                    'assets/images/logoApp.jpg',
                    fit: BoxFit.contain,
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -10),
                  child: const Text(
                    "Chào mừng bạn !",
                    style: TextStyle(
                      color: techBlack,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -10),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    child: Text(
                      "Quản lý, sử dụng và theo dõi.\nBắt đầu trải nghiệm trong hôm nay.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [techBlue, techDarkBlue],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: techBlue.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Bắt đầu ngay",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: techBlue.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: TextButton(
                      onPressed: () {
                        // CHỈNH SỬA: Thêm điều hướng tới trang Sign In
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignInScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Tôi đã có tài khoản",
                        style: TextStyle(
                          color: techDarkBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              "Tiếp tục nghĩa là bạn đồng ý với Điều khoản & Chính sách bảo mật.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black26, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
