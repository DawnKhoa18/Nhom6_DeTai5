import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_return_request.dart';
import 'package:nhom6_detai5_doancuoiki/services/admin_api_service.dart';
import 'package:nhom6_detai5_doancuoiki/widgets/admin_navigation_drawer.dart';

class ReturnRequestManagementScreen extends StatefulWidget {
  const ReturnRequestManagementScreen({super.key});

  @override
  State<ReturnRequestManagementScreen> createState() =>
      _ReturnRequestManagementScreenState();
}

class _ReturnRequestManagementScreenState
    extends State<ReturnRequestManagementScreen> {
  final AdminApiService _api = const AdminApiService();
  late Future<List<AdminReturnRequest>> _future;
  String status = 'all';
  String keyword = '';

  @override
  void initState() {
    super.initState();
    _future = _api.getReturnRequests();
  }

  void _reload() {
    setState(() => _future = _api.getReturnRequests());
  }

  void _openResolve(AdminReturnRequest request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => _ResolveSheet(
        api: _api,
        request: request,
        onDone: () {
          Navigator.pop(sheetContext);
          _reload();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xử lý yêu cầu trả máy.')),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      appBar: AppBar(
        title: const Text('Quản lý yêu cầu trả máy'),
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
        currentSection: AdminSection.returnRequests,
      ),
      body: FutureBuilder<List<AdminReturnRequest>>(
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
                  status: status,
                  onStatus: (value) => setState(() => status = value),
                  onSearch: (value) => setState(() => keyword = value),
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
                    (item) => _RequestCard(
                      request: item,
                      onResolve: () => _openResolve(item),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _matches(AdminReturnRequest request) {
    final search = keyword.trim().toLowerCase();
    final matchesText = search.isEmpty ||
        request.rentalOrderCode.toLowerCase().contains(search) ||
        request.companyName.toLowerCase().contains(search) ||
        request.devices.any(
          (item) =>
              item.assetCode.toLowerCase().contains(search) ||
              item.deviceName.toLowerCase().contains(search),
        );
    return matchesText && (status == 'all' || request.status == status);
  }
}

class _ResolveSheet extends StatefulWidget {
  final AdminApiService api;
  final AdminReturnRequest request;
  final VoidCallback onDone;

  const _ResolveSheet({
    required this.api,
    required this.request,
    required this.onDone,
  });

  @override
  State<_ResolveSheet> createState() => _ResolveSheetState();
}

class _ResolveSheetState extends State<_ResolveSheet> {
  final TextEditingController controller = TextEditingController();
  bool submitting = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        top: 18,
        bottom: MediaQuery.of(context).viewInsets.bottom + 18,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Xử lý yêu cầu trả máy',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.request.rentalOrderCode +
                  ' • ' +
                  widget.request.companyName,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.request.devices
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          item.assetCode + ' • ' + item.deviceName,
                          style: const TextStyle(
                            color: Color(0xFF334155),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Tình trạng máy khi nhận lại',
                hintText: 'Máy nguyên vẹn, đầy đủ phụ kiện...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: submitting ? null : _reject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      minimumSize: const Size.fromHeight(50),
                    ),
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Từ chối'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: submitting ? null : _accept,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    icon: submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.inventory_rounded),
                    label: const Text('Đã nhận máy'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _accept() async {
    final condition = controller.text.trim();
    if (condition.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nhập tình trạng máy khi nhận lại.')),
      );
      return;
    }
    await _submit('da_nhan_may', condition);
  }

  Future<void> _reject() async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Từ chối yêu cầu trả máy?'),
        content: const Text('Đơn thuê sẽ tiếp tục ở trạng thái đang thuê.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Từ chối'),
          ),
        ],
      ),
    );
    if (accepted == true) await _submit('tu_choi', null);
  }

  Future<void> _submit(String status, String? condition) async {
    setState(() => submitting = true);
    try {
      await widget.api.resolveReturnRequest(
        id: widget.request.id,
        status: status,
        returnCondition: condition,
      );
      if (!mounted) return;
      widget.onDone();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xử lý thất bại: ' + error.toString())),
      );
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }
}

class _Header extends StatelessWidget {
  final List<AdminReturnRequest> requests;
  final String status;
  final ValueChanged<String> onStatus;
  final ValueChanged<String> onSearch;

  const _Header({
    required this.requests,
    required this.status,
    required this.onStatus,
    required this.onSearch,
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
            'Yêu cầu trả máy',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tiếp nhận thiết bị, ghi nhận tình trạng trả và hoàn tất đơn thuê.',
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
            onChanged: onSearch,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusChip(
                label: 'Tất cả ' + requests.length.toString(),
                selected: status == 'all',
                onTap: () => onStatus('all'),
              ),
              _StatusChip(
                label: 'Chờ xử lý ' + _count('cho_xu_ly').toString(),
                selected: status == 'cho_xu_ly',
                color: const Color(0xFFEA580C),
                onTap: () => onStatus('cho_xu_ly'),
              ),
              _StatusChip(
                label: 'Đã nhận ' + _count('da_nhan_may').toString(),
                selected: status == 'da_nhan_may',
                color: const Color(0xFF059669),
                onTap: () => onStatus('da_nhan_may'),
              ),
              _StatusChip(
                label: 'Từ chối ' + _count('tu_choi').toString(),
                selected: status == 'tu_choi',
                color: const Color(0xFFDC2626),
                onTap: () => onStatus('tu_choi'),
              ),
              _StatusChip(
                label: 'Đã hủy ' + _count('huy').toString(),
                selected: status == 'huy',
                color: const Color(0xFF64748B),
                onTap: () => onStatus('huy'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _count(String value) =>
      requests.where((request) => request.status == value).length;
}

class _RequestCard extends StatelessWidget {
  final AdminReturnRequest request;
  final VoidCallback onResolve;

  const _RequestCard({required this.request, required this.onResolve});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd/MM/yyyy HH:mm');
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.assignment_return_rounded, color: color),
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
                    const SizedBox(height: 3),
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
          const SizedBox(height: 12),
          Text(
            request.reason?.isNotEmpty == true
                ? request.reason!
                : 'Không ghi lý do trả máy.',
            style: const TextStyle(color: Color(0xFF334155), height: 1.4),
          ),
          if (request.note?.isNotEmpty == true) ...[
            const SizedBox(height: 6),
            Text(
              'Ghi chú: ' + request.note!,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ],
          const SizedBox(height: 12),
          ...request.devices.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(
                item.assetCode + ' • ' + item.deviceName,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yêu cầu lúc ' + date.format(request.requestedAt),
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (request.status == 'cho_xu_ly') ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onResolve,
                icon: const Icon(Icons.fact_check_rounded),
                label: const Text('Xử lý yêu cầu'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  const _StatusChip({
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
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
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
              'Không tải được danh sách yêu cầu trả máy.',
              textAlign: TextAlign.center,
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
    case 'cho_xu_ly':
      return 'Chờ xử lý';
    case 'da_nhan_may':
      return 'Đã nhận máy';
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
    case 'cho_xu_ly':
      return const Color(0xFFEA580C);
    case 'da_nhan_may':
      return const Color(0xFF059669);
    case 'tu_choi':
      return const Color(0xFFDC2626);
    default:
      return const Color(0xFF64748B);
  }
}
