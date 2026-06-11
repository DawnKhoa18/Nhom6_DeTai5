import 'package:flutter/material.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_organization.dart';
import 'package:nhom6_detai5_doancuoiki/services/admin_api_service.dart';
import 'package:nhom6_detai5_doancuoiki/widgets/admin_navigation_drawer.dart';

class OrganizationManagementScreen extends StatefulWidget {
  const OrganizationManagementScreen({super.key});

  @override
  State<OrganizationManagementScreen> createState() =>
      _OrganizationManagementScreenState();
}

class _OrganizationManagementScreenState
    extends State<OrganizationManagementScreen> {
  final AdminApiService _api = const AdminApiService();
  late Future<List<AdminOrganization>> _future;
  String _keyword = '';
  String _status = 'all';

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _future = _api.getOrganizations();
    });
  }

  void _showForm([AdminOrganization? organization]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => _OrganizationForm(
        api: _api,
        organization: organization,
        onSaved: () {
          Navigator.pop(sheetContext);
          _reload();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                organization == null
                    ? 'Đã thêm đơn vị.'
                    : 'Đã cập nhật đơn vị.',
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _delete(AdminOrganization organization) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa đơn vị?'),
        content: Text(
          organization.canDelete
              ? 'Đơn vị "' + organization.name + '" sẽ bị xóa.'
              : 'Đơn vị đã có người dùng hoặc đơn thuê nên không thể xóa. Anh có thể chuyển sang trạng thái ngừng hoạt động.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: organization.canDelete
                ? () => Navigator.pop(dialogContext, true)
                : null,
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _api.deleteOrganization(organization.id);
      if (!mounted) return;
      _reload();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa đơn vị.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể xóa: ' + error.toString())),
      );
    }
  }

  bool _matches(AdminOrganization item) {
    final keyword = _keyword.trim().toLowerCase();
    final matchesKeyword = keyword.isEmpty ||
        item.name.toLowerCase().contains(keyword) ||
        (item.taxCode ?? '').toLowerCase().contains(keyword) ||
        (item.representative ?? '').toLowerCase().contains(keyword) ||
        (item.phone ?? '').toLowerCase().contains(keyword);
    return matchesKeyword && (_status == 'all' || item.status == _status);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      appBar: AppBar(
        title: const Text('Quản lý đơn vị'),
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
        currentSection: AdminSection.organizations,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        backgroundColor: const Color(0xFF1D4ED8),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_business_rounded),
        label: const Text('Thêm đơn vị'),
      ),
      body: FutureBuilder<List<AdminOrganization>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _MessageState(
              icon: Icons.cloud_off_rounded,
              title: 'Không tải được danh sách đơn vị.',
              detail: snapshot.error.toString(),
              onRetry: _reload,
            );
          }

          final organizations = snapshot.data ?? const [];
          final filtered = organizations.where(_matches).toList();
          final activeCount = organizations.where((x) => x.isActive).length;

          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              children: [
                _HeaderPanel(
                  total: organizations.length,
                  active: activeCount,
                  status: _status,
                  onKeywordChanged: (value) =>
                      setState(() => _keyword = value),
                  onStatusChanged: (value) =>
                      setState(() => _status = value),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Danh sách đơn vị',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    _CountBadge(count: filtered.length),
                  ],
                ),
                const SizedBox(height: 12),
                if (filtered.isEmpty)
                  const _MessageState(
                    icon: Icons.business_outlined,
                    title: 'Không có đơn vị phù hợp.',
                  )
                else
                  ...filtered.map(
                    (item) => _OrganizationCard(
                      organization: item,
                      onEdit: () => _showForm(item),
                      onDelete: () => _delete(item),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeaderPanel extends StatelessWidget {
  final int total;
  final int active;
  final String status;
  final ValueChanged<String> onKeywordChanged;
  final ValueChanged<String> onStatusChanged;

  const _HeaderPanel({
    required this.total,
    required this.active,
    required this.status,
    required this.onKeywordChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đơn vị thuê',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Quản lý doanh nghiệp, người đại diện và thông tin liên hệ.',
            style: TextStyle(color: Color(0xFF64748B), height: 1.4),
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: onKeywordChanged,
            decoration: InputDecoration(
              hintText: 'Tìm tên, mã số thuế, đại diện, số điện thoại',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatChip(label: 'Tổng ' + total.toString(), color: const Color(0xFF1D4ED8)),
              _StatChip(label: 'Hoạt động ' + active.toString(), color: const Color(0xFF059669)),
              _StatChip(label: 'Tạm ngừng ' + (total - active).toString(), color: const Color(0xFFEA580C)),
            ],
          ),
          const SizedBox(height: 14),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'all', label: Text('Tất cả')),
              ButtonSegment(value: 'hoat_dong', label: Text('Hoạt động')),
              ButtonSegment(value: 'tam_khoa', label: Text('Tạm khóa')),
            ],
            selected: {status},
            showSelectedIcon: false,
            onSelectionChanged: (values) => onStatusChanged(values.first),
          ),
        ],
      ),
    );
  }
}

class _OrganizationCard extends StatelessWidget {
  final AdminOrganization organization;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _OrganizationCard({
    required this.organization,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = organization.isActive
        ? const Color(0xFF059669)
        : const Color(0xFFEA580C);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.business_rounded, color: Color(0xFF1D4ED8)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      organization.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 5),
                    _StatChip(
                      label: organization.isActive ? 'Hoạt động' : 'Tạm khóa',
                      color: statusColor,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Thao tác',
                onSelected: (value) => value == 'edit' ? onEdit() : onDelete(),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Sửa đơn vị')),
                  PopupMenuItem(value: 'delete', child: Text('Xóa đơn vị')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_hasText(organization.representative))
            _InfoRow(icon: Icons.person_outline_rounded, text: organization.representative!),
          if (_hasText(organization.phone))
            _InfoRow(icon: Icons.phone_outlined, text: organization.phone!),
          if (_hasText(organization.email))
            _InfoRow(icon: Icons.email_outlined, text: organization.email!),
          if (_hasText(organization.address))
            _InfoRow(icon: Icons.location_on_outlined, text: organization.address!),
          if (_hasText(organization.taxCode))
            _InfoRow(icon: Icons.badge_outlined, text: 'MST: ' + organization.taxCode!),
          const Divider(height: 22),
          Row(
            children: [
              Expanded(child: Text(organization.userCount.toString() + ' người dùng', style: const TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w700))),
              Text(organization.orderCount.toString() + ' đơn thuê', style: const TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  bool _hasText(String? value) => value != null && value.trim().isNotEmpty;
}

class _OrganizationForm extends StatefulWidget {
  final AdminApiService api;
  final AdminOrganization? organization;
  final VoidCallback onSaved;

  const _OrganizationForm({
    required this.api,
    required this.organization,
    required this.onSaved,
  });

  @override
  State<_OrganizationForm> createState() => _OrganizationFormState();
}

class _OrganizationFormState extends State<_OrganizationForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _address;
  late final TextEditingController _taxCode;
  late final TextEditingController _representative;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late String _status;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final item = widget.organization;
    _name = TextEditingController(text: item?.name ?? '');
    _address = TextEditingController(text: item?.address ?? '');
    _taxCode = TextEditingController(text: item?.taxCode ?? '');
    _representative = TextEditingController(text: item?.representative ?? '');
    _email = TextEditingController(text: item?.email ?? '');
    _phone = TextEditingController(text: item?.phone ?? '');
    _status = item?.status ?? 'hoat_dong';
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _taxCode.dispose();
    _representative.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _saving = true; _error = null; });
    try {
      final item = widget.organization;
      final values = {
        'name': _name.text.trim(),
        'address': _address.text.trim(),
        'taxCode': _taxCode.text.trim(),
        'representative': _representative.text.trim(),
        'email': _email.text.trim(),
        'phone': _phone.text.trim(),
      };
      if (item == null) {
        await widget.api.createOrganization(
          name: values['name']!, status: _status, address: values['address'],
          taxCode: values['taxCode'], representative: values['representative'],
          email: values['email'], phone: values['phone'],
        );
      } else {
        await widget.api.updateOrganization(
          id: item.id, name: values['name']!, status: _status,
          address: values['address'], taxCode: values['taxCode'],
          representative: values['representative'], email: values['email'],
          phone: values['phone'],
        );
      }
      if (mounted) widget.onSaved();
    } catch (error) {
      if (!mounted) return;
      setState(() { _saving = false; _error = error.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: Text(widget.organization == null ? 'Thêm đơn vị' : 'Sửa đơn vị', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900))),
                IconButton(onPressed: _saving ? null : () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
              ]),
              const SizedBox(height: 16),
              _Field(controller: _name, label: 'Tên đơn vị *', icon: Icons.business_rounded, validator: (value) => value == null || value.trim().isEmpty ? 'Vui lòng nhập tên đơn vị.' : null),
              _Field(controller: _taxCode, label: 'Mã số thuế', icon: Icons.badge_outlined),
              _Field(controller: _representative, label: 'Người đại diện', icon: Icons.person_outline_rounded),
              _Field(controller: _phone, label: 'Số điện thoại', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
              _Field(controller: _email, label: 'Email', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: (value) => value != null && value.trim().isNotEmpty && !value.contains('@') ? 'Email chưa đúng định dạng.' : null),
              _Field(controller: _address, label: 'Địa chỉ', icon: Icons.location_on_outlined, maxLines: 2),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Trạng thái', prefixIcon: Icon(Icons.toggle_on_outlined), border: OutlineInputBorder()),
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
                  icon: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save_rounded),
                  label: Text(_saving ? 'Đang lưu...' : 'Lưu đơn vị'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({required this.controller, required this.label, required this.icon, this.maxLines = 1, this.keyboardType, this.validator});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: const OutlineInputBorder()),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Row(children: [Icon(icon, size: 17, color: const Color(0xFF64748B)), const SizedBox(width: 8), Expanded(child: Text(text, style: const TextStyle(color: Color(0xFF475569))))]),
  );
}

class _StatChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatChip({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(999)),
    child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800)),
  );
}

class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
    child: Text(count.toString() + ' mục', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF334155))),
  );
}

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? detail;
  final VoidCallback? onRetry;
  const _MessageState({required this.icon, required this.title, this.detail, this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 42, color: const Color(0xFF94A3B8)),
        const SizedBox(height: 10),
        Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800)),
        if (detail != null) ...[const SizedBox(height: 7), Text(detail!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)))],
        if (onRetry != null) ...[const SizedBox(height: 14), FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh_rounded), label: const Text('Thử lại'))],
      ]),
    ),
  );
}
