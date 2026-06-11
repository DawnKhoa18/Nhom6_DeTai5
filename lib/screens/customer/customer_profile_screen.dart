import 'package:flutter/material.dart';
import 'package:nhom6_detai5_doancuoiki/screens/auth/welcome_screen.dart';
import 'package:nhom6_detai5_doancuoiki/services/auth_service.dart';
import 'package:nhom6_detai5_doancuoiki/widgets/password_dialogs.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final _auth = const AuthService();
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();

  CustomerProfile? _profile;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _fullName.dispose();
    _username.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile = await _auth.getCustomerProfile(SessionManager.userId);
      if (!mounted) return;
      _profile = profile;
      _fullName.text = profile.fullName;
      _username.text = profile.username;
      _email.text = profile.email ?? '';
      _phone.text = profile.phone ?? '';
      setState(() => _loading = false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final profile = await _auth.updateCustomerProfile(
        userId: SessionManager.userId,
        fullName: _fullName.text.trim(),
        username: _username.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật thông tin cá nhân.')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = error.toString();
      });
    }
  }

  void _logout() {
    SessionManager.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      appBar: AppBar(
        title: const Text('Tài khoản'),
        backgroundColor: const Color(0xFFF3F7FB),
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            onPressed: _loading ? null : _loadProfile,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _profile == null
              ? _ErrorState(message: _error, onRetry: _loadProfile)
              : RefreshIndicator(
                  onRefresh: _loadProfile,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                    children: [
                      _ProfileHeader(profile: _profile!),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Thông tin cá nhân',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _field(
                                controller: _fullName,
                                label: 'Họ và tên',
                                icon: Icons.badge_outlined,
                                validator: _required,
                              ),
                              const SizedBox(height: 12),
                              _field(
                                controller: _username,
                                label: 'Tên đăng nhập',
                                icon: Icons.alternate_email_rounded,
                                validator: _required,
                              ),
                              const SizedBox(height: 12),
                              _field(
                                controller: _email,
                                label: 'Email',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  final text = value?.trim() ?? '';
                                  if (text.isNotEmpty && !text.contains('@')) {
                                    return 'Email chưa đúng định dạng.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              _field(
                                controller: _phone,
                                label: 'Số điện thoại',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                              ),
                              if (_error != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  _error!,
                                  style: const TextStyle(
                                    color: Color(0xFFDC2626),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: _saving ? null : _save,
                                  icon: _saving
                                      ? const SizedBox.square(
                                          dimension: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.save_outlined),
                                  label: Text(
                                    _saving ? 'Đang lưu...' : 'Lưu thay đổi',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.lock_outline_rounded),
                              title: const Text('Đổi mật khẩu'),
                              trailing:
                                  const Icon(Icons.chevron_right_rounded),
                              onTap: () async {
                                final changed =
                                    await showChangePasswordDialog(context);
                                if (changed && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Đã đổi mật khẩu.'),
                                    ),
                                  );
                                }
                              },
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(
                                Icons.logout_rounded,
                                color: Color(0xFFDC2626),
                              ),
                              title: const Text(
                                'Đăng xuất',
                                style: TextStyle(color: Color(0xFFDC2626)),
                              ),
                              onTap: _logout,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  TextFormField _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }

  String? _required(String? value) =>
      (value?.trim().isEmpty ?? true) ? 'Không được để trống.' : null;
}

class _ProfileHeader extends StatelessWidget {
  final CustomerProfile profile;

  const _ProfileHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    final initial = profile.fullName.trim().isEmpty
        ? '?'
        : profile.fullName.trim()[0].toUpperCase();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F766E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Text(
              initial,
              style: const TextStyle(
                color: Color(0xFF0F766E),
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.organizationName ?? 'Chưa có đơn vị thuê',
                  style: const TextStyle(color: Color(0xFFD1FAE5)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 48),
            const SizedBox(height: 12),
            Text(message ?? 'Không tải được thông tin cá nhân.'),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
