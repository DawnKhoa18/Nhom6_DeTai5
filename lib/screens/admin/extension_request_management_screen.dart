import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_extension_request.dart';
import 'package:nhom6_detai5_doancuoiki/services/admin_api_service.dart';
import 'package:nhom6_detai5_doancuoiki/widgets/admin_navigation_drawer.dart';

class ExtensionRequestManagementScreen extends StatefulWidget {
  const ExtensionRequestManagementScreen({super.key});

  @override
  State<ExtensionRequestManagementScreen> createState() =>
      _ExtensionRequestManagementScreenState();
}

class _ExtensionRequestManagementScreenState
    extends State<ExtensionRequestManagementScreen> {
  final AdminApiService _api = const AdminApiService();
  late Future<List<AdminExtensionRequest>> _future;
  String selectedStatus = 'all';
  String keyword = '';

  @override
  void initState() {
    super.initState();
    _future = _api.getExtensionRequests();
  }

  void _reload() {
    setState(() => _future = _api.getExtensionRequests());
  }

  Future<void> _resolve(
    AdminExtensionRequest request,
    String nextStatus,
  ) async {
    final isApprove = nextStatus == 'da_duyet';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isApprove ? 'Duyệt yêu cầu gia hạn?' : 'Từ chối gia hạn?'),
        content: Text(
          isApprove
              ? 'Ngày kết thúc đơn thuê sẽ được cập nhật sang ' +
                  DateFormat('dd/MM/yyyy').format(request.newEndDate) +
                  '.'
              : 'Yêu cầu sẽ được chuyển sang trạng thái từ chối.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(isApprove ? 'Duyệt' : 'Từ chối'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _api.resolveExtensionRequest(
        id: request.id,
        status: nextStatus,
      );
      if (!mounted) return;
      _reload();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isApprove
                ? 'Đã duyệt yêu cầu gia hạn.'
                : 'Đã từ chối yêu cầu gia hạn.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xử lý thất bại: ' + error.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      appBar: AppBar(
        title: const Text('Quản lý yêu cầu gia hạn'),
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
        currentSection: AdminSection.extensionRequests,
      ),
      body: FutureBuilder<List<AdminExtensionRequest>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorView(detail: snapshot.error.toString(), retry: _reload);
          }

          final requests = snapshot.data ?? const [];
          final filtered = requests.where(_matches).toList();
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _Header(
                  requests: requests,
                  selectedStatus: selectedStatus,
                  onStatusChanged: (value) {
                    setState(() => selectedStatus = value);
                  },
                  onKeywordChanged: (value) {
                    setState(() => keyword = value);
                  },
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Danh sách yêu cầu',
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
                  const _EmptyView()
                else
                  ...filtered.map(
                    (request) => _ExtensionCard(
                      request: request,
                      onApprove: () => _resolve(request, 'da_duyet'),
                      onReject: () => _resolve(request, 'tu_choi'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _matches(AdminExtensionRequest request) {
    final search = keyword.trim().toLowerCase();
    final matchesText = search.isEmpty ||
        request.rentalOrderCode.toLowerCase().contains(search) ||
        request.companyName.toLowerCase().contains(search) ||
        request.devices.any(
          (item) =>
              item.assetCode.toLowerCase().contains(search) ||
              item.deviceName.toLowerCase().contains(search),
        );
    return matchesText &&
        (selectedStatus == 'all' || request.status == selectedStatus);
  }
}

class _Header extends StatelessWidget {
  final List<AdminExtensionRequest> requests;
  final String selectedStatus;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onKeywordChanged;

  const _Header({
    required this.requests,
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Yêu cầu gia hạn',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Kiểm tra thời gian thuê mới và tình trạng đặt trước của thiết bị.',
            style: TextStyle(color: Color(0xFF475569), height: 1.45),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Tìm theo đơn thuê, đơn vị hoặc thiết bị',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
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
                label: 'Tất cả ' + requests.length.toString(),
                selected: selectedStatus == 'all',
                onTap: () => onStatusChanged('all'),
              ),
              _FilterChip(
                label: 'Chờ duyệt ' + _count('cho_duyet').toString(),
                selected: selectedStatus == 'cho_duyet',
                color: const Color(0xFFEA580C),
                onTap: () => onStatusChanged('cho_duyet'),
              ),
              _FilterChip(
                label: 'Đã duyệt ' + _count('da_duyet').toString(),
                selected: selectedStatus == 'da_duyet',
                color: const Color(0xFF059669),
                onTap: () => onStatusChanged('da_duyet'),
              ),
              _FilterChip(
                label: 'Từ chối ' + _count('tu_choi').toString(),
                selected: selectedStatus == 'tu_choi',
                color: const Color(0xFFDC2626),
                onTap: () => onStatusChanged('tu_choi'),
              ),
              _FilterChip(
                label: 'Đã hủy ' + _count('huy').toString(),
                selected: selectedStatus == 'huy',
                color: const Color(0xFF64748B),
                onTap: () => onStatusChanged('huy'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _count(String status) =>
      requests.where((request) => request.status == status).length;
}

class _ExtensionCard extends StatelessWidget {
  final AdminExtensionRequest request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _ExtensionCard({
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd/MM/yyyy');
    final color = _statusColor(request.status);
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
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.more_time_rounded, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.rentalOrderCode,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      request.companyName,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(text: _statusText(request.status), color: color),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _DateBox(
                  label: 'Kết thúc hiện tại',
                  value: request.currentEndDate == null
                      ? 'Không rõ'
                      : date.format(request.currentEndDate!),
                  color: const Color(0xFF64748B),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward_rounded),
              ),
              Expanded(
                child: _DateBox(
                  label: 'Ngày đề nghị',
                  value: date.format(request.newEndDate),
                  color: const Color(0xFF1D4ED8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            request.reason?.isNotEmpty == true
                ? request.reason!
                : 'Không ghi lý do gia hạn.',
            style: const TextStyle(color: Color(0xFF334155), height: 1.4),
          ),
          const SizedBox(height: 10),
          ...request.devices.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                item.assetCode + ' • ' + item.deviceName,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          if (request.status == 'cho_duyet') ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                    ),
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Từ chối'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Duyệt'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _DateBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.w900),
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
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : const Color(0xFF475569),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  const _StatusBadge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        count.toString() + ' mục',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String detail;
  final VoidCallback retry;
  const _ErrorView({required this.detail, required this.retry});

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
            const Text(
              'Không tải được danh sách yêu cầu gia hạn.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(detail, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: retry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: Text('Không có yêu cầu phù hợp.')),
    );
  }
}

String _statusText(String status) {
  switch (status) {
    case 'cho_duyet':
      return 'Chờ duyệt';
    case 'da_duyet':
      return 'Đã duyệt';
    case 'tu_choi':
      return 'Từ chối';
    case 'huy':
      return 'Đã hủy';
    default:
      return status;
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'cho_duyet':
      return const Color(0xFFEA580C);
    case 'da_duyet':
      return const Color(0xFF059669);
    case 'tu_choi':
      return const Color(0xFFDC2626);
    default:
      return const Color(0xFF64748B);
  }
}
