import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_contract.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_rental_order.dart';
import 'package:nhom6_detai5_doancuoiki/services/admin_api_service.dart';
import 'package:nhom6_detai5_doancuoiki/widgets/admin_navigation_drawer.dart';

class ContractManagementScreen extends StatefulWidget {
  const ContractManagementScreen({super.key});

  @override
  State<ContractManagementScreen> createState() =>
      _ContractManagementScreenState();
}

class _ContractManagementScreenState extends State<ContractManagementScreen> {
  final AdminApiService _api = const AdminApiService();
  late Future<List<AdminContract>> _future;
  String status = 'all';
  String keyword = '';

  @override
  void initState() {
    super.initState();
    _future = _api.getContracts();
  }

  void _reload() {
    setState(() => _future = _api.getContracts());
  }

  void _showCreateForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => _CreateContractSheet(
        api: _api,
        onCreated: () {
          Navigator.pop(sheetContext);
          _reload();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã tạo hợp đồng.')),
          );
        },
      ),
    );
  }

  Future<void> _changeStatus(AdminContract contract, String nextStatus) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cập nhật trạng thái hợp đồng?'),
        content: Text('Trạng thái mới: ' + _statusText(nextStatus)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _api.updateContractStatus(contract.id, nextStatus);
      if (!mounted) return;
      _reload();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật hợp đồng.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật thất bại: ' + error.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      appBar: AppBar(
        title: const Text('Quản lý hợp đồng'),
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
        currentSection: AdminSection.contracts,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateForm,
        backgroundColor: const Color(0xFF1D4ED8),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tạo hợp đồng'),
      ),
      body: FutureBuilder<List<AdminContract>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorView(detail: snapshot.error.toString(), retry: _reload);
          }
          final contracts = snapshot.data ?? const [];
          final filtered = contracts.where(_matches).toList();
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              children: [
                _Header(
                  contracts: contracts,
                  status: status,
                  onStatus: (value) => setState(() => status = value),
                  onSearch: (value) => setState(() => keyword = value),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Danh sách hợp đồng',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Text(
                      filtered.length.toString() + ' mục',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (filtered.isEmpty)
                  const _EmptyView()
                else
                  ...filtered.map(
                    (item) => _ContractCard(
                      contract: item,
                      onStatus: (value) => _changeStatus(item, value),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _matches(AdminContract contract) {
    final search = keyword.trim().toLowerCase();
    final textMatch = search.isEmpty ||
        contract.code.toLowerCase().contains(search) ||
        contract.rentalOrderCode.toLowerCase().contains(search) ||
        contract.companyName.toLowerCase().contains(search);
    return textMatch && (status == 'all' || contract.status == status);
  }
}

class _CreateContractSheet extends StatefulWidget {
  final AdminApiService api;
  final VoidCallback onCreated;

  const _CreateContractSheet({required this.api, required this.onCreated});

  @override
  State<_CreateContractSheet> createState() => _CreateContractSheetState();
}

class _CreateContractSheetState extends State<_CreateContractSheet> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController fileController = TextEditingController();
  late Future<List<AdminRentalOrder>> ordersFuture;
  AdminRentalOrder? selectedOrder;
  DateTime createdDate = DateTime.now();
  bool submitting = false;

  @override
  void initState() {
    super.initState();
    ordersFuture = widget.api.getRentalOrders();
  }

  @override
  void dispose() {
    codeController.dispose();
    contentController.dispose();
    fileController.dispose();
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
      child: FutureBuilder<List<AdminRentalOrder>>(
        future: ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 220,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final orders = (snapshot.data ?? const [])
              .where(
                (item) =>
                    item.status == 'da_duyet' ||
                    item.status == 'dang_thue' ||
                    item.status == 'qua_han',
              )
              .toList();
          return Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tạo hợp đồng',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<AdminRentalOrder>(
                    value: selectedOrder,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Đơn thuê',
                      border: OutlineInputBorder(),
                    ),
                    items: orders
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(
                              item.code + ' • ' + (item.companyName ?? ''),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    validator: (value) =>
                        value == null ? 'Chọn đơn thuê' : null,
                    onChanged: (value) => setState(() => selectedOrder = value),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: codeController,
                    decoration: const InputDecoration(
                      labelText: 'Mã hợp đồng',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nhập mã hợp đồng';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Ngày lập',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(DateFormat('dd/MM/yyyy').format(createdDate)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: contentController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Nội dung hợp đồng',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: fileController,
                    decoration: const InputDecoration(
                      labelText: 'URL file hợp đồng',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: submitting ? null : _submit,
                      icon: submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_rounded),
                      label: const Text('Tạo hợp đồng'),
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: createdDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => createdDate = picked);
  }

  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => submitting = true);
    try {
      await widget.api.createContract(
        rentalOrderId: selectedOrder!.id,
        code: codeController.text.trim(),
        createdDate: createdDate,
        content: contentController.text.trim(),
        fileUrl: fileController.text.trim(),
      );
      if (!mounted) return;
      widget.onCreated();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tạo thất bại: ' + error.toString())),
      );
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }
}

class _Header extends StatelessWidget {
  final List<AdminContract> contracts;
  final String status;
  final ValueChanged<String> onStatus;
  final ValueChanged<String> onSearch;

  const _Header({
    required this.contracts,
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
            'Hợp đồng thuê thiết bị',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Theo dõi nội dung, file đính kèm và hiệu lực hợp đồng.',
            style: TextStyle(color: Color(0xFF475569)),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Tìm theo mã hợp đồng, đơn thuê hoặc đơn vị',
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
              _Chip(
                label: 'Tất cả ' + contracts.length.toString(),
                selected: status == 'all',
                onTap: () => onStatus('all'),
              ),
              _Chip(
                label: 'Hiệu lực ' + _count('hieu_luc').toString(),
                selected: status == 'hieu_luc',
                color: const Color(0xFF059669),
                onTap: () => onStatus('hieu_luc'),
              ),
              _Chip(
                label: 'Hết hiệu lực ' + _count('het_hieu_luc').toString(),
                selected: status == 'het_hieu_luc',
                color: const Color(0xFF64748B),
                onTap: () => onStatus('het_hieu_luc'),
              ),
              _Chip(
                label: 'Đã hủy ' + _count('huy').toString(),
                selected: status == 'huy',
                color: const Color(0xFFDC2626),
                onTap: () => onStatus('huy'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _count(String value) =>
      contracts.where((item) => item.status == value).length;
}

class _ContractCard extends StatelessWidget {
  final AdminContract contract;
  final ValueChanged<String> onStatus;

  const _ContractCard({required this.contract, required this.onStatus});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd/MM/yyyy');
    final money = NumberFormat.decimalPattern('vi');
    final color = _statusColor(contract.status);
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
              Icon(Icons.description_rounded, color: color, size: 34),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contract.code,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      contract.rentalOrderCode + ' • ' + contract.companyName,
                      style: const TextStyle(color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: onStatus,
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'hieu_luc', child: Text('Hiệu lực')),
                  PopupMenuItem(
                    value: 'het_hieu_luc',
                    child: Text('Hết hiệu lực'),
                  ),
                  PopupMenuItem(value: 'huy', child: Text('Hủy hợp đồng')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Ngày lập: ' + date.format(contract.createdDate),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          if (contract.content?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(contract.content!),
          ],
          const SizedBox(height: 10),
          Text(
            'Tổng giá trị: ' +
                money.format(
                  contract.rentalAmount +
                      contract.depositAmount +
                      contract.compensationAmount,
                ) +
                ' đ',
            style: TextStyle(color: color, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: contract.devices
                .map(
                  (item) => Chip(
                    label: Text(item.assetCode + ' • ' + item.deviceName),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color = const Color(0xFF1D4ED8),
  });
  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      backgroundColor:
          selected ? color.withOpacity(0.12) : const Color(0xFFF1F5F9),
      label: Text(label, style: TextStyle(color: selected ? color : null)),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Không tải được danh sách hợp đồng.'),
          Text(detail, textAlign: TextAlign.center),
          FilledButton(onPressed: retry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Chưa có hợp đồng phù hợp.'));
  }
}

String _statusText(String value) {
  switch (value) {
    case 'hieu_luc':
      return 'Hiệu lực';
    case 'het_hieu_luc':
      return 'Hết hiệu lực';
    case 'huy':
      return 'Đã hủy';
    default:
      return value;
  }
}

Color _statusColor(String value) {
  if (value == 'hieu_luc') return const Color(0xFF059669);
  if (value == 'huy') return const Color(0xFFDC2626);
  return const Color(0xFF64748B);
}
