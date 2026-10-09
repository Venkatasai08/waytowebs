import 'package:waytowebs_app/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<String> sendOtp(String phone, UserRole role);
  Future<UserEntity> verifyOtpAndLogin({
    required String phone,
    required String otp,
    required UserRole role,
  });
  Future<UserEntity?> getCurrentUser();
  Future<void> logout();
  Future<List<UserEntity>> getAllUsers();
  Future<void> updateDealerCreditPermissions({
    required String dealerId,
    required bool credit30Approved,
    required bool credit90Approved,
    required double creditLimit,
    required bool isZohoVerified,
  });
  Future<void> updatePlumberStatus({
    required String plumberId,
    required bool isVerified,
  });
}
