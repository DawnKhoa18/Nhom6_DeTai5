import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_invoice.dart';
import 'package:nhom6_detai5_doancuoiki/services/admin_api_service.dart';
import 'package:nhom6_detai5_doancuoiki/widgets/admin_navigation_drawer.dart';

class InvoiceManagementScreen extends StatefulWidget {
  const InvoiceManagementScreen({super.key});

  @override
  State<InvoiceManagementScreen> createState() =>
      _InvoiceManagementScreenState();
}

class _InvoiceManagementScreenState extends State<InvoiceManagementScreen> {
  final AdminApiService _apiService = const AdminApiService();
  late Future<List<AdminInvoice>> _invoicesFuture;
  String selectedStatus = 'all';
  String keyword = '';

  @override
  void initState() {
    super.initState();
    _invoicesFuture = _apiService.getInvoices();
  }

  void _reload() {
    setState(() => _invoicesFuture = _apiService.getInvoices());
  }

  void _showDetails(AdminInvoice invoice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _InvoiceDetailSheet(invoice: invoice),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      appBar: AppBar(
        title: const Text('Quản lý hóa đơn'),
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
        currentSection: AdminSection.invoices,
      ),
      body: FutureBuilder<List<AdminInvoice>>(
        future: _invoicesFuture,
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

          final invoices = snapshot.data ?? const [];
          final filtered = invoices.where(_matchesFilter).toList();
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _HeaderPanel(
                  invoices: invoices,
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
                        'Danh sách hóa đơn',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Text(
                      '${filtered.length} mục',
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (filtered.isEmpty)
                  const _EmptyState()
                else
                  ...filtered.map(
                    (invoice) => _InvoiceCard(
                      invoice: invoice,
                      onTap: () => _showDetails(invoice),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _matchesFilter(AdminInvoice invoice) {
    final search = keyword.trim().toLowerCase();
    final matchesKeyword = search.isEmpty ||
        invoice.code.toLowerCase().contains(search) ||
        (invoice.rentalOrderCode ?? '').toLowerCase().contains(search) ||
        (invoice.companyName ?? '').toLowerCase().contains(search);
    final matchesStatus =
        selectedStatus == 'all' || invoice.status == selectedStatus;
    return matchesKeyword && matchesStatus;
  }
}

class _HeaderPanel extends StatelessWidget {
  final List<AdminInvoice> invoices;
  final String selectedStatus;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onKeywordChanged;

  const _HeaderPanel({
    required this.invoices,
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hóa đơn',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hóa đơn được tự động sinh khi ghi nhận thanh toán.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: onKeywordChanged,
            decoration: InputDecoration(
              hintText: 'Tìm mã hóa đơn, đơn thuê hoặc đơn vị',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChip(
                label: 'Tất cả ${invoices.length}',
                selected: selectedStatus == 'all',
                onTap: () => onStatusChanged('all'),
              ),
              _FilterChip(
                label: 'Chưa thanh toán ${_count('chua_thanh_toan')}',
                selected: selectedStatus == 'chua_thanh_toan',
                onTap: () => onStatusChanged('chua_thanh_toan'),
                color: const Color(0xFFEA580C),
              ),
              _FilterChip(
                label: 'Một phần ${_count('thanh_toan_mot_phan')}',
                selected: selectedStatus == 'thanh_toan_mot_phan',
                onTap: () => onStatusChanged('thanh_toan_mot_phan'),
                color: const Color(0xFF2563EB),
              ),
              _FilterChip(
                label: 'Đã thanh toán ${_count('da_thanh_toan')}',
                selected: selectedStatus == 'da_thanh_toan',
                onTap: () => onStatusChanged('da_thanh_toan'),
                color: const Color(0xFF059669),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _count(String status) =>
      invoices.where((invoice) => invoice.status == status).length;
}

class _InvoiceCard extends StatelessWidget {
  final AdminInvoice invoice;
  final VoidCallback onTap;

  const _InvoiceCard({required this.invoice, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.decimalPattern('vi');
    final color = _statusColor(invoice.status);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.receipt_long_rounded, color: color),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        invoice.code,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    _Badge(label: _statusText(invoice.status), color: color),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF94A3B8),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '${invoice.rentalOrderCode ?? 'Không mã đơn'} • ${invoice.companyName ?? 'Không đơn vị'}',
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Expanded(child: Text('Tổng thanh toán')),
                    Text(
                      '${currency.format(invoice.totalAmount)} đ',
                      style: const TextStyle(
                        color: Color(0xFF1D4ED8),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InvoiceDetailSheet extends StatelessWidget {
  final AdminInvoice invoice;

  const _InvoiceDetailSheet({required this.invoice});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Chi tiết hóa đơn',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                ),
                IconButton(
                  tooltip: 'Đóng',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _DetailRow(label: 'Mã hóa đơn', value: invoice.code),
            _DetailRow(
              label: 'Đơn thuê',
              value: invoice.rentalOrderCode ?? 'Không có mã',
            ),
            _DetailRow(
              label: 'Đơn vị',
              value: invoice.companyName ?? 'Không có đơn vị',
            ),
            _DetailRow(
              label: 'Ngày lập',
              value: DateFormat('dd/MM/yyyy').format(invoice.createdAt),
            ),
            _DetailRow(
              label: 'Trạng thái',
              value: _statusText(invoice.status),
            ),
            const Divider(height: 28),
            _MoneyRow(label: 'Tiền thuê', value: invoice.rentalAmount),
            _MoneyRow(label: 'Tiền đặt cọc', value: invoice.depositAmount),
            _MoneyRow(label: 'Tiền hư hỏng', value: invoice.compensationAmount),
            _MoneyRow(label: 'Tổng thanh toán', value: invoice.totalAmount),
            _MoneyRow(label: 'Đã thanh toán', value: invoice.paidAmount),
            _MoneyRow(label: 'Còn lại', value: invoice.remainingAmount),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(color: Color(0xFF64748B))),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoneyRow extends StatelessWidget {
  final String label;
  final double value;

  const _MoneyRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: Color(0xFF64748B)))),
          Text(
            '${NumberFormat.decimalPattern('vi').format(value)} đ',
            style: const TextStyle(fontWeight: FontWeight.w900),
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
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
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

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
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
            const Text(
              'Không tải được danh sách hóa đơn.',
              style: TextStyle(fontWeight: FontWeight.w800),
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
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(child: Text('Không có hóa đơn phù hợp.')),
    );
  }
}

String _statusText(String status) {
  switch (status) {
    case 'chua_thanh_toan':
      return 'Chưa thanh toán';
    case 'thanh_toan_mot_phan':
      return 'Thanh toán một phần';
    case 'da_thanh_toan':
      return 'Đã thanh toán';
    case 'huy':
      return 'Hủy';
    default:
      return status;
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'chua_thanh_toan':
      return const Color(0xFFEA580C);
    case 'thanh_toan_mot_phan':
      return const Color(0xFF2563EB);
    case 'da_thanh_toan':
      return const Color(0xFF059669);
    case 'huy':
      return const Color(0xFFDC2626);
    default:
      return const Color(0xFF64748B);
  }
}
