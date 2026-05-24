import 'package:flutter/material.dart';
import 'package:nhom6_detai5_doancuoiki/models/device.dart';
import 'package:nhom6_detai5_doancuoiki/widgets/admin_navigation_drawer.dart';
import 'package:nhom6_detai5_doancuoiki/widgets/device_card.dart';


class DeviceManagementScreen extends StatefulWidget {
  const DeviceManagementScreen({super.key});

  @override
  State<DeviceManagementScreen> createState() => _DeviceManagementScreenState();
}

class _DeviceManagementScreenState extends State<DeviceManagementScreen> {
  final List<Device> devices = [
    Device(
      name: 'Dell XPS 13',
      brand: 'Dell',
      status: 'available',
      image: 'https://picsum.photos/240?1',
    ),
    Device(
      name: 'Macbook Pro',
      brand: 'Apple',
      status: 'rented',
      image: 'https://picsum.photos/240?2',
    ),
    Device(
      name: 'HP Pavilion',
      brand: 'HP',
      status: 'maintenance',
      image: 'https://picsum.photos/240?3',
    ),
  ];

  String keyword = '';

  @override
  Widget build(BuildContext context) {
    final filtered = devices
        .where((device) =>
            device.name.toLowerCase().contains(keyword.toLowerCase()) ||
            device.brand.toLowerCase().contains(keyword.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      appBar: AppBar(
        title: const Text('Quản lý thiết bị'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF0F172A),
      ),
      drawer: const AdminNavigationDrawer(
        currentSection: AdminSection.devices,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xFF1D4ED8),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm thiết bị'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          Container(
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
                const Text(
                  'Kho thiết bị',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Tìm kiếm nhanh, xem tình trạng hiện tại.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm theo tên hoặc thương hiệu',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      keyword = value;
                    });
                  },
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _SummaryChip(
                      label: 'Tổng ${devices.length}',
                      background: const Color(0xFFDBEAFE),
                      foreground: const Color(0xFF1D4ED8),
                    ),
                    _SummaryChip(
                      label:
                          'Sẵn sàng ${devices.where((d) => d.status == 'available').length}',
                      background: const Color(0xFFD1FAE5),
                      foreground: const Color(0xFF059669),
                    ),
                    _SummaryChip(
                      label:
                          'Đang cho thuê ${devices.where((d) => d.status == 'rented').length}',
                      background: const Color(0xFFE0E7FF),
                      foreground: const Color(0xFF4F46E5),
                    ),
                    _SummaryChip(
                      label:
                          'Bảo trì ${devices.where((d) => d.status == 'maintenance').length}',
                      background: const Color(0xFFFFEDD5),
                      foreground: const Color(0xFFEA580C),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Danh sách thiết bị',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          const SizedBox(height: 14),
          ...filtered.map((device) => DeviceCardModern(device: device)),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const _SummaryChip({
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
