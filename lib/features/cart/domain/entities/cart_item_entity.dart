import 'package:waytowebs_app/features/products/domain/entities/product_entity.dart';

class CartItemEntity {
  final ProductEntity product;
  final int quantity;
  final double unitPrice;

  const CartItemEntity({
    required this.product,
    required this.quantity,
    required this.unitPrice,
  });

  double get totalPrice => unitPrice * quantity;

  CartItemEntity copyWith({
    ProductEntity? product,
    int? quantity,
    double? unitPrice,
  }) {
    return CartItemEntity(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }
}
