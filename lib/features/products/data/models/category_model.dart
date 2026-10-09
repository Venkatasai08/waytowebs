import 'package:waytowebs_app/features/products/domain/entities/category_entity.dart';

class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String iconCode;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconCode,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      iconCode: json['iconCode'] as String? ?? 'category',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconCode': iconCode,
    };
  }

  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      description: description,
      iconCode: iconCode,
    );
  }
}
