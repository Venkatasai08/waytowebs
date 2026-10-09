import 'package:waytowebs_app/features/auth/domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String phone;
  final String name;
  final String email;
  final String role;
  final bool isZohoVerified;
  final bool credit30DaysApproved;
  final bool credit90DaysApproved;
  final double creditLimit;
  final double availableCredit;
  final String? companyName;
  final String? gstNumber;
  final String? plumberLicenseNumber;
  final double rating;
  final int completedJobs;

  const UserModel({
    required this.id,
    required this.phone,
    required this.name,
    required this.email,
    required this.role,
    this.isZohoVerified = false,
    this.credit30DaysApproved = false,
    this.credit90DaysApproved = false,
    this.creditLimit = 0.0,
    this.availableCredit = 0.0,
    this.companyName,
    this.gstNumber,
    this.plumberLicenseNumber,
    this.rating = 5.0,
    this.completedJobs = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'customer',
      isZohoVerified: json['isZohoVerified'] as bool? ?? false,
      credit30DaysApproved: json['credit30DaysApproved'] as bool? ?? false,
      credit90DaysApproved: json['credit90DaysApproved'] as bool? ?? false,
      creditLimit: (json['creditLimit'] as num?)?.toDouble() ?? 0.0,
      availableCredit: (json['availableCredit'] as num?)?.toDouble() ?? 0.0,
      companyName: json['companyName'] as String?,
      gstNumber: json['gstNumber'] as String?,
      plumberLicenseNumber: json['plumberLicenseNumber'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      completedJobs: json['completedJobs'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'name': name,
      'email': email,
      'role': role,
      'isZohoVerified': isZohoVerified,
      'credit30DaysApproved': credit30DaysApproved,
      'credit90DaysApproved': credit90DaysApproved,
      'creditLimit': creditLimit,
      'availableCredit': availableCredit,
      'companyName': companyName,
      'gstNumber': gstNumber,
      'plumberLicenseNumber': plumberLicenseNumber,
      'rating': rating,
      'completedJobs': completedJobs,
    };
  }

  UserEntity toEntity() {
    UserRole userRole;
    switch (role.toLowerCase()) {
      case 'dealer':
        userRole = UserRole.dealer;
        break;
      case 'plumber':
        userRole = UserRole.plumber;
        break;
      case 'admin':
        userRole = UserRole.admin;
        break;
      default:
        userRole = UserRole.customer;
    }

    return UserEntity(
      id: id,
      phone: phone,
      name: name,
      email: email,
      role: userRole,
      isZohoVerified: isZohoVerified,
      credit30DaysApproved: credit30DaysApproved,
      credit90DaysApproved: credit90DaysApproved,
      creditLimit: creditLimit,
      availableCredit: availableCredit,
      companyName: companyName,
      gstNumber: gstNumber,
      plumberLicenseNumber: plumberLicenseNumber,
      rating: rating,
      completedJobs: completedJobs,
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      phone: entity.phone,
      name: entity.name,
      email: entity.email,
      role: entity.role.name,
      isZohoVerified: entity.isZohoVerified,
      credit30DaysApproved: entity.credit30DaysApproved,
      credit90DaysApproved: entity.credit90DaysApproved,
      creditLimit: entity.creditLimit,
      availableCredit: entity.availableCredit,
      companyName: entity.companyName,
      gstNumber: entity.gstNumber,
      plumberLicenseNumber: entity.plumberLicenseNumber,
      rating: entity.rating,
      completedJobs: entity.completedJobs,
    );
  }

  UserModel copyWith({
    String? id,
    String? phone,
    String? name,
    String? email,
    String? role,
    bool? isZohoVerified,
    bool? credit30DaysApproved,
    bool? credit90DaysApproved,
    double? creditLimit,
    double? availableCredit,
    String? companyName,
    String? gstNumber,
    String? plumberLicenseNumber,
    double? rating,
    int? completedJobs,
  }) {
    return UserModel(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isZohoVerified: isZohoVerified ?? this.isZohoVerified,
      credit30DaysApproved: credit30DaysApproved ?? this.credit30DaysApproved,
      credit90DaysApproved: credit90DaysApproved ?? this.credit90DaysApproved,
      creditLimit: creditLimit ?? this.creditLimit,
      availableCredit: availableCredit ?? this.availableCredit,
      companyName: companyName ?? this.companyName,
      gstNumber: gstNumber ?? this.gstNumber,
      plumberLicenseNumber: plumberLicenseNumber ?? this.plumberLicenseNumber,
      rating: rating ?? this.rating,
      completedJobs: completedJobs ?? this.completedJobs,
    );
  }
}
