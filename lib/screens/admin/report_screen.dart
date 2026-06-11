import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_report.dart';
import 'package:nhom6_detai5_doancuoiki/services/admin_api_service.dart';
import 'package:nhom6_detai5_doancuoiki/services/report_export_service.dart';
import 'package:nhom6_detai5_doancuoiki/widgets/admin_navigation_drawer.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final AdminApiService _api = const AdminApiService();
  final ReportExportService _exportService = const ReportExportService();
  late DateTime _from;
  late DateTime _to;
  late Future<AdminReport> _future;
  AdminReport? _currentReport;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _to = DateTime.now();
    _from = DateTime(_to.year, _to.month - 5, 1);
    _reload();
  }

  void _reload() {
    _future = _api.getReport(from: _from, to: _to);
  }

  void _applyRange(DateTimeRange range) {
    setState(() {
      _from = range.start;
      _to = range.end;
      _reload();
    });
  }

  Future<void> _pickRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _from, end: _to),
    );
    if (range != null) _applyRange(range);
  }

  Future<void> _exportCsv(BuildContext buttonContext) async {
    final report = _currentReport;
    if (report == null || _exporting) return;

    setState(() => _exporting = true);
    try {
      final box = buttonContext.findRenderObject() as RenderBox?;
      final origin = box == null
          ? const Rect.fromLTWH(0, 0, 1, 1)
          : box.localToGlobal(Offset.zero) & box.size;
      await _exportService.shareCsv(
        report: report,
        sharePositionOrigin: origin,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể xuất báo cáo: $error')),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      appBar: AppBar(
        title: const Text('Báo cáo và thống kê'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF0F172A),
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            onPressed: () => setState(_reload),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      drawer: const AdminNavigationDrawer(currentSection: AdminSection.reports),
      body: FutureBuilder<AdminReport>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorState(
              detail: snapshot.error.toString(),
              onRetry: () => setState(_reload),
            );
          }

          final report = snapshot.data!;
          _currentReport = report;
          return RefreshIndicator(
            onRefresh: () async => setState(_reload),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _DateFilter(
                  from: _from,
                  to: _to,
                  onTap: _pickRange,
                  exporting: _exporting,
                  onExport: _exportCsv,
                ),
                const SizedBox(height: 14),
                _OverviewGrid(overview: report.overview),
                const SizedBox(height: 14),
                _RevenuePanel(items: report.monthlyRevenue),
                const SizedBox(height: 14),
                _PaymentMethodPanel(items: report.paymentMethods),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DateFilter extends StatelessWidget {
  final DateTime from;
  final DateTime to;
  final VoidCallback onTap;
  final bool exporting;
  final ValueChanged<BuildContext> onExport;

  const _DateFilter({
    required this.from,
    required this.to,
    required this.onTap,
    required this.exporting,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd/MM/yyyy');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(),
      child: Row(
        children: [
          const Icon(Icons.analytics_rounded, color: Color(0xFF1D4ED8)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Khoảng thời gian báo cáo',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  '${date.format(from)} - ${date.format(to)}',
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Chọn khoảng ngày',
            onPressed: onTap,
            icon: const Icon(Icons.date_range_rounded),
          ),
          Builder(
            builder: (buttonContext) => IconButton(
              tooltip: 'Xuất CSV',
              onPressed: exporting ? null : () => onExport(buttonContext),
              icon: exporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewGrid extends StatelessWidget {
  final ReportOverview overview;

  const _OverviewGrid({required this.overview});

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.compactCurrency(locale: 'vi', symbol: 'đ');
    final items = [
      ('Doanh thu thực thu', money.format(overview.totalRevenue), Icons.payments_rounded, const Color(0xFF059669)),
      ('Giao dịch', '${overview.paymentCount}', Icons.receipt_long_rounded, const Color(0xFF2563EB)),
      ('Đơn thuê', '${overview.rentalOrderCount}', Icons.assignment_rounded, const Color(0xFF7C3AED)),
      ('Tỷ lệ sử dụng', '${overview.utilizationRate.toStringAsFixed(1)}%', Icons.devices_rounded, const Color(0xFFEA580C)),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 760 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.35,
          ),
          itemBuilder: (_, index) {
            final item = items[index];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: _panelDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(item.$3, color: item.$4),
                  Text(
                    item.$2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                  ),
                  Text(item.$1, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _RevenuePanel extends StatelessWidget {
  final List<ReportMonthlyRevenue> items;

  const _RevenuePanel({required this.items});

  @override
  Widget build(BuildContext context) {
    final maximum = items.fold<double>(0, (value, item) => item.revenue > value ? item.revenue : value);
    final money = NumberFormat.decimalPattern('vi');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Doanh thu theo tháng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          if (items.isEmpty)
            const Text('Chưa có giao dịch trong khoảng thời gian này.')
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text('Tháng ${item.month}/${item.year}', style: const TextStyle(fontWeight: FontWeight.w700)),
                        const Spacer(),
                        Text('${money.format(item.revenue)} đ', style: const TextStyle(fontWeight: FontWeight.w900)),
                      ],
                    ),
                    const SizedBox(height: 7),
                    LinearProgressIndicator(
                      minHeight: 9,
                      borderRadius: BorderRadius.circular(6),
                      value: maximum == 0 ? 0 : item.revenue / maximum,
                      backgroundColor: const Color(0xFFE2E8F0),
                      color: const Color(0xFF2563EB),
                    ),
                  ],
                ),
              ),
            ),
          const Divider(),
          Text(
            'Tỷ lệ sử dụng được tính theo thiết bị xuất hiện trong đơn thuê giao với khoảng ngày đã chọn.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodPanel extends StatelessWidget {
  final List<ReportPaymentMethod> items;

  const _PaymentMethodPanel({required this.items});

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.decimalPattern('vi');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Phương thức thanh toán', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          if (items.isEmpty)
            const Text('Chưa có dữ liệu thanh toán.')
          else
            ...items.map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.account_balance_wallet_rounded),
                title: Text(_methodText(item.method)),
                subtitle: Text('${item.count} giao dịch'),
                trailing: Text('${money.format(item.amount)} đ', style: const TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
        ],
      ),
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
            const Text('Không tải được báo cáo.', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(detail, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh_rounded), label: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}

BoxDecoration _panelDecoration() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    );

String _methodText(String value) {
  switch (value) {
    case 'tien_mat':
      return 'Tiền mặt';
    case 'chuyen_khoan':
      return 'Chuyển khoản';
    case 'vi_dien_tu':
      return 'Ví điện tử';
    default:
      return value;
  }
}
