import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_rental_order.dart';
import 'package:nhom6_detai5_doancuoiki/services/admin_api_service.dart';
import 'package:nhom6_detai5_doancuoiki/widgets/admin_navigation_drawer.dart';

class RentalOrdersScreen extends StatefulWidget {
  const RentalOrdersScreen({super.key});

  @override
  State<RentalOrdersScreen> createState() => _RentalOrdersScreenState();
}

class _RentalOrdersScreenState extends State<RentalOrdersScreen> {
  final AdminApiService _apiService = const AdminApiService();

  late Future<List<AdminRentalOrder>> _ordersFuture;
  String selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _ordersFuture = _apiService.getRentalOrders();
  }

  void _reload() {
    setState(() {
      _ordersFuture = _apiService.getRentalOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      appBar: AppBar(
        title: const Text('Quản lý đơn thuê'),
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
        currentSection: AdminSection.rentalOrders,
      ),
      body: FutureBuilder<List<AdminRentalOrder>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErrorState(
              message: 'Không tải được danh sách đơn thuê.',
              detail: snapshot.error.toString(),
              onRetry: _reload,
            );
          }

          final orders = snapshot.data ?? const [];
          final filtered = selectedStatus == 'all'
              ? orders
              : orders.where((order) => order.status == selectedStatus).toList();

          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _HeaderPanel(
                  orders: orders,
                  selectedStatus: selectedStatus,
                  onStatusChanged: (value) {
                    setState(() {
                      selectedStatus = value;
                    });
                  },
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Danh sách đơn thuê',
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
                    (order) => _RentalOrderCard(
                      order: order,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RentalOrderDetailScreen(order: order),
                          ),
                        );
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
}

class _HeaderPanel extends StatelessWidget {
  final List<AdminRentalOrder> orders;
  final String selectedStatus;
  final ValueChanged<String> onStatusChanged;

  const _HeaderPanel({
    required this.orders,
    required this.selectedStatus,
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
            'Đơn thuê',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Theo dõi yêu cầu thuê, trạng thái xử lý và danh sách máy trong từng đơn.',
            style: TextStyle(
              color: Color(0xFF475569),
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChip(
                label: 'Tất cả ${orders.length}',
                selected: selectedStatus == 'all',
                onTap: () => onStatusChanged('all'),
              ),
              _FilterChip(
                label: 'Chờ duyệt ${_count('cho_duyet')}',
                selected: selectedStatus == 'cho_duyet',
                onTap: () => onStatusChanged('cho_duyet'),
                color: const Color(0xFFFAAD14),
              ),
              _FilterChip(
                label: 'Đã duyệt ${_count('da_duyet')}',
                selected: selectedStatus == 'da_duyet',
                onTap: () => onStatusChanged('da_duyet'),
                color: const Color(0xFF2563EB),
              ),
              _FilterChip(
                label: 'Đang thuê ${_count('dang_thue')}',
                selected: selectedStatus == 'dang_thue',
                onTap: () => onStatusChanged('dang_thue'),
                color: const Color(0xFF4F46E5),
              ),
              _FilterChip(
                label: 'Hoàn thành ${_count('hoan_thanh')}',
                selected: selectedStatus == 'hoan_thanh',
                onTap: () => onStatusChanged('hoan_thanh'),
                color: const Color(0xFF059669),
              ),
              _FilterChip(
                label: 'Quá hạn ${_count('qua_han')}',
                selected: selectedStatus == 'qua_han',
                onTap: () => onStatusChanged('qua_han'),
                color: const Color(0xFFDC2626),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _count(String status) {
    return orders.where((order) => order.status == status).length;
  }
}

class _RentalOrderCard extends StatelessWidget {
  final AdminRentalOrder order;
  final VoidCallback onTap;

  const _RentalOrderCard({
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.decimalPattern('vi');
    final dateFormat = DateFormat('dd/MM/yyyy');
    final statusColor = _statusColor(order.status);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.companyName ?? 'Đơn vị chưa cập nhật',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.code,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(
                  label: _statusText(order.status),
                  color: statusColor,
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'Danh sách máy',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            ...order.devices.take(3).map(
                  (device) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '${device.assetCode ?? 'Không mã'} • ${device.displayName}',
                      style: const TextStyle(
                        color: Color(0xFF334155),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            if (order.devices.length > 3)
              Text(
                '+${order.devices.length - 3} thiết bị khác',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetaItem(
                    icon: Icons.date_range_rounded,
                    label:
                        '${dateFormat.format(order.startDate)} - ${dateFormat.format(order.expectedEndDate)}',
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${currency.format(order.grandTotal)} đ',
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
    );
  }
}

class RentalOrderDetailScreen extends StatelessWidget {
  final AdminRentalOrder order;

  const RentalOrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.decimalPattern('vi');
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      appBar: AppBar(
        title: const Text('Chi tiết đơn thuê'),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DetailSection(
            title: order.companyName ?? 'Đơn vị chưa cập nhật',
            children: [
              _InfoRow(label: 'Mã đơn', value: order.code),
              _InfoRow(label: 'Trạng thái', value: _statusText(order.status)),
              _InfoRow(
                label: 'Thời gian thuê',
                value:
                    '${dateFormat.format(order.startDate)} - ${dateFormat.format(order.expectedEndDate)}',
              ),
              if (order.purpose != null)
                _InfoRow(label: 'Mục đích', value: order.purpose!),
            ],
          ),
          const SizedBox(height: 14),
          _DetailSection(
            title: 'Thiết bị trong đơn',
            children: order.devices
                .map(
                  (device) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.laptop_mac_rounded,
                          size: 20,
                          color: Color(0xFF1D4ED8),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                device.displayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${device.assetCode ?? 'Không mã'} • ${device.rentalDays} ngày',
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${currency.format(device.lineTotal)} đ',
                          style: const TextStyle(
                            color: Color(0xFF1D4ED8),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 14),
          _DetailSection(
            title: 'Thanh toán',
            children: [
              _InfoRow(
                label: 'Tiền thuê',
                value: '${currency.format(order.rentalTotal)} đ',
              ),
              _InfoRow(
                label: 'Tiền đặt cọc',
                value: '${currency.format(order.depositTotal)} đ',
              ),
              _InfoRow(
                label: 'Tiền đền bù',
                value: '${currency.format(order.compensationTotal)} đ',
              ),
              const Divider(height: 22),
              _InfoRow(
                label: 'Tổng cộng',
                value: '${currency.format(order.grandTotal)} đ',
                bold: true,
              ),
            ],
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

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({
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

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DetailSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _InfoRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: const Color(0xFF0F172A),
                fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
              ),
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
          'Không có đơn thuê phù hợp với bộ lọc hiện tại.',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      ),
    );
  }
}

String _statusText(String status) {
  switch (status) {
    case 'cho_duyet':
      return 'Chờ duyệt';
    case 'da_duyet':
      return 'Đã duyệt';
    case 'dang_thue':
      return 'Đang thuê';
    case 'yeu_cau_tra':
      return 'Yêu cầu trả';
    case 'hoan_thanh':
      return 'Hoàn thành';
    case 'qua_han':
      return 'Quá hạn';
    case 'huy':
      return 'Hủy';
    case 'tu_choi':
      return 'Từ chối';
    default:
      return status;
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'cho_duyet':
      return const Color(0xFFFAAD14);
    case 'da_duyet':
      return const Color(0xFF2563EB);
    case 'dang_thue':
      return const Color(0xFF4F46E5);
    case 'hoan_thanh':
      return const Color(0xFF059669);
    case 'qua_han':
    case 'tu_choi':
    case 'huy':
      return const Color(0xFFDC2626);
    default:
      return const Color(0xFF64748B);
  }
}
