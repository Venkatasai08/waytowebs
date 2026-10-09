import 'package:waytowebs_app/features/products/domain/entities/category_entity.dart';
import 'package:waytowebs_app/features/products/domain/entities/product_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getProducts();
  Future<List<CategoryEntity>> getCategories();
  Future<ProductEntity?> getProductById(String id);
  Future<List<ProductEntity>> getProductsByCategory(String categoryId);
  Future<void> syncProductsFromZoho();
  Future<void> updateProductStock(String productId, int newQuantity);
  Future<void> updateProductPrices({
    required String productId,
    required double customerPrice,
    required double dealerPrice,
  });
}
