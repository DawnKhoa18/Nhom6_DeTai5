import 'package:flutter/material.dart';
import 'package:nhom6_detai5_doancuoiki/screens/auth/signIn_screen.dart';
import 'package:nhom6_detai5_doancuoiki/screens/main_screen.dart';
import 'package:nhom6_detai5_doancuoiki/services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = const AuthService();
  final _fullName = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  final _organizationName = TextEditingController();
  final _organizationAddress = TextEditingController();
  final _taxCode = TextEditingController();
  final _representative = TextEditingController();
  final _organizationEmail = TextEditingController();
  final _organizationPhone = TextEditingController();

  late Future<List<RegistrationOrganization>> _organizationsFuture;
  RegistrationOrganization? _selectedOrganization;
  bool _createOrganization = false;
  bool _obscurePassword = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _organizationsFuture = _authService.getRegistrationOrganizations();
  }

  @override
  void dispose() {
    for (final controller in [
      _fullName,
      _username,
      _email,
      _phone,
      _password,
      _confirmation,
      _organizationName,
      _organizationAddress,
      _taxCode,
      _representative,
      _organizationEmail,
      _organizationPhone,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF1D4ED8);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Đăng ký'),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SignInScreen()),
            ),
            child: const Text('Đăng nhập'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
          children: [
            const Text(
              'Tạo tài khoản khách hàng',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Nhập thông tin cá nhân và đơn vị thuê của bạn.',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),
            _Section(
              title: 'Thông tin tài khoản',
              children: [
                _field(_fullName, 'Họ và tên', Icons.person_outline,
                    isRequired: true),
                _field(_username, 'Tên đăng nhập', Icons.badge_outlined,
                    isRequired: true),
                _field(_email, 'Email', Icons.email_outlined,
                    isRequired: true, email: true),
                _field(_phone, 'Số điện thoại', Icons.phone_outlined,
                    keyboardType: TextInputType.phone),
                TextFormField(
                  controller: _password,
                  obscureText: _obscurePassword,
                  decoration: _decoration('Mật khẩu', Icons.lock_outline)
                      .copyWith(
                    suffixIcon: IconButton(
                      onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                  ),
                  validator: (value) => (value ?? '').length < 6
                      ? 'Mật khẩu phải có ít nhất 6 ký tự'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmation,
                  obscureText: _obscurePassword,
                  decoration: _decoration(
                    'Nhập lại mật khẩu',
                    Icons.lock_reset_outlined,
                  ),
                  validator: (value) => value != _password.text
                      ? 'Mật khẩu nhập lại không khớp'
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'Đơn vị thuê',
              children: [
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: false,
                      icon: Icon(Icons.business_outlined),
                      label: Text('Chọn hiện có'),
                    ),
                    ButtonSegment(
                      value: true,
                      icon: Icon(Icons.add_business_outlined),
                      label: Text('Tạo đơn vị'),
                    ),
                  ],
                  selected: {_createOrganization},
                  onSelectionChanged: (value) {
                    setState(() {
                      _createOrganization = value.first;
                      _error = null;
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (_createOrganization)
                  ..._newOrganizationFields()
                else
                  FutureBuilder<List<RegistrationOrganization>>(
                    future: _organizationsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Column(
                          children: [
                            Text('Không tải được đơn vị: ${snapshot.error}'),
                            TextButton.icon(
                              onPressed: () => setState(() {
                                _organizationsFuture = _authService
                                    .getRegistrationOrganizations();
                              }),
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Tải lại'),
                            ),
                          ],
                        );
                      }
                      final organizations = snapshot.data ?? const [];
                      return DropdownButtonFormField<RegistrationOrganization>(
                        value: _selectedOrganization,
                        isExpanded: true,
                        decoration: _decoration(
                          'Chọn đơn vị',
                          Icons.business_outlined,
                        ),
                        items: organizations
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(
                                  item.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => setState(
                          () => _selectedOrganization = value,
                        ),
                        validator: (value) => value == null
                            ? 'Vui lòng chọn đơn vị thuê'
                            : null,
                      );
                    },
                  ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(color: Color(0xFFDC2626)),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: _submitting ? null : _register,
                style: FilledButton.styleFrom(backgroundColor: blue),
                icon: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.person_add_alt_1_rounded),
                label: Text(
                  _submitting ? 'Đang tạo tài khoản...' : 'Tạo tài khoản',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _newOrganizationFields() {
    return [
      _field(_organizationName, 'Tên đơn vị', Icons.business_outlined,
          isRequired: true),
      _field(_organizationAddress, 'Địa chỉ', Icons.location_on_outlined),
      _field(_taxCode, 'Mã số thuế', Icons.receipt_long_outlined),
      _field(_representative, 'Người đại diện', Icons.contact_page_outlined),
      _field(_organizationEmail, 'Email đơn vị', Icons.alternate_email,
          email: true),
      _field(_organizationPhone, 'Số điện thoại đơn vị', Icons.phone_outlined,
          keyboardType: TextInputType.phone),
    ];
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isRequired = false,
    bool email = false,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType ??
            (email ? TextInputType.emailAddress : TextInputType.text),
        decoration: _decoration(label, icon),
        validator: (value) {
          final text = (value ?? '').trim();
          if (isRequired && text.isEmpty) return 'Vui lòng nhập $label';
          if (email && text.isNotEmpty && !text.contains('@')) {
            return 'Email không đúng định dạng';
          }
          return null;
        },
      ),
    );
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  String? _optional(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await _authService.register(
        fullName: _fullName.text.trim(),
        username: _username.text.trim(),
        email: _email.text.trim(),
        phone: _optional(_phone),
        password: _password.text,
        organizationId:
            _createOrganization ? null : _selectedOrganization?.id,
        newOrganization: _createOrganization
            ? {
                'tenDonVi': _organizationName.text.trim(),
                'diaChi': _optional(_organizationAddress),
                'maSoThue': _optional(_taxCode),
                'nguoiDaiDien': _optional(_representative),
                'email': _optional(_organizationEmail),
                'soDienThoai': _optional(_organizationPhone),
              }
            : null,
      );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (_) => false,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = error.toString();
      });
    }
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}
