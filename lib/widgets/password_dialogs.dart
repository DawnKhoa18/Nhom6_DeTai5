import 'package:flutter/material.dart';
import 'package:nhom6_detai5_doancuoiki/services/admin_api_service.dart';
import 'package:nhom6_detai5_doancuoiki/services/auth_service.dart';

Future<bool> showChangePasswordDialog(BuildContext context) async {
  final current = TextEditingController();
  final next = TextEditingController();
  final confirm = TextEditingController();
  final formKey = GlobalKey<FormState>();
  var saving = false;
  String? error;

  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Đổi mật khẩu'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _passwordField(current, 'Mật khẩu hiện tại'),
              const SizedBox(height: 12),
              _passwordField(next, 'Mật khẩu mới'),
              const SizedBox(height: 12),
              _passwordField(confirm, 'Xác nhận mật khẩu'),
              if (error != null) ...[
                const SizedBox(height: 10),
                Text(error!, style: const TextStyle(color: Color(0xFFDC2626))),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: saving ? null : () => Navigator.pop(dialogContext, false),
            child: const Text('Đóng'),
          ),
          FilledButton(
            onPressed: saving
                ? null
                : () async {
                    if (!formKey.currentState!.validate()) return;
                    if (next.text != confirm.text) {
                      setState(() => error = 'Mật khẩu xác nhận không khớp.');
                      return;
                    }
                    setState(() {
                      saving = true;
                      error = null;
                    });
                    try {
                      await const AuthService().changePassword(
                        currentPassword: current.text,
                        newPassword: next.text,
                      );
                      if (dialogContext.mounted) Navigator.pop(dialogContext, true);
                    } catch (exception) {
                      setState(() {
                        saving = false;
                        error = exception.toString();
                      });
                    }
                  },
            child: Text(saving ? 'Đang lưu...' : 'Đổi mật khẩu'),
          ),
        ],
      ),
    ),
  );

  current.dispose();
  next.dispose();
  confirm.dispose();
  return result == true;
}

Future<bool> showResetUserPasswordDialog(
  BuildContext context, {
  required int userId,
  required String username,
}) async {
  final password = TextEditingController();
  final formKey = GlobalKey<FormState>();
  var saving = false;
  String? error;

  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text('Cấp mật khẩu tạm cho @$username'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _passwordField(password, 'Mật khẩu tạm'),
              if (error != null) ...[
                const SizedBox(height: 10),
                Text(error!, style: const TextStyle(color: Color(0xFFDC2626))),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: saving ? null : () => Navigator.pop(dialogContext, false),
            child: const Text('Đóng'),
          ),
          FilledButton(
            onPressed: saving
                ? null
                : () async {
                    if (!formKey.currentState!.validate()) return;
                    setState(() {
                      saving = true;
                      error = null;
                    });
                    try {
                      await const AdminApiService()
                          .resetUserPassword(userId, password.text);
                      if (dialogContext.mounted) Navigator.pop(dialogContext, true);
                    } catch (exception) {
                      setState(() {
                        saving = false;
                        error = exception.toString();
                      });
                    }
                  },
            child: Text(saving ? 'Đang lưu...' : 'Cấp lại mật khẩu'),
          ),
        ],
      ),
    ),
  );

  password.dispose();
  return result == true;
}

TextFormField _passwordField(TextEditingController controller, String label) {
  return TextFormField(
    controller: controller,
    obscureText: true,
    decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
    validator: (value) => (value?.length ?? 0) < 6
        ? 'Mật khẩu phải có ít nhất 6 ký tự.'
        : null,
  );
}
