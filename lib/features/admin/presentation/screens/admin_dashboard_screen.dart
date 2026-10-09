import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waytowebs_app/core/constants/app_colors.dart';
import 'package:waytowebs_app/core/utils/formatters.dart';
import 'package:waytowebs_app/core/widgets/app_drawer.dart';
import 'package:waytowebs_app/features/admin/presentation/providers/admin_provider.dart';
import 'package:waytowebs_app/features/admin/presentation/screens/admin_dealer_management_screen.dart';
import 'package:waytowebs_app/features/admin/presentation/screens/admin_orders_management_screen.dart';
import 'package:waytowebs_app/features/admin/presentation/screens/admin_plumber_management_screen.dart';
import 'package:waytowebs_app/features/admin/presentation/screens/admin_products_management_screen.dart';
import 'package:waytowebs_app/features/admin/presentation/screens/admin_zoho_sync_screen.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(adminMetricsProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Admin Management Console'),
        backgroundColor: AppColors.adminColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_sync),
            tooltip: 'Zoho Workbook Sync Hub',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminZohoSyncScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.adminColor, Color(0xFF7F1D1D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Enterprise Business Overview', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Revenue (GMV)', style: TextStyle(color: Colors.white70, fontSize: 11)),
                            Text(
                              Formatters.formatCurrency(metrics.totalRevenue),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Credit Extended', style: TextStyle(color: Colors.white70, fontSize: 11)),
                            Text(
                              Formatters.formatCurrency(metrics.totalCreditOutstanding),
                              style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Total Orders',
                    value: '${metrics.totalOrdersCount}',
                    icon: Icons.receipt_long,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Dealers',
                    value: '${metrics.totalDealersCount}',
                    icon: Icons.store,
                    color: AppColors.dealerColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Plumbers',
                    value: '${metrics.totalPlumbersCount}',
                    icon: Icons.handyman,
                    color: AppColors.plumberColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Management Modules', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildAdminMenuTile(
              title: 'Dealers & Credit Permissions',
              subtitle: 'Manage Zoho verification, 30/90 day credit eligibility & limits',
              icon: Icons.storefront,
              color: AppColors.dealerColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminDealerManagementScreen()),
                );
              },
            ),
            const SizedBox(height: 8),
            _buildAdminMenuTile(
              title: 'Orders & Fulfillment Pipeline',
              subtitle: 'Review customer & dealer orders, update fulfillment and shipping',
              icon: Icons.local_shipping_outlined,
              color: Colors.blue.shade700,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminOrdersManagementScreen()),
                );
              },
            ),
            const SizedBox(height: 8),
            _buildAdminMenuTile(
              title: 'Products, Pricing & Stock',
              subtitle: 'Update stock levels, modify retail vs wholesale prices',
              icon: Icons.inventory_2_outlined,
              color: Colors.teal,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminProductsManagementScreen()),
                );
              },
            ),
            const SizedBox(height: 8),
            _buildAdminMenuTile(
              title: 'Plumber Partners & Jobs',
              subtitle: 'Verify certified technician credentials and inspect job assignments',
              icon: Icons.build_circle_outlined,
              color: AppColors.plumberColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminPlumberManagementScreen()),
                );
              },
            ),
            const SizedBox(height: 8),
            _buildAdminMenuTile(
              title: 'Zoho Workbook Sync Dashboard',
              subtitle: 'Manage bidirectional sync between local app and Zoho Sheets/CRM',
              icon: Icons.sync_alt,
              color: Colors.indigo,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminZohoSyncScreen()),
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(title, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildAdminMenuTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      ),
    );
  }
}
