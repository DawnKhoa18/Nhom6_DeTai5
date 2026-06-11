import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_damage_level.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_damage_report.dart';
import 'package:nhom6_detai5_doancuoiki/services/admin_api_service.dart';
import 'package:nhom6_detai5_doancuoiki/widgets/admin_navigation_drawer.dart';

class DamageReportManagementScreen extends StatefulWidget {
  const DamageReportManagementScreen({super.key});

  @override
  State<DamageReportManagementScreen> createState() =>
      _DamageReportManagementScreenState();
}

class _DamageReportManagementScreenState
    extends State<DamageReportManagementScreen> {
  final AdminApiService _apiService = const AdminApiService();
  late Future<List<AdminDamageReport>> _reportsFuture;
  late Future<List<AdminDamageLevel>> _levelsFuture;
  String selectedStatus = 'all';
  String keyword = '';

  @override
  void initState() {
    super.initState();
    _reportsFuture = _apiService.getDamageReports();
    _levelsFuture = _apiService.getDamageLevels();
  }

  void _reload() {
    setState(() {
      _reportsFuture = _apiService.getDamageReports();
      _levelsFuture = _apiService.getDamageLevels();
    });
  }

  Future<void> _showResolveSheet(AdminDamageReport report) async {
    try {
      final levels = await _levelsFuture;
      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (sheetContext) => _ResolveDamageSheet(
          apiService: _apiService,
          report: report,
          levels: levels,
          onResolved: () {
            Navigator.pop(sheetContext);
            _reload();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã xử lý báo cáo hư hỏng.')),
            );
          },
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không tải được mức độ hư hỏng: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      appBar: AppBar(
        title: const Text('Quản lý báo cáo hư hỏng'),
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
        currentSection: AdminSection.damageReports,
      ),
      body: FutureBuilder<List<AdminDamageReport>>(
        future: _reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorState(
              detail: snapshot.error.toString(),
              onRetry: _reload,
            );
          }

          final reports = snapshot.data ?? const [];
          final filtered = reports.where(_matchesFilter).toList();

          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _HeaderPanel(
                  reports: reports,
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
                        'Danh sách báo cáo',
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
                  const _EmptyState()
                else
                  ...filtered.map(
                    (report) => _DamageReportCard(
                      report: report,
                      onResolve: () => _showResolveSheet(report),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _matchesFilter(AdminDamageReport report) {
    final search = keyword.trim().toLowerCase();
    final matchesKeyword = search.isEmpty ||
        report.assetCode.toLowerCase().contains(search) ||
        report.deviceName.toLowerCase().contains(search) ||
        report.rentalOrderCode.toLowerCase().contains(search) ||
        report.companyName.toLowerCase().contains(search) ||
        report.reporterName.toLowerCase().contains(search);
    final matchesStatus =
        selectedStatus == 'all' || report.status == selectedStatus;
    return matchesKeyword && matchesStatus;
  }
}

class _ResolveDamageSheet extends StatefulWidget {
  final AdminApiService apiService;
  final AdminDamageReport report;
  final List<AdminDamageLevel> levels;
  final VoidCallback onResolved;

  const _ResolveDamageSheet({
    required this.apiService,
    required this.report,
    required this.levels,
    required this.onResolved,
  });

  @override
  State<_ResolveDamageSheet> createState() => _ResolveDamageSheetState();
}

class _ResolveDamageSheetState extends State<_ResolveDamageSheet> {
  AdminDamageLevel? selectedLevel;
  bool isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.decimalPattern('vi');
    final estimated = selectedLevel == null
        ? 0.0
        : widget.report.deviceValue *
            selectedLevel!.compensationPercent /
            100;

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
              'Xử lý báo cáo hư hỏng',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${widget.report.assetCode} • ${widget.report.deviceName}',
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AdminDamageLevel>(
              value: selectedLevel,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Mức độ hư hỏng',
                border: OutlineInputBorder(),
              ),
              items: widget.levels
                  .map(
                    (level) => DropdownMenuItem(
                      value: level,
                      child: Text(
                        '${level.name} • ${level.compensationPercent.toStringAsFixed(0)}%',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => selectedLevel = value),
            ),
            const SizedBox(height: 12),
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
                children: [
                  Text(
                    'Giá trị máy: ${currency.format(widget.report.deviceValue)} đ',
                    style: const TextStyle(color: Color(0xFF475569)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tiền đền bù dự kiến: ${currency.format(estimated)} đ',
                    style: const TextStyle(
                      color: Color(0xFFDC2626),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isSubmitting ? null : _reject,
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
                    onPressed: isSubmitting || selectedLevel == null
                        ? null
                        : _confirm,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    icon: isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_rounded),
                    label: const Text('Xác nhận'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirm() async {
    await _submit('da_xac_nhan', selectedLevel!.id);
  }

  Future<void> _reject() async {
    await _submit('da_tu_choi', null);
  }

  Future<void> _submit(String status, int? levelId) async {
    setState(() => isSubmitting = true);
    try {
      await widget.apiService.resolveDamageReport(
        id: widget.report.id,
        status: status,
        damageLevelId: levelId,
      );
      if (!mounted) return;
      widget.onResolved();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xử lý thất bại: $error')),
      );
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }
}

class _HeaderPanel extends StatelessWidget {
  final List<AdminDamageReport> reports;
  final String selectedStatus;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onKeywordChanged;

  const _HeaderPanel({
    required this.reports,
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
            'Báo cáo hư hỏng',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Xác minh sự cố, áp dụng mức độ hư hỏng và tính tiền đền bù.',
            style: TextStyle(color: Color(0xFF475569), height: 1.45),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Tìm theo máy, đơn thuê, đơn vị hoặc người báo',
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
                label: 'Tất cả ${reports.length}',
                selected: selectedStatus == 'all',
                onTap: () => onStatusChanged('all'),
              ),
              _FilterChip(
                label: 'Chờ xử lý ${_count('cho_xu_ly')}',
                selected: selectedStatus == 'cho_xu_ly',
                color: const Color(0xFFEA580C),
                onTap: () => onStatusChanged('cho_xu_ly'),
              ),
              _FilterChip(
                label: 'Đã xác nhận ${_count('da_xac_nhan')}',
                selected: selectedStatus == 'da_xac_nhan',
                color: const Color(0xFF059669),
                onTap: () => onStatusChanged('da_xac_nhan'),
              ),
              _FilterChip(
                label: 'Từ chối ${_count('da_tu_choi')}',
                selected: selectedStatus == 'da_tu_choi',
                color: const Color(0xFFDC2626),
                onTap: () => onStatusChanged('da_tu_choi'),
              ),
              _FilterChip(
                label: 'Đã thanh toán ${_count('da_thanh_toan')}',
                selected: selectedStatus == 'da_thanh_toan',
                color: const Color(0xFF2563EB),
                onTap: () => onStatusChanged('da_thanh_toan'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _count(String status) =>
      reports.where((item) => item.status == status).length;
}

class _DamageReportCard extends StatelessWidget {
  final AdminDamageReport report;
  final VoidCallback onResolve;

  const _DamageReportCard({required this.report, required this.onResolve});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.decimalPattern('vi');
    final date = DateFormat('dd/MM/yyyy HH:mm');
    final color = _statusColor(report.status);

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
                child: Icon(Icons.report_problem_rounded, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.deviceName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${report.assetCode} • ${report.rentalOrderCode}',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(label: _statusText(report.status), color: color),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            report.description,
            style: const TextStyle(color: Color(0xFF334155), height: 1.45),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoPill(icon: Icons.business_rounded, label: report.companyName),
              _InfoPill(icon: Icons.person_rounded, label: report.reporterName),
              _InfoPill(
                icon: Icons.schedule_rounded,
                label: date.format(report.reportedAt),
              ),
            ],
          ),
          if (report.damageLevelName != null) ...[
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${report.damageLevelName} • ${report.compensationPercent?.toStringAsFixed(0) ?? 0}%',
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '${currency.format(report.compensationAmount)} đ',
                  style: const TextStyle(
                    color: Color(0xFFDC2626),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
          if (report.status == 'cho_xu_ly') ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onResolve,
                icon: const Icon(Icons.fact_check_rounded),
                label: const Text('Xử lý báo cáo'),
              ),
            ),
          ],
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
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
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
      child: Text('$count mục', style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String detail;
  final VoidCallback onRetry;
  const _ErrorState({required this.detail, required this.onRetry});

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
              'Không tải được danh sách báo cáo hư hỏng.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(detail, textAlign: TextAlign.center),
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
      child: const Center(child: Text('Không có báo cáo phù hợp.')),
    );
  }
}

String _statusText(String status) {
  switch (status) {
    case 'cho_xu_ly':
      return 'Chờ xử lý';
    case 'da_xac_nhan':
      return 'Đã xác nhận';
    case 'da_tu_choi':
      return 'Đã từ chối';
    case 'da_thanh_toan':
      return 'Đã thanh toán';
    default:
      return status;
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'cho_xu_ly':
      return const Color(0xFFEA580C);
    case 'da_xac_nhan':
      return const Color(0xFF059669);
    case 'da_tu_choi':
      return const Color(0xFFDC2626);
    case 'da_thanh_toan':
      return const Color(0xFF2563EB);
    default:
      return const Color(0xFF64748B);
  }
}
