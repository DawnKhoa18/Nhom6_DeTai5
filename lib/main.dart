import 'package:flutter/material.dart';
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
      debugShowCheckedModeBanner: false,
      title: 'CompuRent App',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF4A00E0),
      ),
      home: const WelcomeScreen(),
    );
  }
}