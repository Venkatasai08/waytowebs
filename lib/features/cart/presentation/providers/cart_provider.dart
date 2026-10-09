import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waytowebs_app/features/auth/domain/entities/user_entity.dart';
import 'package:waytowebs_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:waytowebs_app/features/cart/domain/entities/cart_item_entity.dart';
import 'package:waytowebs_app/features/products/domain/entities/product_entity.dart';

class CartState {
  final List<CartItemEntity> items;

  const CartState({this.items = const []});

  int get totalItemsCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get gstTaxAmount => subtotal * 0.18;

  double get deliveryFee => subtotal > 2000 ? 0.0 : 150.0;

  double get grandTotal => subtotal + gstTaxAmount + (items.isEmpty ? 0.0 : deliveryFee);

  CartState copyWith({List<CartItemEntity>? items}) {
    return CartState(items: items ?? this.items);
  }
}

class CartNotifier extends StateNotifier<CartState> {
  final Ref ref;

  CartNotifier(this.ref) : super(const CartState());

  double _getApplicablePrice(ProductEntity product) {
    final user = ref.read(authStateProvider).user;
    if (user != null && user.role == UserRole.dealer) {
      return product.dealerPrice;
    }
    return product.customerPrice;
  }

  void addItem(ProductEntity product, [int quantity = 1]) {
    final unitPrice = _getApplicablePrice(product);
    final existingIndex = state.items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex != -1) {
      final updatedList = List<CartItemEntity>.from(state.items);
      final currentItem = updatedList[existingIndex];
      updatedList[existingIndex] = currentItem.copyWith(
        quantity: currentItem.quantity + quantity,
        unitPrice: unitPrice,
      );
      state = state.copyWith(items: updatedList);
    } else {
      final newItem = CartItemEntity(
        product: product,
        quantity: quantity,
        unitPrice: unitPrice,
      );
      state = state.copyWith(items: [...state.items, newItem]);
    }
  }

  void updateQuantity(String productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(productId);
      return;
    }
    final updatedList = state.items.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: newQuantity);
      }
      return item;
    }).toList();
    state = state.copyWith(items: updatedList);
  }

  void removeItem(String productId) {
    final updatedList = state.items.where((item) => item.product.id != productId).toList();
    state = state.copyWith(items: updatedList);
  }

  void clearCart() {
    state = const CartState();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier(ref);
});
