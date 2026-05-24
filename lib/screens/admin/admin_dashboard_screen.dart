import 'package:flutter/material.dart';
import 'package:nhom6_detai5_doancuoiki/widgets/admin_navigation_drawer.dart';
import 'package:nhom6_detai5_doancuoiki/widgets/stat_card.dart';


class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  static const _stats = [
    (
      title: 'Tổng thiết bị',
      value: '120',
      icon: Icons.devices_rounded,
      startColor: Color(0xFF1D4ED8),
      endColor: Color(0xFF60A5FA),
      caption: '+12%',
    ),
    (
      title: 'Đang cho thuê',
      value: '60',
      icon: Icons.assignment_turned_in_rounded,
      startColor: Color.fromARGB(255, 58, 58, 237),
      endColor: Color(0xFFA78BFA),
      caption: 'On track',
    ),
    (
      title: 'Bảo trì',
      value: '10',
      icon: Icons.build_rounded,
      startColor: Color(0xFFEA580C),
      endColor: Color(0xFFF59E0B),
      caption: 'Cần xử lý',
    ),
    (
      title: 'Sẵn sàng',
      value: '50',
      icon: Icons.check_circle_rounded,
      startColor: Color(0xFF059669),
      endColor: Color(0xFF34D399),
      caption: 'Tốt',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      appBar: AppBar(
        title: const Text('Trang quản trị'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF0F172A),
      ),
      drawer: const AdminNavigationDrawer(
        currentSection: AdminSection.dashboard,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withOpacity(0.05),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
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
                  SizedBox(height: 10),
                  Text(
                    'Theo dõi nhanh tình trạng thiết bị, lịch sử cho thuê và các thông báo quan trọng ngay tại đây.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 900
                    ? 4
                    : constraints.maxWidth > 640
                        ? 3
                        : 2;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _stats.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.05,
                  ),
                  itemBuilder: (context, index) {
                    final stat = _stats[index];
                    return StatCard(
                      title: stat.title,
                      value: stat.value,
                      icon: stat.icon,
                      startColor: stat.startColor,
                      endColor: stat.endColor,
                      caption: stat.caption,
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withOpacity(0.05),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Nhắc việc',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E7FF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          '2 mục',
                          style: TextStyle(
                            color: Color(0xFF3730A3),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const _ReminderTile(
                    icon: Icons.warning_amber_rounded,
                    iconColor: Color(0xFFEA580C),
                    title: 'Macbook sắp đến hạn trả',
                    subtitle:
                        'Cần nhắc người thuê trước 1 ngày để tránh trễ hạn.',
                  ),
                  const SizedBox(height: 12),
                  const _ReminderTile(
                    icon: Icons.build_circle_outlined,
                    iconColor: Color(0xFF2563EB),
                    title: 'HP Pavilion cần bảo trì',
                    subtitle:
                        'Lịch bảo trì định kì.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _ReminderTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
