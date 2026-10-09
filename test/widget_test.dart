import 'package:flutter_test/flutter_test.dart';
import 'package:waytowebs_app/features/auth/domain/entities/user_entity.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('UserEntity model test', () {
    const user = UserEntity(
      id: 'USR-1',
      phone: '9876543210',
      name: 'Test Dealer',
      email: 'dealer@test.com',
      role: UserRole.dealer,
      isZohoVerified: true,
      credit30DaysApproved: true,
      credit90DaysApproved: true,
      creditLimit: 100000.0,
      availableCredit: 80000.0,
    );

    expect(user.id, 'USR-1');
    expect(user.role, UserRole.dealer);
    expect(user.isZohoVerified, true);
    expect(user.credit30DaysApproved, true);
    expect(user.credit90DaysApproved, true);
  });

  test('Role-based UserEntity validation test for all 4 roles', () {
    const customer = UserEntity(
      id: 'USR-CUST-1',
      phone: '9988776655',
      name: 'Customer',
      email: 'customer@test.com',
      role: UserRole.customer,
      isZohoVerified: true,
    );
    expect(customer.role, UserRole.customer);

    const dealer = UserEntity(
      id: 'USR-DEALER-1',
      phone: '9876543210',
      name: 'Apex Hardware',
      email: 'dealer@test.com',
      role: UserRole.dealer,
      isZohoVerified: true,
      credit30DaysApproved: true,
      credit90DaysApproved: true,
      creditLimit: 250000.0,
      availableCredit: 185000.0,
    );
    expect(dealer.role, UserRole.dealer);
    expect(dealer.credit90DaysApproved, true);

    const plumber = UserEntity(
      id: 'USR-PLUMB-1',
      phone: '9123456780',
      name: 'Ramesh Kumar',
      email: 'plumber@test.com',
      role: UserRole.plumber,
      isZohoVerified: true,
      plumberLicenseNumber: 'PLUMB-IN-2024-889',
      rating: 4.9,
    );
    expect(plumber.role, UserRole.plumber);

    const admin = UserEntity(
      id: 'USR-ADMIN-1',
      phone: '9000000000',
      name: 'Administrator',
      email: 'admin@waytowebs.com',
      role: UserRole.admin,
      isZohoVerified: true,
    );
    expect(admin.role, UserRole.admin);
  });
}
