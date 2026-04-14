import 'package:flutter/material.dart';
import '../../core/widgets/equipment_card.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data
    final List<Map<String, dynamic>> availableEquipments = [
      {
        'name': 'ThinkPad T14 Gen 3',
        'price': 150000.0,
        'cpu': 'Core i7-12700H', 'ram': '16GB', 'ssd': '512GB SSD',
        'display': '14" FHD+', 'gpu': 'Iris Xe',
        'image': 'assets/images/Lap1.jpg'
      },
      {
        'name': 'MacBook Pro M2',
        'price': 250000.0,
        'cpu': 'Apple M2', 'ram': '8GB', 'ssd': '256GB SSD',
        'display': '13.3" Retina', 'gpu': '8-core GPU',
        'image': 'assets/images/Lap1.jpg'
      },
      {
        'name': 'Dell XPS 13 Plus',
        'price': 180000.0,
        'cpu': 'Core i5-1240P', 'ram': '16GB', 'ssd': '512GB SSD',
        'display': '13.4" 3.5K OLED', 'gpu': 'Iris Xe',
        'image': 'assets/images/Lap1.jpg'
      },
      {
        'name': 'Alienware m15 R7',
        'price': 300000.0,
        'cpu': 'Core i7-12700H', 'ram': '32GB', 'ssd': '1TB SSD',
        'display': '15.6" 2K 240Hz', 'gpu': 'RTX 3070 Ti',
        'image': 'assets/images/Lap1.jpg'
      },
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. Banner giới thiệu
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            actions: [
              IconButton(
                icon: const Badge(
                  label: Text('2'),
                  child: Icon(Icons.shopping_cart, color: Colors.white),
                ),
                onPressed: () {},
              ),
            ],
            // FIXED: Phải có FlexibleSpaceBar bọc quanh background
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/banner.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.teal.shade700,
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 50, color: Colors.white54),
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Tiêu đề
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Text(
                'Máy sẵn sàng cho thuê',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // 3. Grid Danh sách máy
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                childAspectRatio: 0.48,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  final item = availableEquipments[index];
                  return EquipmentCard(
                    name: item['name'],
                    price: item['price'],
                    cpu: item['cpu'],
                    ram: item['ram'],
                    ssd: item['ssd'],
                    display: item['display'],
                    gpu: item['gpu'],
                    imagePath: item['image'],
                    onDetailsPressed: () {},
                    onAddToCart: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đã thêm ${item['name']} vào yêu cầu!')),
                      );
                    },
                  );
                },
                childCount: availableEquipments.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}