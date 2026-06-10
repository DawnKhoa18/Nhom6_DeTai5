import 'package:flutter/material.dart';
import 'main_screen.dart';
import 'package:nhom6_detai5_doancuoiki/screens/admin/admin_dashboard_screen.dart';
import 'package:nhom6_detai5_doancuoiki/screens/admin/edit_equipment_screen_admin.dart';
import 'package:nhom6_detai5_doancuoiki/screens/admin/order_detail_admin_screen.dart';
import 'package:nhom6_detai5_doancuoiki/screens/admin/rental_orders_screen_admin.dart';
import 'package:nhom6_detai5_doancuoiki/screens/auth/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản lý thiết bị',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}