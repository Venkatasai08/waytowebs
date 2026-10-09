enum UserRole {
  customer,
  dealer,
  plumber,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.dealer:
        return 'Dealer';
      case UserRole.plumber:
        return 'Plumber';
      case UserRole.admin:
        return 'Administrator';
    }
  }
}

class UserEntity {
  final String id;
  final String phone;
  final String name;
  final String email;
  final UserRole role;
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

  const UserEntity({
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

  UserEntity copyWith({
    String? id,
    String? phone,
    String? name,
    String? email,
    UserRole? role,
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
    return UserEntity(
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
