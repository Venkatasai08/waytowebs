import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waytowebs_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:waytowebs_app/features/products/data/datasources/zoho_workbook_sync_service.dart';
import 'package:waytowebs_app/features/products/data/repositories/product_repository_impl.dart';
import 'package:waytowebs_app/features/products/domain/entities/category_entity.dart';
import 'package:waytowebs_app/features/products/domain/entities/product_entity.dart';
import 'package:waytowebs_app/features/products/domain/repositories/product_repository.dart';

final zohoWorkbookSyncServiceProvider = Provider<ZohoWorkbookSyncService>((ref) {
  final client = ref.watch(zohoApiClientProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return ZohoWorkbookSyncServiceImpl(
    zohoApiClient: client,
    sharedPreferences: prefs,
  );
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final syncService = ref.watch(zohoWorkbookSyncServiceProvider);
  return ProductRepositoryImpl(syncService: syncService);
});

class ProductsState {
  final List<ProductEntity> products;
  final List<CategoryEntity> categories;
  final String? selectedCategoryId;
  final String searchQuery;
  final bool isLoading;
  final bool isSyncing;
  final String? errorMessage;
  final DateTime? lastSyncTime;

  const ProductsState({
    this.products = const [],
    this.categories = const [],
    this.selectedCategoryId,
    this.searchQuery = '',
    this.isLoading = false,
    this.isSyncing = false,
    this.errorMessage,
    this.lastSyncTime,
  });

  List<ProductEntity> get filteredProducts {
    return products.where((product) {
      final matchesCategory = selectedCategoryId == null ||
          selectedCategoryId!.isEmpty ||
          product.categoryId == selectedCategoryId;
      final matchesQuery = searchQuery.isEmpty ||
          product.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          product.sku.toLowerCase().contains(searchQuery.toLowerCase()) ||
          product.categoryName.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

  ProductsState copyWith({
    List<ProductEntity>? products,
    List<CategoryEntity>? categories,
    String? selectedCategoryId,
    String? searchQuery,
    bool? isLoading,
    bool? isSyncing,
    String? errorMessage,
    DateTime? lastSyncTime,
    bool clearCategory = false,
  }) {
    return ProductsState(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      selectedCategoryId: clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      errorMessage: errorMessage,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }
}

class ProductsNotifier extends StateNotifier<ProductsState> {
  final ProductRepository repository;

  ProductsNotifier({required this.repository}) : super(const ProductsState()) {
    loadProductsAndCategories();
  }

  Future<void> loadProductsAndCategories() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final categories = await repository.getCategories();
      final products = await repository.getProducts();
      state = state.copyWith(
        products: products,
        categories: categories,
        isLoading: false,
        lastSyncTime: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to fetch inventory from Zoho workbook: ${e.toString()}',
      );
    }
  }

  void selectCategory(String? categoryId) {
    if (state.selectedCategoryId == categoryId) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategoryId: categoryId);
    }
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> triggerZohoWorkbookSync() async {
    state = state.copyWith(isSyncing: true);
    try {
      await repository.syncProductsFromZoho();
      final products = await repository.getProducts();
      state = state.copyWith(
        products: products,
        isSyncing: false,
        lastSyncTime: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        errorMessage: 'Sync error: ${e.toString()}',
      );
    }
  }

  Future<void> updateStock(String productId, int newStock) async {
    await repository.updateProductStock(productId, newStock);
    final updatedProducts = state.products.map((p) {
      if (p.id == productId) {
        return p.copyWith(stockQuantity: newStock);
      }
      return p;
    }).toList();
    state = state.copyWith(products: updatedProducts);
  }

  Future<void> updatePrices(String productId, double customerPrice, double dealerPrice) async {
    await repository.updateProductPrices(
      productId: productId,
      customerPrice: customerPrice,
      dealerPrice: dealerPrice,
    );
    final updatedProducts = state.products.map((p) {
      if (p.id == productId) {
        return p.copyWith(
          customerPrice: customerPrice,
          dealerPrice: dealerPrice,
        );
      }
      return p;
    }).toList();
    state = state.copyWith(products: updatedProducts);
  }
}

final productsProvider = StateNotifierProvider<ProductsNotifier, ProductsState>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return ProductsNotifier(repository: repository);
});
