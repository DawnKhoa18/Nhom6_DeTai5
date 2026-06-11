import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_dashboard.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_rental_order.dart';
import 'package:nhom6_detai5_doancuoiki/screens/admin/device_management_screen.dart';
import 'package:nhom6_detai5_doancuoiki/screens/admin/maintenance_management_screen.dart';
import 'package:nhom6_detai5_doancuoiki/screens/admin/rental_orders_screen_admin.dart';
import 'package:nhom6_detai5_doancuoiki/services/admin_api_service.dart';
import 'package:nhom6_detai5_doancuoiki/widgets/admin_navigation_drawer.dart';
import 'package:nhom6_detai5_doancuoiki/widgets/stat_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminApiService _apiService = const AdminApiService();
  late Future<AdminDashboard> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _apiService.getDashboard();
  }

  void _reload() {
    setState(() {
      _dashboardFuture = _apiService.getDashboard();
    });
  }

  void _openScreen(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _openReminder(DashboardReminder reminder) async {
    if (reminder.type == 'rental_due') {
      try {
        final orders = await _apiService.getRentalOrders();
        AdminRentalOrder? selected;
        for (final order in orders) {
          if (order.id == reminder.id) {
            selected = order;
            break;
          }
        }
        if (!mounted) return;
        if (selected == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không tìm thấy đơn thuê cần mở.')),
          );
          return;
        }
        _openScreen(RentalOrderDetailScreen(order: selected));
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không mở được đơn thuê: $error')),
        );
      }
      return;
    }

    final assetCode = reminder.title;
    if (reminder.status == 'bao_tri') {
      _openScreen(
        MaintenanceManagementScreen(
          initialKeyword: assetCode,
          initialStatus: 'dang_bao_tri',
        ),
      );
    } else {
      _openScreen(
        DeviceManagementScreen(
          initialKeyword: assetCode,
          initialStatus: reminder.status ?? 'all',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      appBar: AppBar(
        title: const Text('Trang quản trị'),
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
        currentSection: AdminSection.dashboard,
      ),
      body: FutureBuilder<AdminDashboard>(
        future: _dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErrorState(
              message: 'Không tải được dữ liệu dashboard.',
              detail: snapshot.error.toString(),
              onRetry: _reload,
            );
          }

          final dashboard = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _HeroPanel(),
                  const SizedBox(height: 18),
                  _StatsGrid(
                    dashboard: dashboard,
                    onAllDevices: () =>
                        _openScreen(const DeviceManagementScreen()),
                    onRentedDevices: () => _openScreen(
                      const DeviceManagementScreen(initialStatus: 'dang_thue'),
                    ),
                    onMaintenanceDevices: () => _openScreen(
                      const MaintenanceManagementScreen(
                        initialStatus: 'dang_bao_tri',
                      ),
                    ),
                    onAvailableDevices: () => _openScreen(
                      const DeviceManagementScreen(initialStatus: 'san_sang'),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _StatusAndRevenuePanel(dashboard: dashboard),
                  const SizedBox(height: 18),
                  _ReminderPanel(
                    dashboard: dashboard,
                    onReminderTap: _openReminder,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tổng quan hệ thống',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Theo dõi tình trạng thiết bị, doanh thu và các việc cần xử lý.',
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final AdminDashboard dashboard;
  final VoidCallback onAllDevices;
  final VoidCallback onRentedDevices;
  final VoidCallback onMaintenanceDevices;
  final VoidCallback onAvailableDevices;

  const _StatsGrid({
    required this.dashboard,
    required this.onAllDevices,
    required this.onRentedDevices,
    required this.onMaintenanceDevices,
    required this.onAvailableDevices,
  });

  @override
  Widget build(BuildContext context) {
    final stats = [
      (
        title: 'Tổng thiết bị',
        value: '${dashboard.overview.totalDevices}',
        icon: Icons.devices_rounded,
        startColor: const Color(0xFF1D4ED8),
        endColor: const Color(0xFF60A5FA),
        caption: 'Trong kho',
        onTap: onAllDevices,
      ),
      (
        title: 'Đang cho thuê',
        value: '${dashboard.overview.rentedDevices}',
        icon: Icons.assignment_turned_in_rounded,
        startColor: const Color(0xFF4F46E5),
        endColor: const Color(0xFFA78BFA),
        caption: 'Đang chạy',
        onTap: onRentedDevices,
      ),
      (
        title: 'Bảo trì',
        value: '${dashboard.overview.maintenanceDevices}',
        icon: Icons.build_rounded,
        startColor: const Color(0xFFEA580C),
        endColor: const Color(0xFFF59E0B),
        caption: 'Cần xử lý',
        onTap: onMaintenanceDevices,
      ),
      (
        title: 'Sẵn sàng',
        value: '${dashboard.overview.availableDevices}',
        icon: Icons.check_circle_rounded,
        startColor: const Color(0xFF059669),
        endColor: const Color(0xFF34D399),
        caption: 'Có thể thuê',
        onTap: onAvailableDevices,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 4
            : constraints.maxWidth > 640
                ? 3
                : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stats.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (context, index) {
            final stat = stats[index];
            return StatCard(
              title: stat.title,
              value: stat.value,
              icon: stat.icon,
              startColor: stat.startColor,
              endColor: stat.endColor,
              caption: stat.caption,
              onTap: stat.onTap,
            );
          },
        );
      },
    );
  }
}

class _StatusAndRevenuePanel extends StatelessWidget {
  final AdminDashboard dashboard;

  const _StatusAndRevenuePanel({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.decimalPattern('vi');
    final revenue = dashboard.monthlyRevenue.isEmpty
        ? 0.0
        : dashboard.monthlyRevenue.last.revenue;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 720;
        final children = [
          Expanded(
            flex: isWide ? 1 : 0,
            child: _Panel(
              title: 'Tình trạng thiết bị',
              child: Column(
                children: dashboard.deviceStatus.isEmpty
                    ? [
                        const _MutedText('Chưa có dữ liệu trạng thái.'),
                      ]
                    : dashboard.deviceStatus
                        .map(
                          (item) => _StatusRow(
                            label: _statusText(item.status),
                            count: item.count,
                            total: dashboard.overview.totalDevices,
                            color: _statusColor(item.status),
                          ),
                        )
                        .toList(),
              ),
            ),
          ),
          SizedBox(width: isWide ? 14 : 0, height: isWide ? 0 : 14),
          Expanded(
            flex: isWide ? 1 : 0,
            child: _Panel(
              title: 'Doanh thu gần nhất',
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.payments_rounded,
                      color: Color(0xFF1D4ED8),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${currency.format(revenue)} đ',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Theo hóa đơn trong dữ liệu hiện tại',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ];

        return isWide
            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: children)
            : Column(children: children);
      },
    );
  }

  static String _statusText(String status) {
    switch (status) {
      case 'san_sang':
        return 'Sẵn sàng';
      case 'dang_thue':
        return 'Đang thuê';
      case 'bao_tri':
        return 'Bảo trì';
      case 'hong':
        return 'Hỏng';
      case 'ngung_kinh_doanh':
        return 'Ngừng kinh doanh';
      default:
        return status;
    }
  }

  static Color _statusColor(String status) {
    switch (status) {
      case 'san_sang':
        return const Color(0xFF059669);
      case 'dang_thue':
        return const Color(0xFF2563EB);
      case 'bao_tri':
        return const Color(0xFFEA580C);
      case 'hong':
      case 'ngung_kinh_doanh':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF64748B);
    }
  }
}

class _ReminderPanel extends StatelessWidget {
  final AdminDashboard dashboard;
  final ValueChanged<DashboardReminder> onReminderTap;

  const _ReminderPanel({
    required this.dashboard,
    required this.onReminderTap,
  });

  @override
  Widget build(BuildContext context) {
    final reminders = dashboard.reminders;

    return _Panel(
      title: 'Nhắc việc',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFE0E7FF),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          '${reminders.length} mục',
          style: const TextStyle(
            color: Color(0xFF3730A3),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      child: reminders.isEmpty
          ? const _MutedText('Chưa có nhắc việc cần xử lý.')
          : Column(
              children: reminders
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ReminderTile(
                        reminder: item,
                        onTap: () => onReminderTap(item),
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _Panel extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _Panel({
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _StatusRow({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : count / total;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334155),
                  ),
                ),
              ),
              Text(
                '$count',
                style: TextStyle(color: color, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: progress,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  final DashboardReminder reminder;
  final VoidCallback onTap;

  const _ReminderTile({required this.reminder, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDevice = reminder.type == 'device_attention';
    final iconColor = isDevice ? const Color(0xFFEA580C) : const Color(0xFF2563EB);
    final title = isDevice ? reminder.deviceName ?? reminder.title : reminder.title;
    final subtitle = isDevice
        ? 'Thiết bị cần kiểm tra: ${reminder.status ?? ''}'
        : 'Hạn dự kiến: ${_formatDate(reminder.dueDate)}';

    return Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isDevice
                  ? Icons.build_circle_outlined
                  : Icons.warning_amber_rounded,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
            ),
          ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Chưa cập nhật';
    return DateFormat('dd/MM/yyyy').format(date);
  }
}

class _MutedText extends StatelessWidget {
  final String text;

  const _MutedText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(color: Color(0xFF64748B)),
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
