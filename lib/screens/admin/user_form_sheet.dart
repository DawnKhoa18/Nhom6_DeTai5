import 'package:flutter/material.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_organization.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_user.dart';
import 'package:nhom6_detai5_doancuoiki/services/admin_api_service.dart';

class UserFormSheet extends StatefulWidget {
  final AdminApiService api;
  final AdminUser? user;
  final VoidCallback onSaved;

  const UserFormSheet({
    super.key,
    required this.api,
    required this.user,
    required this.onSaved,
  });

  @override
  State<UserFormSheet> createState() => _UserFormSheetState();
}

class _UserFormSheetState extends State<UserFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late Future<List<AdminOrganization>> _organizationsFuture;
  late final TextEditingController _fullName;
  late final TextEditingController _username;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _password;
  late String _role;
  late String _status;
  int? _organizationId;
  bool _hidePassword = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _organizationsFuture = widget.api.getOrganizations();
    _fullName = TextEditingController(text: user?.fullName ?? '');
    _username = TextEditingController(text: user?.username ?? '');
    _email = TextEditingController(text: user?.email ?? '');
    _phone = TextEditingController(text: user?.phone ?? '');
    _password = TextEditingController();
    _role = user?.role ?? 'khach_hang';
    _status = user?.status ?? 'hoat_dong';
    _organizationId = user?.companyId;
  }

  @override
  void dispose() {
    _fullName.dispose();
    _username.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  String? _optional(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_role == 'khach_hang' && _organizationId == null) {
      setState(() => _error = 'Khách hàng phải thuộc một đơn vị.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final user = widget.user;
      if (user == null) {
        await widget.api.createUser(
          fullName: _fullName.text.trim(),
          username: _username.text.trim(),
          password: _password.text,
          role: _role,
          status: _status,
          organizationId: _role == 'khach_hang' ? _organizationId : null,
          email: _optional(_email),
          phone: _optional(_phone),
        );
      } else {
        await widget.api.updateUser(
          id: user.id,
          fullName: _fullName.text.trim(),
          username: _username.text.trim(),
          role: _role,
          status: _status,
          organizationId: _role == 'khach_hang' ? _organizationId : null,
          email: _optional(_email),
          phone: _optional(_phone),
        );
      }
      if (mounted) widget.onSaved();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.user == null ? 'Thêm tài khoản' : 'Sửa tài khoản',
                      style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Đóng',
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _field(_fullName, 'Họ tên *', Icons.person_outline_rounded, required: true),
              _field(_username, 'Tên đăng nhập *', Icons.alternate_email_rounded, required: true),
              if (widget.user == null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 13),
                  child: TextFormField(
                    controller: _password,
                    obscureText: _hidePassword,
                    validator: (value) => value == null || value.length < 6
                        ? 'Mật khẩu tạm phải có ít nhất 6 ký tự.'
                        : null,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu tạm *',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        tooltip: _hidePassword ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
                        onPressed: () => setState(() => _hidePassword = !_hidePassword),
                        icon: Icon(_hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              _field(_email, 'Email', Icons.email_outlined, validator: (value) {
                if (value != null && value.trim().isNotEmpty && !value.contains('@')) {
                  return 'Email chưa đúng định dạng.';
                }
                return null;
              }),
              _field(_phone, 'Số điện thoại', Icons.phone_outlined, keyboardType: TextInputType.phone),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(
                  labelText: 'Vai trò',
                  prefixIcon: Icon(Icons.manage_accounts_outlined),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'nhan_vien', child: Text('Nhân viên')),
                  DropdownMenuItem(value: 'khach_hang', child: Text('Khách hàng')),
                ],
                onChanged: _saving ? null : (value) => setState(() {
                  _role = value!;
                  if (_role != 'khach_hang') _organizationId = null;
                }),
              ),
              const SizedBox(height: 13),
              if (_role == 'khach_hang') ...[
                FutureBuilder<List<AdminOrganization>>(
                  future: _organizationsFuture,
                  builder: (context, snapshot) {
                    final organizations = (snapshot.data ?? const [])
                        .where((item) => item.isActive)
                        .toList();
                    return DropdownButtonFormField<int>(
                      value: organizations.any((item) => item.id == _organizationId)
                          ? _organizationId
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Đơn vị *',
                        prefixIcon: Icon(Icons.business_outlined),
                        border: OutlineInputBorder(),
                      ),
                      items: organizations
                          .map((item) => DropdownMenuItem(value: item.id, child: Text(item.name)))
                          .toList(),
                      onChanged: _saving ? null : (value) => setState(() => _organizationId = value),
                    );
                  },
                ),
                const SizedBox(height: 13),
              ],
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Trạng thái',
                  prefixIcon: Icon(Icons.toggle_on_outlined),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'hoat_dong', child: Text('Hoạt động')),
                  DropdownMenuItem(value: 'tam_khoa', child: Text('Tạm khóa')),
                ],
                onChanged: _saving ? null : (value) => setState(() => _status = value!),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12)),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save_rounded),
                  label: Text(_saving ? 'Đang lưu...' : 'Lưu tài khoản'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool required = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator ??
            (required
                ? (value) => value == null || value.trim().isEmpty
                    ? 'Vui lòng nhập ' + label.replaceAll(' *', '').toLowerCase() + '.'
                    : null
                : null),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
