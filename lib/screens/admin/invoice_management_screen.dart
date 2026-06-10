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
    setState(() {
      _invoicesFuture = _apiService.getInvoices();
    });
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
              message: 'Không tải được danh sách hóa đơn.',
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
                        'Danh sách hóa đơn',
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
                  ...filtered.map((invoice) => _InvoiceCard(invoice: invoice)),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _matchesFilter(AdminInvoice invoice) {
    final normalizedKeyword = keyword.trim().toLowerCase();
    final matchesKeyword = normalizedKeyword.isEmpty ||
        invoice.code.toLowerCase().contains(normalizedKeyword) ||
        (invoice.rentalOrderCode ?? '').toLowerCase().contains(normalizedKeyword) ||
        (invoice.companyName ?? '').toLowerCase().contains(normalizedKeyword);

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
    final total = invoices.fold<double>(0, (sum, item) => sum + item.totalAmount);
    final currency = NumberFormat.decimalPattern('vi');

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
            'Hóa đơn',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tổng giá trị hóa đơn hiện có: ${currency.format(total)} đ',
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Tìm theo mã hóa đơn, mã đơn thuê hoặc đơn vị',
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
                label: 'Đã thanh toán ${_count('da_thanh_toan')}',
                selected: selectedStatus == 'da_thanh_toan',
                onTap: () => onStatusChanged('da_thanh_toan'),
                color: const Color(0xFF059669),
              ),
              _FilterChip(
                label: 'Một phần ${_count('thanh_toan_mot_phan')}',
                selected: selectedStatus == 'thanh_toan_mot_phan',
                onTap: () => onStatusChanged('thanh_toan_mot_phan'),
                color: const Color(0xFF2563EB),
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
    return invoices.where((invoice) => invoice.status == status).length;
  }
}

class _InvoiceCard extends StatelessWidget {
  final AdminInvoice invoice;

  const _InvoiceCard({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.decimalPattern('vi');
    final dateFormat = DateFormat('dd/MM/yyyy');
    final statusColor = _statusColor(invoice.status);

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
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.receipt_long_rounded, color: statusColor),
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
                            invoice.code,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        _Badge(
                          label: _statusText(invoice.status),
                          color: statusColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${invoice.rentalOrderCode ?? 'Không mã đơn'} • ${invoice.companyName ?? 'Không đơn vị'}',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _MoneyRow(label: 'Tiền thuê', value: invoice.rentalAmount),
          _MoneyRow(label: 'Tiền đặt cọc', value: invoice.depositAmount),
          _MoneyRow(label: 'Tiền đền bù', value: invoice.compensationAmount),
          const Divider(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Ngày lập: ${dateFormat.format(invoice.createdAt)}',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${currency.format(invoice.totalAmount)} đ',
                style: const TextStyle(
                  color: Color(0xFF1D4ED8),
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoneyRow extends StatelessWidget {
  final String label;
  final double value;

  const _MoneyRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.decimalPattern('vi');

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          Text(
            '${currency.format(value)} đ',
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w800,
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
          'Không có hóa đơn phù hợp với bộ lọc hiện tại.',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      ),
    );
  }
}

String _statusText(String status) {
  switch (status) {
    case 'chua_thanh_toan':
      return 'Chưa thanh toán';
    case 'da_thanh_toan':
      return 'Đã thanh toán';
    case 'thanh_toan_mot_phan':
      return 'Thanh toán một phần';
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
    case 'da_thanh_toan':
      return const Color(0xFF059669);
    case 'thanh_toan_mot_phan':
      return const Color(0xFF2563EB);
    case 'huy':
      return const Color(0xFFDC2626);
    default:
      return const Color(0xFF64748B);
  }
}
