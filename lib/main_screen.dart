import 'package:flutter/material.dart';
import 'features/catalog/catalog_screen.dart';
import 'features/booking/booking_screen.dart';
import 'features/my_assets/my_assets_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Khởi tạo danh sách 3 màn hình
  final List<Widget> _screens = const [
    CatalogScreen(),
    BookingScreen(),
    MyAssetsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Danh mục',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_checkout_outlined),
            selectedIcon: Icon(Icons.shopping_cart_checkout),
            label: 'Yêu cầu',
          ),
          NavigationDestination(
            icon: Icon(Icons.devices_outlined),
            selectedIcon: Icon(Icons.devices),
            label: 'Máy của tôi',
          ),
        ],
      ),
    );
  }
}