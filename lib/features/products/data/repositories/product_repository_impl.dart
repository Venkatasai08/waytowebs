import 'package:waytowebs_app/features/products/data/datasources/zoho_workbook_sync_service.dart';
import 'package:waytowebs_app/features/products/domain/entities/category_entity.dart';
import 'package:waytowebs_app/features/products/domain/entities/product_entity.dart';
import 'package:waytowebs_app/features/products/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ZohoWorkbookSyncService syncService;

  ProductRepositoryImpl({required this.syncService});

  @override
  Future<List<ProductEntity>> getProducts() async {
    final models = await syncService.fetchAndSyncWorkbookProducts();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<CategoryEntity>> getCategories() async {
    final models = await syncService.getCategories();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<ProductEntity?> getProductById(String id) async {
    final products = await getProducts();
    return products.where((p) => p.id == id).firstOrNull;
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory(String categoryId) async {
    final products = await getProducts();
    return products.where((p) => p.categoryId == categoryId).toList();
  }

  @override
  Future<void> syncProductsFromZoho() async {
    await syncService.fetchAndSyncWorkbookProducts();
  }

  @override
  Future<void> updateProductStock(String productId, int newQuantity) async {
    await syncService.updateLocalProductStock(productId, newQuantity);
  }

  @override
  Future<void> updateProductPrices({
    required String productId,
    required double customerPrice,
    required double dealerPrice,
  }) async {
    await syncService.updateLocalProductPrices(productId, customerPrice, dealerPrice);
  }
}
