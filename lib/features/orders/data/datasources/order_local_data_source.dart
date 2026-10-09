import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waytowebs_app/core/network/zoho_api_client.dart';
import 'package:waytowebs_app/features/orders/data/models/order_model.dart';

abstract class OrderLocalDataSource {
  Future<List<OrderModel>> getAllOrders();
  Future<void> saveOrder(OrderModel order);
  Future<void> updateOrderStatus(String orderId, String newStatus);
}

class OrderLocalDataSourceImpl implements OrderLocalDataSource {
  final SharedPreferences sharedPreferences;
  final ZohoApiClient zohoApiClient;

  static const String _ordersKey = 'system_orders_database_store';

  OrderLocalDataSourceImpl({
    required this.sharedPreferences,
    required this.zohoApiClient,
  }) {
    _initializeDefaultOrders();
  }

  void _initializeDefaultOrders() {
    final existing = sharedPreferences.getString(_ordersKey);
    if (existing == null) {
      final sampleOrders = [
        OrderModel(
          id: 'WTW-ORD-88219',
          userId: 'USR-CUST-101',
          userName: 'Rajesh Sharma',
          userPhone: '9988776655',
          userRole: 'customer',
          itemsJson: [
            {
              'product': {
                'id': 'ZOHO-PROD-002',
                'name': 'Quarter Turn Ceramic Disc Bib Cock Tap',
                'categoryId': 'cat_faucets',
                'categoryName': 'Faucets & Taps',
                'customerPrice': 650.00,
                'dealerPrice': 460.00,
                'stockQuantity': 120,
                'sku': 'WTW-TAP-QT-01',
                'unit': 'Piece',
                'description': 'Heavy chrome finish brass bib cock with durable ceramic disc.',
                'imageUrl': 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=500',
                'specifications': {'Finish': 'Chrome'},
                'isSyncedWithZoho': true,
                'lastSyncedAtIso': DateTime.now().toIso8601String(),
              },
              'quantity': 2,
              'unitPrice': 650.00,
            }
          ],
          subtotal: 1300.0,
          gstAmount: 234.0,
          deliveryFee: 150.0,
          totalAmount: 1684.0,
          paymentMethod: 'directUpi',
          paymentStatus: 'Paid via UPI',
          orderStatus: 'shipped',
          createdAtIso: DateTime.now().subtract(const Duration(days: 1, hours: 3)).toIso8601String(),
          shippingAddress: 'Flat 402, Green Meadows, MG Road, Bengaluru, Karnataka 560001',
        ),
        OrderModel(
          id: 'WTW-ORD-99104',
          userId: 'USR-DEALER-201',
          userName: 'Vikram Patel',
          userPhone: '9876543210',
          userRole: 'dealer',
          itemsJson: [
            {
              'product': {
                'id': 'ZOHO-PROD-001',
                'name': 'CPVC Brass Female Threaded Adapter 25mm',
                'categoryId': 'cat_pipes',
                'categoryName': 'Pipes & Fittings',
                'customerPrice': 185.00,
                'dealerPrice': 130.00,
                'stockQuantity': 450,
                'sku': 'WTW-CPVC-FTA-25',
                'unit': 'Piece',
                'description': 'High tensile brass threaded adapter.',
                'imageUrl': 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=500',
                'specifications': {'Size': '25mm'},
                'isSyncedWithZoho': true,
                'lastSyncedAtIso': DateTime.now().toIso8601String(),
              },
              'quantity': 50,
              'unitPrice': 130.00,
            }
          ],
          subtotal: 6500.0,
          gstAmount: 1170.0,
          deliveryFee: 0.0,
          totalAmount: 7670.0,
          paymentMethod: 'dealerCredit30Days',
          paymentStatus: 'Credit Term: Net 30 Days (Due in 28 Days)',
          orderStatus: 'confirmed',
          createdAtIso: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
          creditDueDateIso: DateTime.now().add(const Duration(days: 28)).toIso8601String(),
          shippingAddress: 'Warehouse No 12, Industrial Area, Peenya, Bengaluru 560058',
        )
      ];

      final encoded = jsonEncode(sampleOrders.map((o) => o.toJson()).toList());
      sharedPreferences.setString(_ordersKey, encoded);
    }
  }

  @override
  Future<List<OrderModel>> getAllOrders() async {
    final raw = sharedPreferences.getString(_ordersKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveOrder(OrderModel order) async {
    final orders = await getAllOrders();
    orders.insert(0, order);
    final encoded = jsonEncode(orders.map((e) => e.toJson()).toList());
    await sharedPreferences.setString(_ordersKey, encoded);
    await zohoApiClient.pushOrderToZoho(order.toJson());
  }

  @override
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final orders = await getAllOrders();
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final old = orders[index];
      orders[index] = OrderModel(
        id: old.id,
        userId: old.userId,
        userName: old.userName,
        userPhone: old.userPhone,
        userRole: old.userRole,
        itemsJson: old.itemsJson,
        subtotal: old.subtotal,
        gstAmount: old.gstAmount,
        deliveryFee: old.deliveryFee,
        totalAmount: old.totalAmount,
        paymentMethod: old.paymentMethod,
        paymentStatus: old.paymentStatus,
        orderStatus: newStatus,
        createdAtIso: old.createdAtIso,
        creditDueDateIso: old.creditDueDateIso,
        shippingAddress: old.shippingAddress,
      );
      final encoded = jsonEncode(orders.map((e) => e.toJson()).toList());
      await sharedPreferences.setString(_ordersKey, encoded);
    }
  }
}
