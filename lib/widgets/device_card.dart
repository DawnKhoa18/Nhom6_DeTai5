import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_device.dart';

class DeviceCardModern extends StatelessWidget {
  final AdminDevice device;

  const DeviceCardModern({super.key, required this.device});

  Color get _statusColor {
    switch (device.status) {
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

  String get _statusText {
    switch (device.status) {
      case 'san_sang':
        return 'Sẵn sàng';
      case 'dang_thue':
        return 'Đang cho thuê';
      case 'bao_tri':
        return 'Bảo trì';
      case 'hong':
        return 'Hỏng';
      case 'ngung_kinh_doanh':
        return 'Ngừng kinh doanh';
      default:
        return device.status;
    }
  }

  IconData get _statusIcon {
    switch (device.status) {
      case 'san_sang':
        return Icons.check_circle_rounded;
      case 'dang_thue':
        return Icons.assignment_turned_in_rounded;
      case 'bao_tri':
        return Icons.build_circle_rounded;
      case 'hong':
      case 'ngung_kinh_doanh':
        return Icons.error_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.decimalPattern('vi');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.laptop_mac_rounded, color: _statusColor),
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
                          device.displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _StatusBadge(
                        icon: _statusIcon,
                        label: _statusText,
                        color: _statusColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${device.assetCode} • ${device.type}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoPill(label: device.cpu ?? 'CPU chưa cập nhật'),
                      _InfoPill(label: device.ram ?? 'RAM chưa cập nhật'),
                      _InfoPill(label: device.storage ?? 'Ổ cứng chưa cập nhật'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${currency.format(device.dailyRentalPrice)} đ/ngày',
                          style: const TextStyle(
                            color: Color(0xFF1D4ED8),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        'Cọc ${device.depositRate.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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

class _StatusBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatusBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;

  const _InfoPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF475569),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
