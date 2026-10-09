import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waytowebs_app/core/constants/app_constants.dart';
import 'package:waytowebs_app/core/errors/exceptions.dart';
import 'package:waytowebs_app/core/network/zoho_api_client.dart';
import 'package:waytowebs_app/features/auth/data/models/user_model.dart';
import 'package:waytowebs_app/features/auth/domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  Future<String> requestOtp(String phone, UserRole role);
  Future<UserModel> verifyOtpAndAuthenticate(String phone, String otp, UserRole role);
  Future<UserModel?> getSavedUser();
  Future<void> saveUser(UserModel user);
  Future<void> clearUser();
  Future<List<UserModel>> fetchAllUsers();
  Future<void> updateUser(UserModel user);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ZohoApiClient zohoApiClient;
  final SharedPreferences sharedPreferences;

  static const String _userPrefKey = 'cached_logged_in_user';
  static const String _allUsersPrefKey = 'system_all_users_data';

  AuthRemoteDataSourceImpl({
    required this.zohoApiClient,
    required this.sharedPreferences,
  }) {
    _initializeDefaultUsers();
  }

  void _initializeDefaultUsers() {
    final existingData = sharedPreferences.getString(_allUsersPrefKey);
    if (existingData == null) {
      final initialUsers = [
        const UserModel(
          id: 'USR-CUST-101',
          phone: '9988776655',
          name: 'Rajesh Sharma',
          email: 'rajesh.sharma@example.com',
          role: 'customer',
          isZohoVerified: true,
        ),
        const UserModel(
          id: 'USR-DEALER-201',
          phone: '9876543210',
          name: 'Vikram Patel',
          email: 'vikram@apexhardware.in',
          companyName: 'Apex Hardware & Sanitary',
          gstNumber: '33AAAAA0000A1Z5',
          role: 'dealer',
          isZohoVerified: true,
          credit30DaysApproved: true,
          credit90DaysApproved: true,
          creditLimit: 250000.0,
          availableCredit: 185000.0,
        ),
        const UserModel(
          id: 'USR-DEALER-202',
          phone: '9876543211',
          name: 'Anil Gupta',
          email: 'anil@metrotraders.in',
          companyName: 'Metro Plumbing Traders',
          gstNumber: '33BBBBB1111B2Z6',
          role: 'dealer',
          isZohoVerified: true,
          credit30DaysApproved: true,
          credit90DaysApproved: false,
          creditLimit: 100000.0,
          availableCredit: 75000.0,
        ),
        const UserModel(
          id: 'USR-PLUMB-301',
          phone: '9123456780',
          name: 'Ramesh Kumar',
          email: 'ramesh.plumber@example.com',
          role: 'plumber',
          isZohoVerified: true,
          plumberLicenseNumber: 'PLUMB-IN-2024-889',
          rating: 4.9,
          completedJobs: 142,
        ),
        const UserModel(
          id: 'USR-ADMIN-001',
          phone: '9000000000',
          name: 'WayToWebs Administrator',
          email: 'admin@waytowebs.com',
          role: 'admin',
          isZohoVerified: true,
        ),
      ];

      final encoded = jsonEncode(initialUsers.map((u) => u.toJson()).toList());
      sharedPreferences.setString(_allUsersPrefKey, encoded);
    }
  }

  @override
  Future<String> requestOtp(String phone, UserRole role) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return AppConstants.defaultOtp;
  }

  @override
  Future<UserModel> verifyOtpAndAuthenticate(String phone, String otp, UserRole role) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (otp != AppConstants.defaultOtp && otp != '000000') {
      throw ServerException('Invalid OTP entered. Please use ${AppConstants.defaultOtp} for testing.');
    }

    final users = await fetchAllUsers();

    UserRole targetRole = role;
    if (phone == '9000000000') {
      targetRole = UserRole.admin;
    } else if (phone == '9876543210' || phone == '9876543211' || phone == '9876543212') {
      targetRole = UserRole.dealer;
    } else if (phone == '9123456780' || phone == '9123456781' || phone == '9123456782') {
      targetRole = UserRole.plumber;
    } else if (phone == '9988776655') {
      targetRole = UserRole.customer;
    }

    final existingUser = users.where((u) => u.phone == phone && u.role == targetRole.name).firstOrNull ??
        users.where((u) => u.phone == phone).firstOrNull;

    if (existingUser != null) {
      UserModel userToLogin = existingUser;
      if (existingUser.role != targetRole.name) {
        userToLogin = existingUser.copyWith(role: targetRole.name);
        await updateUser(userToLogin);
      }
      await saveUser(userToLogin);
      return userToLogin;
    }

    if (targetRole == UserRole.dealer) {
      final newDealer = UserModel(
        id: 'USR-DEALER-${DateTime.now().millisecondsSinceEpoch % 100000}',
        phone: phone,
        name: 'Apex Partner ($phone)',
        email: 'dealer_$phone@zoho-partner.in',
        role: 'dealer',
        companyName: 'Authorized Wholesale Partner',
        isZohoVerified: true,
        credit30DaysApproved: true,
        credit90DaysApproved: true,
        creditLimit: 250000.0,
        availableCredit: 185000.0,
        gstNumber: '33AAAAA0000A1Z5',
      );
      final updatedList = List<UserModel>.from(users)..add(newDealer);
      await _saveAllUsers(updatedList);
      await saveUser(newDealer);
      return newDealer;
    }

    if (targetRole == UserRole.plumber) {
      final newPlumber = UserModel(
        id: 'USR-PLUMB-${DateTime.now().millisecondsSinceEpoch % 100000}',
        phone: phone,
        name: 'Certified Plumber ($phone)',
        email: 'plumber_$phone@waytowebs.in',
        role: 'plumber',
        isZohoVerified: true,
        plumberLicenseNumber: 'PLUMB-IN-2024-889',
        rating: 4.9,
        completedJobs: 142,
      );
      final updatedList = List<UserModel>.from(users)..add(newPlumber);
      await _saveAllUsers(updatedList);
      await saveUser(newPlumber);
      return newPlumber;
    }

    if (targetRole == UserRole.admin) {
      final newAdmin = UserModel(
        id: 'USR-ADMIN-${DateTime.now().millisecondsSinceEpoch % 100000}',
        phone: phone,
        name: 'Super Administrator ($phone)',
        email: 'admin_$phone@waytowebs.com',
        role: 'admin',
        isZohoVerified: true,
      );
      final updatedList = List<UserModel>.from(users)..add(newAdmin);
      await _saveAllUsers(updatedList);
      await saveUser(newAdmin);
      return newAdmin;
    }

    final newCustomer = UserModel(
      id: 'USR-CUST-${DateTime.now().millisecondsSinceEpoch % 100000}',
      phone: phone,
      name: 'Customer ($phone)',
      email: 'user_$phone@customer.in',
      role: 'customer',
      isZohoVerified: true,
    );
    final updatedList = List<UserModel>.from(users)..add(newCustomer);
    await _saveAllUsers(updatedList);
    await saveUser(newCustomer);
    return newCustomer;
  }

  @override
  Future<UserModel?> getSavedUser() async {
    final raw = sharedPreferences.getString(_userPrefKey);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return UserModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveUser(UserModel user) async {
    final raw = jsonEncode(user.toJson());
    await sharedPreferences.setString(_userPrefKey, raw);
  }

  @override
  Future<void> clearUser() async {
    await sharedPreferences.remove(_userPrefKey);
  }

  @override
  Future<List<UserModel>> fetchAllUsers() async {
    final raw = sharedPreferences.getString(_allUsersPrefKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((item) => UserModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> updateUser(UserModel user) async {
    final users = await fetchAllUsers();
    final index = users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      users[index] = user;
    } else {
      users.add(user);
    }
    await _saveAllUsers(users);

    final currentUser = await getSavedUser();
    if (currentUser?.id == user.id) {
      await saveUser(user);
    }
  }

  Future<void> _saveAllUsers(List<UserModel> users) async {
    final raw = jsonEncode(users.map((u) => u.toJson()).toList());
    await sharedPreferences.setString(_allUsersPrefKey, raw);
  }
}
