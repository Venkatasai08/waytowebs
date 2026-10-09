import 'package:waytowebs_app/core/errors/exceptions.dart';
import 'package:waytowebs_app/core/errors/failures.dart';
import 'package:waytowebs_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:waytowebs_app/features/auth/data/models/user_model.dart';
import 'package:waytowebs_app/features/auth/domain/entities/user_entity.dart';
import 'package:waytowebs_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> sendOtp(String phone, UserRole role) async {
    try {
      return await remoteDataSource.requestOtp(phone, role);
    } on ZohoAuthException catch (e) {
      throw ZohoAuthFailure(e.message);
    } on PlumberVerificationException catch (e) {
      throw PlumberVerificationFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<UserEntity> verifyOtpAndLogin({
    required String phone,
    required String otp,
    required UserRole role,
  }) async {
    try {
      final userModel = await remoteDataSource.verifyOtpAndAuthenticate(phone, otp, role);
      return userModel.toEntity();
    } on ZohoAuthException catch (e) {
      throw ZohoAuthFailure(e.message);
    } on PlumberVerificationException catch (e) {
      throw PlumberVerificationFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getSavedUser();
      return userModel?.toEntity();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.clearUser();
  }

  @override
  Future<List<UserEntity>> getAllUsers() async {
    try {
      final models = await remoteDataSource.fetchAllUsers();
      return models.map((m) => m.toEntity()).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> updateDealerCreditPermissions({
    required String dealerId,
    required bool credit30Approved,
    required bool credit90Approved,
    required double creditLimit,
    required bool isZohoVerified,
  }) async {
    final users = await remoteDataSource.fetchAllUsers();
    final target = users.where((u) => u.id == dealerId).firstOrNull;
    if (target != null) {
      final updated = UserModel(
        id: target.id,
        phone: target.phone,
        name: target.name,
        email: target.email,
        companyName: target.companyName,
        gstNumber: target.gstNumber,
        role: target.role,
        isZohoVerified: isZohoVerified,
        credit30DaysApproved: credit30Approved,
        credit90DaysApproved: credit90Approved,
        creditLimit: creditLimit,
        availableCredit: target.availableCredit > creditLimit ? creditLimit : target.availableCredit,
        rating: target.rating,
        completedJobs: target.completedJobs,
      );
      await remoteDataSource.updateUser(updated);
    }
  }

  @override
  Future<void> updatePlumberStatus({
    required String plumberId,
    required bool isVerified,
  }) async {
    final users = await remoteDataSource.fetchAllUsers();
    final target = users.where((u) => u.id == plumberId).firstOrNull;
    if (target != null) {
      final updated = UserModel(
        id: target.id,
        phone: target.phone,
        name: target.name,
        email: target.email,
        companyName: target.companyName,
        gstNumber: target.gstNumber,
        role: target.role,
        isZohoVerified: isVerified,
        credit30DaysApproved: target.credit30DaysApproved,
        credit90DaysApproved: target.credit90DaysApproved,
        creditLimit: target.creditLimit,
        availableCredit: target.availableCredit,
        plumberLicenseNumber: target.plumberLicenseNumber,
        rating: target.rating,
        completedJobs: target.completedJobs,
      );
      await remoteDataSource.updateUser(updated);
    }
  }
}
