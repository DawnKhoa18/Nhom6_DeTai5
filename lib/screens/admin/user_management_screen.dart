import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_user.dart';
import 'package:nhom6_detai5_doancuoiki/services/admin_api_service.dart';
import 'package:nhom6_detai5_doancuoiki/services/auth_service.dart';
import 'package:nhom6_detai5_doancuoiki/widgets/admin_navigation_drawer.dart';
import 'package:nhom6_detai5_doancuoiki/screens/admin/user_form_sheet.dart';
import 'package:nhom6_detai5_doancuoiki/widgets/password_dialogs.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final AdminApiService _apiService = const AdminApiService();

  late Future<List<AdminUser>> _usersFuture;
  String selectedRole = 'all';
  String selectedStatus = 'all';
  String keyword = '';

  @override
  void initState() {
    super.initState();
    _usersFuture = _apiService.getUsers();
  }

  void _reload() {
    setState(() {
      _usersFuture = _apiService.getUsers();
    });
  }

  void _showForm([AdminUser? user, bool canEditAccess = true]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => UserFormSheet(
        api: _apiService,
        user: user,
        canEditAccess: canEditAccess,
        onSaved: () {
          Navigator.pop(sheetContext);
          _reload();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                user == null ? 'Đã thêm tài khoản.' : 'Đã cập nhật tài khoản.',
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _toggleStatus(AdminUser user) async {
    final newStatus = user.status == 'hoat_dong' ? 'tam_khoa' : 'hoat_dong';
    final action = newStatus == 'tam_khoa' ? 'khóa' : 'mở khóa';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(action == 'khóa' ? 'Khóa tài khoản?' : 'Mở khóa tài khoản?'),
        content: Text('Xác nhận ' + action + ' tài khoản @' + user.username + '.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(action == 'khóa' ? 'Khóa' : 'Mở khóa'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _apiService.updateUserStatus(user.id, newStatus);
      if (!mounted) return;
      _reload();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã ' + action + ' tài khoản.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể cập nhật: ' + error.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      appBar: AppBar(
        title: const Text('Quản lý người dùng'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF0F172A),
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      drawer: const AdminNavigationDrawer(
        currentSection: AdminSection.users,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        backgroundColor: const Color(0xFF1D4ED8),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Thêm tài khoản'),
      ),
      body: FutureBuilder<List<AdminUser>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErrorState(
              message: 'Không tải được danh sách người dùng.',
              detail: snapshot.error.toString(),
              onRetry: _reload,
            );
          }

          final users = snapshot.data ?? const [];
          final filtered = users.where(_matchesFilter).toList();
          final activeAdminCount = users
              .where((user) =>
                  user.role == 'admin' && user.status == 'hoat_dong')
              .length;

          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              children: [
                _HeaderPanel(
                  users: users,
                  selectedRole: selectedRole,
                  selectedStatus: selectedStatus,
                  onRoleChanged: (value) {
                    setState(() {
                      selectedRole = value;
                    });
                  },
                  onStatusChanged: (value) {
                    setState(() {
                      selectedStatus = value;
                    });
                  },
                  onKeywordChanged: (value) {
                    setState(() {
                      keyword = value;
                    });
                  },
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Danh sách tài khoản',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${filtered.length} mục',
                        style: const TextStyle(
                          color: Color(0xFF334155),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (filtered.isEmpty)
                  const _EmptyState()
                else
                  ...filtered.map(
                    (user) {
                      final isCurrentUser =
                          user.id == SessionManager.current?.userId;
                      final isLastActiveAdmin = user.role == 'admin' &&
                          user.status == 'hoat_dong' &&
                          activeAdminCount == 1;
                      final canChangeAccess =
                          !isCurrentUser && !isLastActiveAdmin;
                      return _UserCard(
                        user: user,
                        isCurrentUser: isCurrentUser,
                        accessLocked: !canChangeAccess,
                        onEdit: () => _showForm(user, canChangeAccess),
                        onToggleStatus: canChangeAccess
                            ? () => _toggleStatus(user)
                            : null,
                        onResetPassword: () async {
                          final reset = await showResetUserPasswordDialog(
                            context,
                            userId: user.id,
                            username: user.username,
                          );
                          if (reset && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã cấp lại mật khẩu tạm.'),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _matchesFilter(AdminUser user) {
    final normalizedKeyword = keyword.trim().toLowerCase();
    final matchesKeyword = normalizedKeyword.isEmpty ||
        user.fullName.toLowerCase().contains(normalizedKeyword) ||
        user.username.toLowerCase().contains(normalizedKeyword) ||
        (user.email ?? '').toLowerCase().contains(normalizedKeyword) ||
        (user.phone ?? '').toLowerCase().contains(normalizedKeyword) ||
        (user.companyName ?? '').toLowerCase().contains(normalizedKeyword);

    final matchesRole = selectedRole == 'all' || user.role == selectedRole;
    final matchesStatus =
        selectedStatus == 'all' || user.status == selectedStatus;

    return matchesKeyword && matchesRole && matchesStatus;
  }
}

class _HeaderPanel extends StatelessWidget {
  final List<AdminUser> users;
  final String selectedRole;
  final String selectedStatus;
  final ValueChanged<String> onRoleChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onKeywordChanged;

  const _HeaderPanel({
    required this.users,
    required this.selectedRole,
    required this.selectedStatus,
    required this.onRoleChanged,
    required this.onStatusChanged,
    required this.onKeywordChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tài khoản hệ thống',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Quản lý tài khoản admin, nhân viên hỗ trợ và khách hàng theo đơn vị.',
            style: TextStyle(
              color: Color(0xFF475569),
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Tìm theo họ tên, username, email, SĐT hoặc đơn vị',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: onKeywordChanged,
          ),
          const SizedBox(height: 14),
          const Text(
            'Vai trò',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChip(
                label: 'Tất cả ${users.length}',
                selected: selectedRole == 'all',
                onTap: () => onRoleChanged('all'),
              ),
              _FilterChip(
                label: 'Admin ${_countRole('admin')}',
                selected: selectedRole == 'admin',
                onTap: () => onRoleChanged('admin'),
                color: const Color(0xFF7C3AED),
              ),
              _FilterChip(
                label: 'Nhân viên ${_countRole('nhan_vien')}',
                selected: selectedRole == 'nhan_vien',
                onTap: () => onRoleChanged('nhan_vien'),
                color: const Color(0xFF2563EB),
              ),
              _FilterChip(
                label: 'Khách hàng ${_countRole('khach_hang')}',
                selected: selectedRole == 'khach_hang',
                onTap: () => onRoleChanged('khach_hang'),
                color: const Color(0xFF059669),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Trạng thái',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChip(
                label: 'Tất cả',
                selected: selectedStatus == 'all',
                onTap: () => onStatusChanged('all'),
              ),
              _FilterChip(
                label: 'Hoạt động ${_countStatus('hoat_dong')}',
                selected: selectedStatus == 'hoat_dong',
                onTap: () => onStatusChanged('hoat_dong'),
                color: const Color(0xFF059669),
              ),
              _FilterChip(
                label: 'Tạm khóa ${_countStatus('tam_khoa')}',
                selected: selectedStatus == 'tam_khoa',
                onTap: () => onStatusChanged('tam_khoa'),
                color: const Color(0xFFDC2626),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _countRole(String role) {
    return users.where((user) => user.role == role).length;
  }

  int _countStatus(String status) {
    return users.where((user) => user.status == status).length;
  }
}

class _UserCard extends StatelessWidget {
  final AdminUser user;
  final VoidCallback onEdit;
  final VoidCallback? onToggleStatus;
  final bool isCurrentUser;
  final bool accessLocked;
  final VoidCallback onResetPassword;

  const _UserCard({
    required this.user,
    required this.onEdit,
    required this.onToggleStatus,
    required this.isCurrentUser,
    required this.accessLocked,
    required this.onResetPassword,
  });

  @override
  Widget build(BuildContext context) {
    final roleColor = _roleColor(user.role);
    final statusColor = _statusColor(user.status);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: roleColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_roleIcon(user.role), color: roleColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        user.fullName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    _Badge(
                      label: _statusText(user.status),
                      color: statusColor,
                    ),
                    PopupMenuButton<String>(
                      tooltip: 'Thao tác',
                      onSelected: (value) {
                        if (value == 'edit') onEdit();
                        if (value == 'status') onToggleStatus?.call();
                        if (value == 'password') onResetPassword();
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Sửa tài khoản'),
                        ),
                        const PopupMenuItem(
                          value: 'password',
                          child: Text('Cấp lại mật khẩu'),
                        ),
                        if (!accessLocked)
                          PopupMenuItem(
                            value: 'status',
                            child: Text(
                              user.status == 'hoat_dong'
                                  ? 'Khóa tài khoản'
                                  : 'Mở khóa tài khoản',
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '@${user.username} • ${_roleText(user.role)}',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (isCurrentUser || accessLocked) ...[
                  const SizedBox(height: 6),
                  Text(
                    isCurrentUser
                        ? 'Tài khoản đang đăng nhập'
                        : 'Admin hoạt động cuối cùng',
                    style: const TextStyle(
                      color: Color(0xFFB45309),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoPill(
                      icon: Icons.business_rounded,
                      label: user.companyName ?? 'Không thuộc đơn vị',
                    ),
                    if (user.email != null)
                      _InfoPill(
                        icon: Icons.email_rounded,
                        label: user.email!,
                      ),
                    if (user.phone != null)
                      _InfoPill(
                        icon: Icons.phone_rounded,
                        label: user.phone!,
                      ),
                    _InfoPill(
                      icon: Icons.calendar_month_rounded,
                      label: dateFormat.format(user.createdAt),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color = const Color(0xFF1D4ED8),
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.12) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? color.withOpacity(0.35) : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : const Color(0xFF475569),
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF64748B)),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final String detail;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.detail,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 42, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
            const SizedBox(height: 16),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text(
          'Không có tài khoản phù hợp với bộ lọc hiện tại.',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      ),
    );
  }
}

String _roleText(String role) {
  switch (role) {
    case 'admin':
      return 'Admin';
    case 'nhan_vien':
      return 'Nhân viên';
    case 'khach_hang':
      return 'Khách hàng';
    default:
      return role;
  }
}

Color _roleColor(String role) {
  switch (role) {
    case 'admin':
      return const Color(0xFF7C3AED);
    case 'nhan_vien':
      return const Color(0xFF2563EB);
    case 'khach_hang':
      return const Color(0xFF059669);
    default:
      return const Color(0xFF64748B);
  }
}

IconData _roleIcon(String role) {
  switch (role) {
    case 'admin':
      return Icons.admin_panel_settings_rounded;
    case 'nhan_vien':
      return Icons.support_agent_rounded;
    case 'khach_hang':
      return Icons.account_circle_rounded;
    default:
      return Icons.person_rounded;
  }
}

String _statusText(String status) {
  switch (status) {
    case 'hoat_dong':
      return 'Hoạt động';
    case 'tam_khoa':
      return 'Tạm khóa';
    default:
      return status;
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'hoat_dong':
      return const Color(0xFF059669);
    case 'tam_khoa':
      return const Color(0xFFDC2626);
    default:
      return const Color(0xFF64748B);
  }
}
