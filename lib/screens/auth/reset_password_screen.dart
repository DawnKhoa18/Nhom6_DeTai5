import 'package:flutter/material.dart';
import 'package:nhom6_detai5_doancuoiki/services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _account = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final AuthService _auth = const AuthService();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _account.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_password.text != _confirm.text) {
      setState(() => _error = 'Mật khẩu xác nhận không khớp.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await _auth.resetPassword(
        account: _account.text.trim(),
        email: _email.text.trim(),
        newPassword: _password.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã đặt lại mật khẩu.')),
      );
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đặt lại mật khẩu')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Icon(Icons.lock_reset_rounded, size: 56, color: Color(0xFF1D4ED8)),
            const SizedBox(height: 20),
            const Text(
              'Xác minh tài khoản',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nhập đúng tên đăng nhập và email đã đăng ký để đặt mật khẩu mới.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),
            _field(_account, 'Tên đăng nhập', Icons.person_outline_rounded),
            _field(_email, 'Email', Icons.email_outlined, email: true),
            _field(_password, 'Mật khẩu mới', Icons.lock_outline_rounded, password: true),
            _field(_confirm, 'Xác nhận mật khẩu', Icons.verified_user_outlined, password: true),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Color(0xFFDC2626))),
              const SizedBox(height: 12),
            ],
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: _saving ? null : _submit,
                icon: const Icon(Icons.save_rounded),
                label: Text(_saving ? 'Đang lưu...' : 'Đặt lại mật khẩu'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool password = false,
    bool email = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        obscureText: password,
        keyboardType: email ? TextInputType.emailAddress : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          final text = value?.trim() ?? '';
          if (text.isEmpty) return 'Vui lòng nhập $label.';
          if (password && text.length < 6) return 'Mật khẩu tối thiểu 6 ký tự.';
          if (email && !text.contains('@')) return 'Email không hợp lệ.';
          return null;
        },
      ),
    );
  }
}
