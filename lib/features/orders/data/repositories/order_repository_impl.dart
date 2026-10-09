import 'package:waytowebs_app/features/orders/data/datasources/order_local_data_source.dart';
import 'package:waytowebs_app/features/orders/data/models/order_model.dart';
import 'package:waytowebs_app/features/orders/domain/entities/order_entity.dart';
import 'package:waytowebs_app/features/orders/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderLocalDataSource localDataSource;

  OrderRepositoryImpl({required this.localDataSource});

  @override
  Future<OrderEntity> placeOrder(OrderEntity order) async {
    final model = OrderModel.fromEntity(order);
    await localDataSource.saveOrder(model);
    return order;
  }

  @override
  Future<List<OrderEntity>> getOrdersByUser(String userId) async {
    final all = await localDataSource.getAllOrders();
    return all.where((o) => o.userId == userId).map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<OrderEntity>> getAllOrders() async {
    final all = await localDataSource.getAllOrders();
    return all.map((m) => m.toEntity()).toList();
  }

  @override
  Future<OrderEntity?> getOrderById(String orderId) async {
    final all = await localDataSource.getAllOrders();
    final target = all.where((o) => o.id == orderId).firstOrNull;
    return target?.toEntity();
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    await localDataSource.updateOrderStatus(orderId, newStatus.name);
  }
}
