import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_invoice.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_payment.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_rental_order.dart';
import 'package:nhom6_detai5_doancuoiki/services/admin_api_service.dart';
import 'package:nhom6_detai5_doancuoiki/widgets/admin_navigation_drawer.dart';

class PaymentManagementScreen extends StatefulWidget {
  const PaymentManagementScreen({super.key});

  @override
  State<PaymentManagementScreen> createState() => _PaymentManagementScreenState();
}

class _PaymentManagementScreenState extends State<PaymentManagementScreen> {
  final AdminApiService _apiService = const AdminApiService();

  late Future<List<AdminPayment>> _paymentsFuture;
  String selectedMethod = 'all';
  String keyword = '';

  @override
  void initState() {
    super.initState();
    _paymentsFuture = _apiService.getPayments();
  }

  void _reload() {
    setState(() {
      _paymentsFuture = _apiService.getPayments();
    });
  }

  void _showCreatePaymentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _CreatePaymentSheet(
          apiService: _apiService,
          onCreated: () {
            Navigator.pop(context);
            _reload();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã ghi nhận thanh toán.')),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      appBar: AppBar(
        title: const Text('Quản lý thanh toán'),
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
        currentSection: AdminSection.payments,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreatePaymentSheet,
        backgroundColor: const Color(0xFF1D4ED8),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_card_rounded),
        label: const Text('Ghi nhận thanh toán'),
      ),
      body: FutureBuilder<List<AdminPayment>>(
        future: _paymentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErrorState(
              message: 'Không tải được danh sách thanh toán.',
              detail: snapshot.error.toString(),
              onRetry: _reload,
            );
          }

          final payments = snapshot.data ?? const [];
          final filtered = payments.where(_matchesFilter).toList();

          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              children: [
                _HeaderPanel(
                  payments: payments,
                  selectedMethod: selectedMethod,
                  onMethodChanged: (value) {
                    setState(() {
                      selectedMethod = value;
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
                        'Danh sách thanh toán',
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
                    (payment) => _PaymentCard(
                      payment: payment,
                      onAdjust: payment.isAdjustment
                          ? null
                          : () => _showAdjustmentDialog(payment),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _matchesFilter(AdminPayment payment) {
    final normalizedKeyword = keyword.trim().toLowerCase();
    final matchesKeyword = normalizedKeyword.isEmpty ||
        (payment.invoiceCode ?? '').toLowerCase().contains(normalizedKeyword) ||
        (payment.rentalOrderCode ?? '').toLowerCase().contains(normalizedKeyword) ||
        (payment.companyName ?? '').toLowerCase().contains(normalizedKeyword) ||
        (payment.transactionCode ?? '').toLowerCase().contains(normalizedKeyword);

    final matchesMethod =
        selectedMethod == 'all' || payment.method == selectedMethod;

    return matchesKeyword && matchesMethod;
  }

  Future<void> _showAdjustmentDialog(AdminPayment payment) async {
    final adjusted = await showDialog<bool>(
      context: context,
      builder: (context) => _PaymentAdjustmentDialog(
        apiService: _apiService,
        payment: payment,
      ),
    );
    if (adjusted != true || !mounted) return;

    _reload();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã ghi nhận điều chỉnh thanh toán.')),
    );
  }
}

class _HeaderPanel extends StatelessWidget {
  final List<AdminPayment> payments;
  final String selectedMethod;
  final ValueChanged<String> onMethodChanged;
  final ValueChanged<String> onKeywordChanged;

  const _HeaderPanel({
    required this.payments,
    required this.selectedMethod,
    required this.onMethodChanged,
    required this.onKeywordChanged,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.decimalPattern('vi');
    final total = payments.fold<double>(0, (sum, item) => sum + item.amount);

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
            'Thanh toán',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tổng tiền đã ghi nhận: ${currency.format(total)} đ',
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Tìm theo hóa đơn, đơn thuê, đơn vị hoặc mã giao dịch',
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
                label: 'Tất cả ${payments.length}',
                selected: selectedMethod == 'all',
                onTap: () => onMethodChanged('all'),
              ),
              _FilterChip(
                label: 'Tiền mặt ${_count('tien_mat')}',
                selected: selectedMethod == 'tien_mat',
                onTap: () => onMethodChanged('tien_mat'),
                color: const Color(0xFF059669),
              ),
              _FilterChip(
                label: 'Chuyển khoản ${_count('chuyen_khoan')}',
                selected: selectedMethod == 'chuyen_khoan',
                onTap: () => onMethodChanged('chuyen_khoan'),
                color: const Color(0xFF2563EB),
              ),
              _FilterChip(
                label: 'Ví điện tử ${_count('vi_dien_tu')}',
                selected: selectedMethod == 'vi_dien_tu',
                onTap: () => onMethodChanged('vi_dien_tu'),
                color: const Color(0xFF7C3AED),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _count(String method) {
    return payments.where((payment) => payment.method == method).length;
  }
}

class _PaymentCard extends StatelessWidget {
  final AdminPayment payment;
  final VoidCallback? onAdjust;

  const _PaymentCard({required this.payment, this.onAdjust});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.decimalPattern('vi');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final color = payment.isAdjustment
        ? const Color(0xFFDC2626)
        : _methodColor(payment.method);

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
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_methodIcon(payment.method), color: color),
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
                        '${currency.format(payment.amount)} đ',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    _Badge(
                      label: payment.isAdjustment
                          ? 'Điều chỉnh'
                          : _methodText(payment.method),
                      color: color,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${payment.invoiceCode ?? 'Không mã hóa đơn'} • ${payment.companyName ?? 'Không đơn vị'}',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoPill(
                      icon: Icons.schedule_rounded,
                      label: dateFormat.format(payment.paidAt),
                    ),
                    if (payment.transactionCode != null &&
                        payment.transactionCode!.trim().isNotEmpty)
                      _InfoPill(
                        icon: Icons.confirmation_number_rounded,
                        label: payment.transactionCode!,
                      ),
                  ],
                ),
                if (payment.note != null && payment.note!.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    payment.note!,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
                if (onAdjust != null) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: onAdjust,
                    icon: const Icon(Icons.edit_note_rounded),
                    label: const Text('Điều chỉnh giao dịch'),
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

class _PaymentAdjustmentDialog extends StatefulWidget {
  final AdminApiService apiService;
  final AdminPayment payment;

  const _PaymentAdjustmentDialog({
    required this.apiService,
    required this.payment,
  });

  @override
  State<_PaymentAdjustmentDialog> createState() =>
      _PaymentAdjustmentDialogState();
}

class _PaymentAdjustmentDialogState extends State<_PaymentAdjustmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.decimalPattern('vi');
    return AlertDialog(
      title: const Text('Điều chỉnh thanh toán'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Giao dịch #${widget.payment.id}: '
                '${currency.format(widget.payment.amount)} đ',
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Số tiền cần điều chỉnh',
                  suffixText: 'đ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final amount = _parseAmount(value);
                  if (amount == null || amount <= 0) {
                    return 'Nhập số tiền lớn hơn 0';
                  }
                  if (amount > widget.payment.amount) {
                    return 'Không vượt quá giao dịch ban đầu';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _reasonController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Lý do điều chỉnh',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value ?? '').trim().isEmpty
                    ? 'Vui lòng nhập lý do'
                    : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: Text(_saving ? 'Đang lưu...' : 'Xác nhận'),
        ),
      ],
    );
  }

  double? _parseAmount(String? value) {
    return double.tryParse(
      (value ?? '').replaceAll('.', '').replaceAll(',', ''),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.apiService.adjustPayment(
        paymentId: widget.payment.id,
        amount: _parseAmount(_amountController.text)!,
        reason: _reasonController.text.trim(),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }
}

class _CreatePaymentSheet extends StatefulWidget {
  final AdminApiService apiService;
  final VoidCallback onCreated;

  const _CreatePaymentSheet({
    required this.apiService,
    required this.onCreated,
  });

  @override
  State<_CreatePaymentSheet> createState() => _CreatePaymentSheetState();
}

class _CreatePaymentSheetState extends State<_CreatePaymentSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _transactionController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  late Future<List<dynamic>> _dataFuture;
  AdminRentalOrder? _selectedOrder;
  AdminInvoice? _selectedInvoice;
  String _method = 'chuyen_khoan';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _dataFuture = Future.wait([
      widget.apiService.getRentalOrders(),
      widget.apiService.getInvoices(),
    ]);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _transactionController.dispose();
    _noteController.dispose();
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
      child: FutureBuilder<List<dynamic>>(
        future: _dataFuture,
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
                child: Text('Không tải được dữ liệu thanh toán: ${snapshot.error}'),
              ),
            );
          }

          final data = snapshot.data ?? const [];
          final orders = data.isNotEmpty
              ? List<AdminRentalOrder>.from(data[0] as List)
              : <AdminRentalOrder>[];
          final invoices = data.length > 1
              ? List<AdminInvoice>.from(data[1] as List)
              : <AdminInvoice>[];
          const payableStatuses = {
            'da_duyet',
            'dang_thue',
            'yeu_cau_tra',
            'hoan_thanh',
            'qua_han',
          };
          final payableOrders = orders.where((order) {
            if (!payableStatuses.contains(order.status)) return false;
            for (final invoice in invoices) {
              if (invoice.rentalOrderId == order.id &&
                  invoice.status != 'huy' &&
                  (invoice.status == 'da_thanh_toan' ||
                      invoice.remainingAmount <= 0)) {
                return false;
              }
            }
            return true;
          }).toList();

          if (payableOrders.isEmpty) {
            return const SizedBox(
              height: 220,
              child: Center(
                child: Text(
                  'Không có đơn thuê nào cần ghi nhận thanh toán.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ghi nhận thanh toán',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<AdminRentalOrder>(
                    value: _selectedOrder,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Đơn thuê',
                      border: OutlineInputBorder(),
                    ),
                    items: payableOrders
                        .map(
                          (order) => DropdownMenuItem(
                            value: order,
                            child: Text(
                              '${order.code} • ${order.companyName ?? 'Không đơn vị'}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    validator: (value) {
                      if (value == null) return 'Chọn đơn thuê';
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _selectedOrder = value;
                        _selectedInvoice = null;
                        if (value != null) {
                          for (final invoice in invoices) {
                            if (invoice.rentalOrderId == value.id &&
                                invoice.status != 'huy') {
                              _selectedInvoice = invoice;
                              break;
                            }
                          }
                          final remaining = _selectedInvoice?.remainingAmount ??
                              value.grandTotal;
                          _amountController.text = remaining.toStringAsFixed(0);
                        }
                      });
                    },
                  ),
                  if (_selectedOrder != null) ...[
                    const SizedBox(height: 8),
                    _PaymentSummary(
                      order: _selectedOrder!,
                      remainingAmount: _selectedInvoice?.remainingAmount ??
                          _selectedOrder!.grandTotal,
                    ),
                  ],
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _method,
                    decoration: const InputDecoration(
                      labelText: 'Phương thức',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'tien_mat',
                        child: Text('Tiền mặt'),
                      ),
                      DropdownMenuItem(
                        value: 'chuyen_khoan',
                        child: Text('Chuyển khoản'),
                      ),
                      DropdownMenuItem(
                        value: 'vi_dien_tu',
                        child: Text('Ví điện tử'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _method = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Số tiền',
                      suffixText: 'đ',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final amount = double.tryParse(value?.trim() ?? '');
                      if (amount == null || amount <= 0) {
                        return 'Số tiền không hợp lệ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _transactionController,
                    decoration: const InputDecoration(
                      labelText: 'Mã giao dịch',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _noteController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Ghi chú',
                      border: OutlineInputBorder(),
                    ),
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
                      label: const Text('Ghi nhận'),
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.apiService.createPayment(
        rentalOrderId: _selectedOrder!.id,
        amount: double.parse(_amountController.text.trim()),
        method: _method,
        transactionCode: _transactionController.text.trim().isEmpty
            ? null
            : _transactionController.text.trim(),
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );
      if (!mounted) return;
      widget.onCreated();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ghi nhận thất bại: $error')),
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

class _PaymentSummary extends StatelessWidget {
  final AdminRentalOrder order;
  final double remainingAmount;

  const _PaymentSummary({
    required this.order,
    required this.remainingAmount,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.decimalPattern('vi');

    Widget row(String label, double value, {Color? color}) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                ),
              ),
            ),
            Text(
              '${currency.format(value)} đ',
              style: TextStyle(
                color: color ?? const Color(0xFF0F172A),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          row('Tiền thuê', order.rentalTotal),
          row('Tiền đặt cọc', order.depositTotal),
          row(
            'Tiền hư hỏng',
            order.compensationTotal,
            color: order.compensationTotal > 0
                ? const Color(0xFFDC2626)
                : null,
          ),
          const Divider(height: 14),
          row(
            'Còn phải thanh toán',
            remainingAmount,
            color: const Color(0xFF1D4ED8),
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
          'Chưa có thanh toán phù hợp với bộ lọc hiện tại.',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      ),
    );
  }
}

String _methodText(String method) {
  switch (method) {
    case 'tien_mat':
      return 'Tiền mặt';
    case 'chuyen_khoan':
      return 'Chuyển khoản';
    case 'vi_dien_tu':
      return 'Ví điện tử';
    default:
      return method;
  }
}

Color _methodColor(String method) {
  switch (method) {
    case 'tien_mat':
      return const Color(0xFF059669);
    case 'chuyen_khoan':
      return const Color(0xFF2563EB);
    case 'vi_dien_tu':
      return const Color(0xFF7C3AED);
    default:
      return const Color(0xFF64748B);
  }
}

IconData _methodIcon(String method) {
  switch (method) {
    case 'tien_mat':
      return Icons.payments_rounded;
    case 'chuyen_khoan':
      return Icons.account_balance_rounded;
    case 'vi_dien_tu':
      return Icons.account_balance_wallet_rounded;
    default:
      return Icons.payment_rounded;
  }
}
