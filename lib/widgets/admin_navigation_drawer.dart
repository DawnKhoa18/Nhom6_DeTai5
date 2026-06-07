import 'package:flutter/material.dart';

import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/computer_line_management_screen.dart';
import '../screens/admin/device_management_screen.dart';
import '../screens/admin/invoice_management_screen.dart';
import '../screens/admin/maintenance_management_screen.dart';
import '../screens/admin/payment_management_screen.dart';
import '../screens/admin/rental_orders_screen_admin.dart';
import '../screens/admin/user_management_screen.dart';

class AdminNavigationDrawer extends StatelessWidget {
  final AdminSection currentSection;

  const AdminNavigationDrawer({
    super.key,
    required this.currentSection,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF8FBFF),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: ListView(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1D4ED8), Color(0xFF60A5FA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white24,
                      child: Icon(
                        Icons.admin_panel_settings_rounded,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Menu quản trị',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _DrawerItem(
                icon: Icons.space_dashboard_rounded,
                label: 'Dashboard',
                selected: currentSection == AdminSection.dashboard,
                onTap: () => _goTo(
                  context,
                  const AdminDashboardScreen(),
                  AdminSection.dashboard,
                ),
                currentSection: currentSection,
              ),
              const SizedBox(height: 8),
              _DrawerItem(
                icon: Icons.inventory_2_rounded,
                label: 'Quản lý thiết bị',
                selected: currentSection == AdminSection.devices,
                onTap: () => _goTo(
                  context,
                  const DeviceManagementScreen(),
                  AdminSection.devices,
                ),
                currentSection: currentSection,
              ),
              const SizedBox(height: 8),
              _DrawerItem(
                icon: Icons.receipt_long_rounded,
                label: 'Quản lý đơn thuê',
                selected: currentSection == AdminSection.rentalOrders,
                onTap: () => _goTo(
                  context,
                  const RentalOrdersScreen(),
                  AdminSection.rentalOrders,
                ),
                currentSection: currentSection,
              ),
              const SizedBox(height: 8),
              _DrawerItem(
                icon: Icons.manage_accounts_rounded,
                label: 'Quản lý người dùng',
                selected: currentSection == AdminSection.users,
                onTap: () => _goTo(
                  context,
                  const UserManagementScreen(),
                  AdminSection.users,
                ),
                currentSection: currentSection,
              ),
              const SizedBox(height: 8),
              _DrawerItem(
                icon: Icons.category_rounded,
                label: 'Quản lý dòng máy',
                selected: currentSection == AdminSection.computerLines,
                onTap: () => _goTo(
                  context,
                  const ComputerLineManagementScreen(),
                  AdminSection.computerLines,
                ),
                currentSection: currentSection,
              ),
              const SizedBox(height: 8),
              _DrawerItem(
                icon: Icons.build_rounded,
                label: 'Quản lý bảo trì',
                selected: currentSection == AdminSection.maintenances,
                onTap: () => _goTo(
                  context,
                  const MaintenanceManagementScreen(),
                  AdminSection.maintenances,
                ),
                currentSection: currentSection,
              ),
              const SizedBox(height: 8),
              _DrawerItem(
                icon: Icons.request_quote_rounded,
                label: 'Quản lý hóa đơn',
                selected: currentSection == AdminSection.invoices,
                onTap: () => _goTo(
                  context,
                  const InvoiceManagementScreen(),
                  AdminSection.invoices,
                ),
                currentSection: currentSection,
              ),
              const SizedBox(height: 8),
              _DrawerItem(
                icon: Icons.payments_rounded,
                label: 'Quản lý thanh toán',
                selected: currentSection == AdminSection.payments,
                onTap: () => _goTo(
                  context,
                  const PaymentManagementScreen(),
                  AdminSection.payments,
                ),
                currentSection: currentSection,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goTo(BuildContext context, Widget screen, AdminSection target) {
    Navigator.pop(context);
    if (currentSection == target) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}

enum AdminSection {
  dashboard,
  devices,
  rentalOrders,
  users,
  computerLines,
  maintenances,
  invoices,
  payments,
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final AdminSection currentSection;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.currentSection,
  });

  @override
  Widget build(BuildContext context) {
    final background = selected ? const Color(0xFFE0ECFF) : Colors.transparent;
    final foreground =
        selected ? const Color(0xFF1D4ED8) : const Color(0xFF334155);

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: selected ? Colors.white : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: foreground),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: foreground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
