import 'package:waytowebs_app/features/orders/domain/entities/order_entity.dart';

abstract class OrderRepository {
  Future<OrderEntity> placeOrder(OrderEntity order);
  Future<List<OrderEntity>> getOrdersByUser(String userId);
  Future<List<OrderEntity>> getAllOrders();
  Future<OrderEntity?> getOrderById(String orderId);
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus);
}
