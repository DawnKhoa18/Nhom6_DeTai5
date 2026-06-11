import 'package:flutter/material.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_device.dart';
import 'package:nhom6_detai5_doancuoiki/services/admin_api_service.dart';
import 'package:nhom6_detai5_doancuoiki/widgets/admin_navigation_drawer.dart';
import 'package:nhom6_detai5_doancuoiki/widgets/device_card.dart';
import 'package:nhom6_detai5_doancuoiki/screens/admin/device_form_sheet.dart';

class DeviceManagementScreen extends StatefulWidget {
  final String initialKeyword;
  final String initialStatus;

  const DeviceManagementScreen({
    super.key,
    this.initialKeyword = '',
    this.initialStatus = 'all',
  });

  @override
  State<DeviceManagementScreen> createState() => _DeviceManagementScreenState();
}

class _DeviceManagementScreenState extends State<DeviceManagementScreen> {
  final AdminApiService _apiService = const AdminApiService();

  late Future<List<AdminDevice>> _devicesFuture;
  late String keyword;
  late String selectedStatus;

  @override
  void initState() {
    super.initState();
    keyword = widget.initialKeyword;
    selectedStatus = widget.initialStatus;
    _devicesFuture = _apiService.getDevices();
  }

  void _reload() {
    setState(() {
      _devicesFuture = _apiService.getDevices();
    });
  }

  void _showForm([AdminDevice? device]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => DeviceFormSheet(
        api: _apiService,
        device: device,
        onSaved: () {
          Navigator.pop(sheetContext);
          _reload();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                device == null ? 'Đã thêm thiết bị.' : 'Đã cập nhật thiết bị.',
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _delete(AdminDevice device) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa thiết bị?'),
        content: Text(
          'Thiết bị ' + device.assetCode + ' chỉ có thể xóa nếu chưa phát sinh lịch sử thuê, bảo trì hoặc ảnh.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _apiService.deleteDevice(device.id);
      if (!mounted) return;
      _reload();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa thiết bị.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể xóa: ' + error.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      appBar: AppBar(
        title: const Text('Quản lý thiết bị'),
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
        currentSection: AdminSection.devices,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        backgroundColor: const Color(0xFF1D4ED8),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm thiết bị'),
      ),
      body: FutureBuilder<List<AdminDevice>>(
        future: _devicesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErrorState(
              message: 'Không tải được danh sách thiết bị.',
              detail: snapshot.error.toString(),
              onRetry: _reload,
            );
          }

          final devices = snapshot.data ?? const [];
          final filtered = devices.where(_matchesFilter).toList();

          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              children: [
                _InventoryHeader(
                  devices: devices,
                  keyword: keyword,
                  selectedStatus: selectedStatus,
                  onKeywordChanged: (value) {
                    setState(() {
                      keyword = value;
                    });
                  },
                  onStatusChanged: (value) {
                    setState(() {
                      selectedStatus = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Danh sách thiết bị',
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
                const SizedBox(height: 14),
                if (filtered.isEmpty)
                  const _EmptyState()
                else
                  ...filtered.map(
                    (device) => DeviceCardModern(
                      device: device,
                      onEdit: () => _showForm(device),
                      onDelete: () => _delete(device),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _matchesFilter(AdminDevice device) {
    final normalizedKeyword = keyword.trim().toLowerCase();
    final matchesKeyword = normalizedKeyword.isEmpty ||
        device.displayName.toLowerCase().contains(normalizedKeyword) ||
        device.assetCode.toLowerCase().contains(normalizedKeyword) ||
        (device.brand ?? '').toLowerCase().contains(normalizedKeyword) ||
        (device.serialNumber ?? '').toLowerCase().contains(normalizedKeyword);

    final matchesStatus =
        selectedStatus == 'all' || device.status == selectedStatus;

    return matchesKeyword && matchesStatus;
  }
}

class _InventoryHeader extends StatelessWidget {
  final List<AdminDevice> devices;
  final String keyword;
  final String selectedStatus;
  final ValueChanged<String> onKeywordChanged;
  final ValueChanged<String> onStatusChanged;

  const _InventoryHeader({
    required this.devices,
    required this.keyword,
    required this.selectedStatus,
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
            'Kho thiết bị',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tìm kiếm, lọc và kiểm tra nhanh tình trạng từng máy.',
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: keyword,
            decoration: InputDecoration(
              hintText: 'Tìm theo tên, mã tài sản, serial hoặc hãng',
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChip(
                label: 'Tất cả ${devices.length}',
                selected: selectedStatus == 'all',
                onTap: () => onStatusChanged('all'),
              ),
              _FilterChip(
                label: 'Sẵn sàng ${_count('san_sang')}',
                selected: selectedStatus == 'san_sang',
                onTap: () => onStatusChanged('san_sang'),
                color: const Color(0xFF059669),
              ),
              _FilterChip(
                label: 'Đang thuê ${_count('dang_thue')}',
                selected: selectedStatus == 'dang_thue',
                onTap: () => onStatusChanged('dang_thue'),
                color: const Color(0xFF2563EB),
              ),
              _FilterChip(
                label: 'Bảo trì ${_count('bao_tri')}',
                selected: selectedStatus == 'bao_tri',
                onTap: () => onStatusChanged('bao_tri'),
                color: const Color(0xFFEA580C),
              ),
              _FilterChip(
                label: 'Hỏng ${_count('hong')}',
                selected: selectedStatus == 'hong',
                onTap: () => onStatusChanged('hong'),
                color: const Color(0xFFDC2626),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _count(String status) {
    return devices.where((device) => device.status == status).length;
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
          'Không có thiết bị phù hợp với bộ lọc hiện tại.',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      ),
    );
  }
}
