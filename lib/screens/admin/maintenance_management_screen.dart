import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_device.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_maintenance.dart';
import 'package:nhom6_detai5_doancuoiki/services/admin_api_service.dart';
import 'package:nhom6_detai5_doancuoiki/widgets/admin_navigation_drawer.dart';

class MaintenanceManagementScreen extends StatefulWidget {
  const MaintenanceManagementScreen({super.key});

  @override
  State<MaintenanceManagementScreen> createState() =>
      _MaintenanceManagementScreenState();
}

class _MaintenanceManagementScreenState
    extends State<MaintenanceManagementScreen> {
  final AdminApiService _apiService = const AdminApiService();

  late Future<List<AdminMaintenance>> _maintenancesFuture;
  String selectedStatus = 'all';
  String keyword = '';

  @override
  void initState() {
    super.initState();
    _maintenancesFuture = _apiService.getMaintenances();
  }

  void _reload() {
    setState(() {
      _maintenancesFuture = _apiService.getMaintenances();
    });
  }

  Future<void> _changeMaintenanceStatus(
    AdminMaintenance maintenance,
    String nextStatus,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cập nhật phiếu #${maintenance.id}?'),
        content: Text('Trạng thái mới: ${_statusText(nextStatus)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _apiService.updateMaintenanceStatus(maintenance.id, nextStatus);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật phiếu bảo trì.')),
      );
      _reload();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật thất bại: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      appBar: AppBar(
        title: const Text('Quản lý bảo trì'),
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
        currentSection: AdminSection.maintenances,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateMaintenanceSheet,
        backgroundColor: const Color(0xFF1D4ED8),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tạo phiếu bảo trì'),
      ),
      body: FutureBuilder<List<AdminMaintenance>>(
        future: _maintenancesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErrorState(
              message: 'Không tải được danh sách bảo trì.',
              detail: snapshot.error.toString(),
              onRetry: _reload,
            );
          }

          final maintenances = snapshot.data ?? const [];
          final filtered = maintenances.where(_matchesFilter).toList();

          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              children: [
                _HeaderPanel(
                  maintenances: maintenances,
                  selectedStatus: selectedStatus,
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
                        'Danh sách phiếu bảo trì',
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
                    (maintenance) => _MaintenanceCard(
                      maintenance: maintenance,
                      onStatusChanged: (nextStatus) {
                        _changeMaintenanceStatus(maintenance, nextStatus);
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _matchesFilter(AdminMaintenance maintenance) {
    final normalizedKeyword = keyword.trim().toLowerCase();
    final matchesKeyword = normalizedKeyword.isEmpty ||
        maintenance.displayDeviceName.toLowerCase().contains(normalizedKeyword) ||
        (maintenance.assetCode ?? '').toLowerCase().contains(normalizedKeyword) ||
        maintenance.content.toLowerCase().contains(normalizedKeyword);

    final matchesStatus =
        selectedStatus == 'all' || maintenance.status == selectedStatus;

    return matchesKeyword && matchesStatus;
  }

  void _showCreateMaintenanceSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _CreateMaintenanceSheet(
          apiService: _apiService,
          onCreated: () {
            Navigator.pop(context);
            _reload();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã tạo phiếu bảo trì.')),
            );
          },
        );
      },
    );
  }
}

class _CreateMaintenanceSheet extends StatefulWidget {
  final AdminApiService apiService;
  final VoidCallback onCreated;

  const _CreateMaintenanceSheet({
    required this.apiService,
    required this.onCreated,
  });

  @override
  State<_CreateMaintenanceSheet> createState() =>
      _CreateMaintenanceSheetState();
}

class _CreateMaintenanceSheetState extends State<_CreateMaintenanceSheet> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _costController = TextEditingController(text: '0');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late Future<List<AdminDevice>> _devicesFuture;
  AdminDevice? _selectedDevice;
  DateTime _startDate = DateTime.now();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _devicesFuture = widget.apiService.getDevices();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Padding(
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        top: 18,
        bottom: MediaQuery.of(context).viewInsets.bottom + 18,
      ),
      child: FutureBuilder<List<AdminDevice>>(
        future: _devicesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 220,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return SizedBox(
              height: 220,
              child: Center(
                child: Text('Không tải được danh sách máy: ${snapshot.error}'),
              ),
            );
          }

          final devices = snapshot.data ?? const [];

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tạo phiếu bảo trì',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<AdminDevice>(
                    value: _selectedDevice,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Thiết bị',
                      border: OutlineInputBorder(),
                    ),
                    items: devices
                        .map(
                          (device) => DropdownMenuItem(
                            value: device,
                            child: Text(
                              '${device.assetCode} • ${device.displayName}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    validator: (value) {
                      if (value == null) return 'Chọn thiết bị cần bảo trì';
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _selectedDevice = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: _pickStartDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Ngày bắt đầu',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.date_range_rounded, size: 18),
                          const SizedBox(width: 8),
                          Text(dateFormat.format(_startDate)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _contentController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Nội dung bảo trì',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nhập nội dung bảo trì';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _costController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Chi phí',
                      suffixText: 'đ',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final cost = double.tryParse(value?.trim() ?? '');
                      if (cost == null || cost < 0) {
                        return 'Chi phí không hợp lệ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: _isSubmitting ? null : _submit,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_rounded),
                      label: const Text('Tạo phiếu'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked == null) return;

    setState(() {
      _startDate = picked;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.apiService.createMaintenance(
        deviceId: _selectedDevice!.id,
        startDate: _startDate,
        content: _contentController.text.trim(),
        cost: double.parse(_costController.text.trim()),
      );
      if (!mounted) return;
      widget.onCreated();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tạo phiếu thất bại: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

class _HeaderPanel extends StatelessWidget {
  final List<AdminMaintenance> maintenances;
  final String selectedStatus;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onKeywordChanged;

  const _HeaderPanel({
    required this.maintenances,
    required this.selectedStatus,
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
            'Bảo trì thiết bị',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Theo dõi phiếu bảo trì, chi phí và tiến độ xử lý từng thiết bị.',
            style: TextStyle(
              color: Color(0xFF475569),
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Tìm theo mã máy, tên máy hoặc nội dung bảo trì',
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
                label: 'Tất cả ${maintenances.length}',
                selected: selectedStatus == 'all',
                onTap: () => onStatusChanged('all'),
              ),
              _FilterChip(
                label: 'Đang bảo trì ${_count('dang_bao_tri')}',
                selected: selectedStatus == 'dang_bao_tri',
                onTap: () => onStatusChanged('dang_bao_tri'),
                color: const Color(0xFFEA580C),
              ),
              _FilterChip(
                label: 'Hoàn thành ${_count('hoan_thanh')}',
                selected: selectedStatus == 'hoan_thanh',
                onTap: () => onStatusChanged('hoan_thanh'),
                color: const Color(0xFF059669),
              ),
              _FilterChip(
                label: 'Hủy ${_count('huy')}',
                selected: selectedStatus == 'huy',
                onTap: () => onStatusChanged('huy'),
                color: const Color(0xFFDC2626),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _count(String status) {
    return maintenances.where((item) => item.status == status).length;
  }
}

class _MaintenanceCard extends StatelessWidget {
  final AdminMaintenance maintenance;
  final ValueChanged<String> onStatusChanged;

  const _MaintenanceCard({
    required this.maintenance,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.decimalPattern('vi');
    final dateFormat = DateFormat('dd/MM/yyyy');
    final statusColor = _statusColor(maintenance.status);

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
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.build_rounded, color: statusColor),
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
                        maintenance.displayDeviceName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    _Badge(
                      label: _statusText(maintenance.status),
                      color: statusColor,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  maintenance.assetCode ?? 'Không mã tài sản',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  maintenance.content,
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    height: 1.4,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoPill(
                      icon: Icons.date_range_rounded,
                      label:
                          'Bắt đầu ${dateFormat.format(maintenance.startDate)}',
                    ),
                    _InfoPill(
                      icon: Icons.event_available_rounded,
                      label: maintenance.endDate == null
                          ? 'Chưa kết thúc'
                          : 'Kết thúc ${dateFormat.format(maintenance.endDate!)}',
                    ),
                    _InfoPill(
                      icon: Icons.payments_rounded,
                      label: '${currency.format(maintenance.cost)} đ',
                    ),
                  ],
                ),
                if (maintenance.status == 'dang_bao_tri') ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => onStatusChanged('hoan_thanh'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF059669),
                          side: BorderSide(
                            color: const Color(0xFF059669).withOpacity(0.35),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: const Text('Hoàn tất'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => onStatusChanged('huy'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFDC2626),
                          side: BorderSide(
                            color: const Color(0xFFDC2626).withOpacity(0.35),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.close_rounded, size: 18),
                        label: const Text('Hủy phiếu'),
                      ),
                    ],
                  ),
                ],
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
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 12,
              fontWeight: FontWeight.w700,
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
          'Không có phiếu bảo trì phù hợp với bộ lọc hiện tại.',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      ),
    );
  }
}

String _statusText(String status) {
  switch (status) {
    case 'dang_bao_tri':
      return 'Đang bảo trì';
    case 'hoan_thanh':
      return 'Hoàn thành';
    case 'huy':
      return 'Hủy';
    default:
      return status;
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'dang_bao_tri':
      return const Color(0xFFEA580C);
    case 'hoan_thanh':
      return const Color(0xFF059669);
    case 'huy':
      return const Color(0xFFDC2626);
    default:
      return const Color(0xFF64748B);
  }
}
