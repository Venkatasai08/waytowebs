import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waytowebs_app/core/constants/app_colors.dart';
import 'package:waytowebs_app/core/constants/app_constants.dart';
import 'package:waytowebs_app/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:waytowebs_app/features/auth/domain/entities/user_entity.dart';
import 'package:waytowebs_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:waytowebs_app/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:waytowebs_app/features/customer/presentation/screens/customer_dashboard_screen.dart';
import 'package:waytowebs_app/features/dealer/presentation/screens/dealer_dashboard_screen.dart';
import 'package:waytowebs_app/features/plumber/presentation/screens/plumber_dashboard_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController(text: '9988776655');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  UserRole _selectedRole = UserRole.customer;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_handlePhoneAutoDetection);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_handlePhoneAutoDetection);
    _phoneController.dispose();
    super.dispose();
  }

  void _handlePhoneAutoDetection() {
    final phone = _phoneController.text.trim();
    final detected = _detectRoleForPhone(phone);
    if (detected != null && detected != _selectedRole) {
      setState(() {
        _selectedRole = detected;
      });
    }
  }

  UserRole? _detectRoleForPhone(String phone) {
    if (phone == '9000000000') return UserRole.admin;
    if (phone == '9876543210' || phone == '9876543211' || phone == '9876543212') return UserRole.dealer;
    if (phone == '9123456780' || phone == '9123456781' || phone == '9123456782') return UserRole.plumber;
    if (phone == '9988776655') return UserRole.customer;
    return null;
  }

  void _fillDemo(String phone, UserRole role) {
    setState(() {
      _phoneController.text = phone;
      _selectedRole = role;
    });
  }

  Future<void> _handleSendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit mobile number'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final role = _detectRoleForPhone(phone) ?? _selectedRole;

    await ref.read(authStateProvider.notifier).sendOtp(
          phone: phone,
          role: role,
        );

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            phone: phone,
            role: role,
          ),
        ),
      );
    }
  }

  Future<void> _handleQuickDirectLogin(String phone, UserRole role) async {
    _fillDemo(phone, role);
    final success = await ref.read(authStateProvider.notifier).verifyOtpAndLogin(
          phone: phone,
          otp: AppConstants.defaultOtp,
          role: role,
        );

    if (success && mounted) {
      final user = ref.read(authStateProvider).user;
      final destinationRole = user?.role ?? role;
      Widget destination;
      switch (destinationRole) {
        case UserRole.customer:
          destination = const CustomerDashboardScreen();
          break;
        case UserRole.dealer:
          destination = const DealerDashboardScreen();
          break;
        case UserRole.plumber:
          destination = const PlumberDashboardScreen();
          break;
        case UserRole.admin:
          destination = const AdminDashboardScreen();
          break;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => destination),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.plumbing_rounded,
                      size: 38,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  AppConstants.appName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  AppConstants.appSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.pin_outlined, size: 20, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Template Test OTP: 123456',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.brown,
                              ),
                            ),
                            Text(
                              'Valid for all 4 roles & phone numbers. Auto-filled on OTP screen.',
                              style: TextStyle(fontSize: 11, color: Colors.brown.shade700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Select Account Role',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildRoleCard(
                        role: UserRole.customer,
                        title: 'Customer',
                        icon: Icons.person_outline,
                        color: AppColors.customerColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildRoleCard(
                        role: UserRole.dealer,
                        title: 'Dealer',
                        icon: Icons.storefront_outlined,
                        color: AppColors.dealerColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildRoleCard(
                        role: UserRole.plumber,
                        title: 'Plumber',
                        icon: Icons.build_circle_outlined,
                        color: AppColors.plumberColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildRoleCard(
                        role: UserRole.admin,
                        title: 'Admin',
                        icon: Icons.admin_panel_settings_outlined,
                        color: AppColors.adminColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Mobile Phone Number',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.phone_android),
                    prefixText: '+91 ',
                    hintText: 'Enter 10-digit mobile number',
                    counterText: '',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your mobile number';
                    }
                    if (val.trim().length != 10) {
                      return 'Enter a valid 10-digit mobile number';
                    }
                    return null;
                  },
                ),
                if (authState.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.error),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            authState.errorMessage!,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: authState.isLoading ? null : _handleSendOtp,
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Send Verification OTP (Go to OTP Screen)'),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.touch_app_outlined, size: 16, color: AppColors.primary),
                          SizedBox(width: 6),
                          Text(
                            'Quick Demo Accounts (Tap to Fill or Instant Login)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildQuickDemoTile(
                        roleTitle: 'Customer',
                        subtitle: 'Direct Payment & Order Tracking',
                        phone: '9988776655',
                        role: UserRole.customer,
                        color: AppColors.customerColor,
                        zohoStatus: 'Verified',
                      ),
                      const SizedBox(height: 6),
                      _buildQuickDemoTile(
                        roleTitle: 'Dealer (90-Day Credit)',
                        subtitle: 'Apex Hardware • ₹2.5L Limit',
                        phone: '9876543210',
                        role: UserRole.dealer,
                        color: AppColors.dealerColor,
                        zohoStatus: 'Zoho CRM Verified',
                      ),
                      const SizedBox(height: 6),
                      _buildQuickDemoTile(
                        roleTitle: 'Dealer (30-Day Credit)',
                        subtitle: 'Metro Traders • ₹1.0L Limit',
                        phone: '9876543211',
                        role: UserRole.dealer,
                        color: AppColors.dealerColor,
                        zohoStatus: 'Zoho CRM Verified',
                      ),
                      const SizedBox(height: 6),
                      _buildQuickDemoTile(
                        roleTitle: 'Plumber',
                        subtitle: 'Ramesh Kumar • Certified Partner',
                        phone: '9123456780',
                        role: UserRole.plumber,
                        color: AppColors.plumberColor,
                        zohoStatus: 'Zoho Verified',
                      ),
                      const SizedBox(height: 6),
                      _buildQuickDemoTile(
                        roleTitle: 'Super Admin',
                        subtitle: 'Manage Users, Credit, Zoho Sync',
                        phone: '9000000000',
                        role: UserRole.admin,
                        color: AppColors.adminColor,
                        zohoStatus: 'Admin Master',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required String title,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedRole == role;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedRole = role;
          switch (role) {
            case UserRole.customer:
              _phoneController.text = '9988776655';
              break;
            case UserRole.dealer:
              _phoneController.text = '9876543210';
              break;
            case UserRole.plumber:
              _phoneController.text = '9123456780';
              break;
            case UserRole.admin:
              _phoneController.text = '9000000000';
              break;
          }
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : AppColors.textSecondary, size: 22),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickDemoTile({
    required String roleTitle,
    required String subtitle,
    required String phone,
    required UserRole role,
    required Color color,
    required String zohoStatus,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              onTap: () => _fillDemo(phone, role),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        roleTitle,
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: color),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Text(
                          zohoStatus,
                          style: TextStyle(fontSize: 9, color: Colors.green.shade800, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '+91 $phone • $subtitle',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: '1-Tap Instant Login',
            icon: const Icon(Icons.login_rounded, size: 20, color: AppColors.primary),
            onPressed: () => _handleQuickDirectLogin(phone, role),
          ),
        ],
      ),
    );
  }
}
