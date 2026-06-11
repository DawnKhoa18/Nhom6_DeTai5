import 'package:flutter/material.dart';
// Import các màn hình nằm trong cùng thư mục customer
import 'customer/catalog_screen.dart';
import 'customer/my_orders_screen.dart';
import 'customer/my_assets_screen.dart';
import 'customer/chat_support_screen.dart';
import 'customer/customer_profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Khởi tạo danh sách 4 màn hình chính tương ứng với toàn bộ API Phân hệ User
  final List<Widget> _screens = [
    const CatalogScreen(),
    const MyOrdersScreen(),
    const MyAssetsScreen(),
    const ChatSupportScreen(),
    const CustomerProfileScreen(),
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
          // TAB 1: Màn 1 & Màn 4 & Màn 5 & Màn 2
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Danh mục',
          ),
          // TAB 2: Màn 6 & Màn 7 & Màn 8 & Màn 10 & Màn 11 & Màn 12
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Đơn thuê',
          ),
          // TAB 3: Màn 3 & Màn 9
          NavigationDestination(
            icon: Icon(Icons.devices_outlined),
            selectedIcon: Icon(Icons.devices),
            label: 'Máy của tôi',
          ),
          // TAB 4: Màn 13
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Hỗ trợ',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }
}
