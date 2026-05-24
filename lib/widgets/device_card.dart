import 'package:flutter/material.dart';

import '../models/device.dart';

class DeviceCardModern extends StatelessWidget {
  final Device device;

  const DeviceCardModern({super.key, required this.device});

  Color getColor() {
    switch (device.status) {
      case 'available':
        return const Color(0xFF059669);
      case 'rented':
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFFEA580C);
    }
  }

  String getText() {
    switch (device.status) {
      case 'available':
        return 'Sẵn sàng';
      case 'rented':
        return 'Đang cho thuê';
      default:
        return 'Bảo trì';
    }
  }

  IconData getStatusIcon() {
    switch (device.status) {
      case 'available':
        return Icons.check_circle_rounded;
      case 'rented':
        return Icons.assignment_turned_in_rounded;
      default:
        return Icons.build_circle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = getColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                device.image,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    device.brand,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              getStatusIcon(),
                              size: 16,
                              color: statusColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              getText(),
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Cập nhật gần đây',
                          style: TextStyle(
                            color: Color(0xFF475569),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
