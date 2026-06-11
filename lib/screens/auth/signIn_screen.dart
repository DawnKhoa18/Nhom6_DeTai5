import 'package:flutter/material.dart';
import 'package:nhom6_detai5_doancuoiki/screens/main_screen.dart'; // CHỈNH SỬA: Import MainScreen để chuyển hướng trang chủ
import 'package:nhom6_detai5_doancuoiki/screens/auth/reset_password_screen.dart';
import 'package:nhom6_detai5_doancuoiki/screens/auth/signUp_screen.dart';
import 'package:nhom6_detai5_doancuoiki/screens/admin/admin_dashboard_screen.dart';
import 'package:nhom6_detai5_doancuoiki/services/auth_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isObscured = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final AuthService _authService = const AuthService();
  bool _isLoading = false;
  String? _error;

  Future<void> _login() async {
    final account = _emailController.text.trim();
    final password = _passController.text;
    if (account.isEmpty || password.isEmpty) {
      setState(() => _error = 'Vui lòng nhập tài khoản và mật khẩu.');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final session = await _authService.login(account: account, password: password);
      if (!mounted) return;
      final destination = session.role == 'admin' || session.role == 'nhan_vien'
          ? const AdminDashboardScreen()
          : const MainScreen();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => destination),
        (_) => false,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = error.toString();
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color techBlue = Color(0xFF1E88E5);
    const Color techDarkBlue = Color(0xFF0D47A1);
    const Color techBlack = Color(0xFF1A1A1A);

    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: techBlue,
          selectionColor: techBlue,
          selectionHandleColor: techBlue,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: techBlack),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            _buildTopButton("Đăng nhập", true, techBlue, techDarkBlue, () {}),
            _buildTopButton("Đăng ký", false, techBlue, techDarkBlue, () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SignUpScreen()),
              );
            }),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Mừng bạn quay lại",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: techBlack,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Đăng nhập để tiếp tục",
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
              const SizedBox(height: 40),
              _buildTextField(
                controller: _emailController,
                hint: "Tên đăng nhập hoặc email",
                icon: Icons.person_outline_rounded,
                cursorColor: techBlue,
              ),
              const SizedBox(height: 16),
              _buildPasswordField(techBlue),

              // CHỖ BẠN CẦN: Liên kết Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ResetPasswordScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Quên mật khẩu?",
                    style: TextStyle(
                      color: techBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              _buildMainButton("Đăng nhập", techBlue, techDarkBlue),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12),
                ),
              ],
              const SizedBox(height: 32),
              const Center(
                child: Text(
                  "hoặc tiếp tục với:",
                  style: TextStyle(color: Colors.black38),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildSocialButton(
                      "Google",
                      Icons.g_mobiledata,
                      Colors.redAccent,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSocialButton(
                      "Apple",
                      Icons.apple,
                      Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              _buildSignUpRedirect(techBlue),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget Helpers để code gọn hơn ---

  Widget _buildTopButton(
    String label,
    bool isActive,
    Color c1,
    Color c2,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isActive ? LinearGradient(colors: [c1, c2]) : null,
          color: isActive ? null : const Color(0xFFF5F5F5),
        ),
        child: TextButton(
          onPressed: onTap,
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(Color cursorColor) {
    return TextField(
      controller: _passController,
      cursorColor: cursorColor,
      obscureText: _isObscured,
      decoration: InputDecoration(
        hintText: "Mật khẩu",
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.black45),
        suffixIcon: IconButton(
          icon: Icon(
            _isObscured
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: Colors.black45,
          ),
          onPressed: () => setState(() => _isObscured = !_isObscured),
        ),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }

  Widget _buildMainButton(String label, Color c1, Color c2) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: [c1, c2]),
        boxShadow: [
          BoxShadow(
            color: c1.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color cursorColor,
  }) {
    return TextField(
      controller: controller,
      cursorColor: cursorColor,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.black45),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }

  Widget _buildSocialButton(String label, IconData icon, Color iconColor) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: iconColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpRedirect(Color techBlue) {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignUpScreen()),
        ),
        child: RichText(
          text: TextSpan(
            text: "Bạn chưa có tài khoản? ",
            style: const TextStyle(color: Colors.black54, fontSize: 15),
            children: [
              TextSpan(
                text: "Đăng ký",
                style: TextStyle(color: techBlue, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
