import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../widgets/equipment_card.dart';
import 'equipment_detail_screen.dart';
import 'cart_screen.dart';
import 'cart_manager.dart';
import 'package:nhom6_detai5_doancuoiki/services/api_config.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  List<dynamic> devices = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCatalog();
  }

  Future<void> fetchCatalog() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/user/UserDevices/catalog'),
      );
      if (response.statusCode == 200) {
        setState(() {
          devices = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Lỗi kết nối API Catalog: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Thiết bị cho thuê', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              background: Image.asset('assets/images/banner.png', fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(color: Colors.teal)),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen())),
              ),
            ],
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Danh sách máy sẵn sàng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          if (isLoading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: Colors.teal)))
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.52,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = devices[index];
                    return EquipmentCard(
                      id: item['id'],
                      name: item['name'],
                      price: (item['price'] as num).toDouble(),
                      cpu: item['cpu'] ?? '',
                      ram: item['ram'] ?? '',
                      ssd: item['ssd'] ?? '',
                      gpu: item['gpu'] ?? '',
                      display: item['display'] ?? '',
                      imagePath: _resolveImage(item['imageUrl']),
                      onDetailsPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => EquipmentDetailScreen(deviceId: item['id'])));
                      },
                      onAddToCart: () {
                        final added = CartManager.addToCart(
                          Map<String, dynamic>.from(item),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              added
                                  ? 'Đã thêm ${item['name']} vào giỏ'
                                  : 'Thiết bị đã có trong giỏ',
                            ),
                          ),
                        );
                      },
                    );
                  },
                  childCount: devices.length,
                ),
              ),
            )
        ],
      ),
    );
  }

  String _resolveImage(dynamic value) {
    final path = value?.toString().trim() ?? '';
    if (path.isEmpty) return 'assets/images/Lap1.jpg';
    if (path.startsWith('http')) return path;
    if (path.startsWith('/')) return ApiConfig.baseUrl + path;
    return path;
  }
}
