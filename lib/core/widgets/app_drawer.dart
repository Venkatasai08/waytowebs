import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waytowebs_app/core/constants/app_colors.dart';
import 'package:waytowebs_app/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:waytowebs_app/features/auth/domain/entities/user_entity.dart';
import 'package:waytowebs_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:waytowebs_app/features/auth/presentation/screens/login_screen.dart';
import 'package:waytowebs_app/features/cart/presentation/screens/cart_screen.dart';
import 'package:waytowebs_app/features/customer/presentation/screens/customer_categories_screen.dart';
import 'package:waytowebs_app/features/customer/presentation/screens/customer_dashboard_screen.dart';
import 'package:waytowebs_app/features/dealer/presentation/screens/dealer_credit_ledger_screen.dart';
import 'package:waytowebs_app/features/dealer/presentation/screens/dealer_dashboard_screen.dart';
import 'package:waytowebs_app/features/dealer/presentation/screens/dealer_stock_catalog_screen.dart';
import 'package:waytowebs_app/features/orders/presentation/screens/order_history_screen.dart';
import 'package:waytowebs_app/features/plumber/presentation/screens/plumber_catalog_screen.dart';
import 'package:waytowebs_app/features/plumber/presentation/screens/plumber_dashboard_screen.dart';
import 'package:waytowebs_app/features/plumber/presentation/screens/plumber_jobs_screen.dart';
import 'package:waytowebs_app/features/plumber/presentation/screens/plumber_profile_screen.dart';
import 'package:waytowebs_app/features/products/presentation/screens/product_list_screen.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final role = user?.role ?? UserRole.customer;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getRoleHeaderColor(role),
                  AppColors.primaryDark,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                _getRoleIcon(role),
                color: _getRoleHeaderColor(role),
                size: 36,
              ),
            ),
            accountName: Text(
              user?.name ?? 'Guest User',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            accountEmail: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user != null ? '${user.role.displayName} • ${user.phone}' : 'Not logged in',
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
                if (user?.isZohoVerified == true) ...[
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, size: 12, color: Colors.white),
                        SizedBox(width: 4),
                        Text('Zoho Verified', style: TextStyle(fontSize: 10, color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                if (role == UserRole.customer) ...[
                  ListTile(
                    leading: const Icon(Icons.dashboard_outlined, color: AppColors.primary),
                    title: const Text('Customer Dashboard'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const CustomerDashboardScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.category_outlined, color: AppColors.primary),
                    title: const Text('Browse Categories'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CustomerCategoriesScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.storefront_outlined, color: AppColors.primary),
                    title: const Text('All Products'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProductListScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.shopping_cart_outlined, color: AppColors.primary),
                    title: const Text('Shopping Cart'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CartScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.local_shipping_outlined, color: AppColors.primary),
                    title: const Text('My Orders & Tracking'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                      );
                    },
                  ),
                ],
                if (role == UserRole.dealer) ...[
                  ListTile(
                    leading: const Icon(Icons.space_dashboard_outlined, color: AppColors.dealerColor),
                    title: const Text('Dealer Dashboard'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const DealerDashboardScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.inventory_2_outlined, color: AppColors.dealerColor),
                    title: const Text('Wholesale Stock Catalog'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DealerStockCatalogScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.credit_card_outlined, color: AppColors.dealerColor),
                    title: const Text('Credit Ledger & Invoices'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DealerCreditLedgerScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.shopping_bag_outlined, color: AppColors.dealerColor),
                    title: const Text('Bulk Cart & Checkout'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CartScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.receipt_long_outlined, color: AppColors.dealerColor),
                    title: const Text('Dealer Order History'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                      );
                    },
                  ),
                ],
                if (role == UserRole.plumber) ...[
                  ListTile(
                    leading: const Icon(Icons.handyman_outlined, color: AppColors.plumberColor),
                    title: const Text('Plumber Dashboard'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const PlumberDashboardScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.assignment_outlined, color: AppColors.plumberColor),
                    title: const Text('Assigned Job Activities'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PlumberJobsScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.menu_book_outlined, color: AppColors.plumberColor),
                    title: const Text('Spare Parts & Guides'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PlumberCatalogScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person_outline, color: AppColors.plumberColor),
                    title: const Text('Profile & Earnings'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PlumberProfileScreen()),
                      );
                    },
                  ),
                ],
                if (role == UserRole.admin) ...[
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings_outlined, color: AppColors.adminColor),
                    title: const Text('Admin Console'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                      );
                    },
                  ),
                ],
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.swap_horiz, color: Colors.blueGrey),
                  title: const Text('Switch Role (Demo Switcher)'),
                  subtitle: const Text('Quick test Customer / Dealer / Plumber / Admin', style: TextStyle(fontSize: 11)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.error),
                  title: const Text('Logout', style: TextStyle(color: AppColors.error)),
                  onTap: () async {
                    Navigator.pop(context);
                    await ref.read(authStateProvider.notifier).logout();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.grey.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('WayToWebs v1.0.0', style: TextStyle(fontSize: 12, color: Colors.grey)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Zoho Synced', style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleHeaderColor(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return AppColors.customerColor;
      case UserRole.dealer:
        return AppColors.dealerColor;
      case UserRole.plumber:
        return AppColors.plumberColor;
      case UserRole.admin:
        return AppColors.adminColor;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return Icons.person;
      case UserRole.dealer:
        return Icons.store;
      case UserRole.plumber:
        return Icons.plumbing;
      case UserRole.admin:
        return Icons.shield;
    }
  }
}
