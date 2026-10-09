import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waytowebs_app/core/constants/app_colors.dart';
import 'package:waytowebs_app/core/utils/formatters.dart';
import 'package:waytowebs_app/features/auth/domain/entities/user_entity.dart';
import 'package:waytowebs_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:waytowebs_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:waytowebs_app/features/orders/domain/entities/order_entity.dart';
import 'package:waytowebs_app/features/orders/presentation/providers/order_provider.dart';
import 'package:waytowebs_app/features/orders/presentation/screens/order_confirmation_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final TextEditingController _addressController = TextEditingController(
    text: 'Plot 48, Industrial Suburb, 2nd Stage, Peenya, Bengaluru 560058',
  );
  PaymentMethod _selectedPaymentMethod = PaymentMethod.directUpi;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authStateProvider).user;
    if (user?.role == UserRole.dealer) {
      if (user?.credit30DaysApproved == true) {
        _selectedPaymentMethod = PaymentMethod.dealerCredit30Days;
      } else {
        _selectedPaymentMethod = PaymentMethod.dealerUpfront;
      }
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handlePlaceOrder() async {
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a delivery address')),
      );
      return;
    }

    final order = await ref.read(ordersProvider.notifier).createOrder(
          paymentMethod: _selectedPaymentMethod,
          shippingAddress: address,
        );

    if (order != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderConfirmationScreen(order: order),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user;
    final cartState = ref.watch(cartProvider);
    final ordersState = ref.watch(ordersProvider);
    final isDealer = user?.role == UserRole.dealer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout & Payment'),
        backgroundColor: isDealer ? AppColors.dealerColor : AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Delivery Address',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _addressController,
              maxLines: 2,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.location_on_outlined),
                hintText: 'Enter complete delivery address',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Payment Method',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                if (isDealer)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.dealerColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'B2B Wholesale Terms',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.dealerColor),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (isDealer) ...[
              _buildDealerPaymentOptions(user!),
            ] else ...[
              _buildCustomerPaymentOptions(),
            ],
            const SizedBox(height: 20),
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  ...cartState.items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item.product.name} (x${item.quantity})',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            Formatters.formatCurrency(item.totalPrice),
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      Text(Formatters.formatCurrency(cartState.subtotal), style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('GST (18%):', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      Text(Formatters.formatCurrency(cartState.gstTaxAmount), style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Shipping:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      Text(
                        cartState.deliveryFee == 0 ? 'FREE' : Formatters.formatCurrency(cartState.deliveryFee),
                        style: TextStyle(fontSize: 12, color: cartState.deliveryFee == 0 ? AppColors.success : null),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Payable Total:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      Text(
                        Formatters.formatCurrency(cartState.grandTotal),
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: isDealer ? AppColors.dealerColor : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (ordersState.errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error),
                ),
                child: Text(
                  ordersState.errorMessage!,
                  style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDealer ? AppColors.dealerColor : AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: ordersState.isLoading ? null : _handlePlaceOrder,
              child: ordersState.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text('Confirm & Place Order (${Formatters.formatCurrency(cartState.grandTotal)})'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerPaymentOptions() {
    return Column(
      children: [
        _buildPaymentRadioTile(
          value: PaymentMethod.directUpi,
          title: 'UPI / QR Payment (Instant)',
          subtitle: 'Google Pay, PhonePe, Paytm, BHIM',
          icon: Icons.qr_code_2,
        ),
        _buildPaymentRadioTile(
          value: PaymentMethod.directCard,
          title: 'Credit / Debit Card',
          subtitle: 'Visa, MasterCard, RuPay',
          icon: Icons.credit_card,
        ),
        _buildPaymentRadioTile(
          value: PaymentMethod.directNetBanking,
          title: 'Net Banking',
          subtitle: 'All major Indian banks',
          icon: Icons.account_balance,
        ),
        _buildPaymentRadioTile(
          value: PaymentMethod.cashOnDelivery,
          title: 'Cash on Delivery (COD)',
          subtitle: 'Pay cash upon delivery',
          icon: Icons.local_atm,
        ),
      ],
    );
  }

  Widget _buildDealerPaymentOptions(UserEntity dealer) {
    return Column(
      children: [
        _buildPaymentRadioTile(
          value: PaymentMethod.dealerUpfront,
          title: 'Upfront Payment',
          subtitle: 'Direct NEFT / RTGS / Instant Transfer',
          icon: Icons.account_balance_wallet,
        ),
        _buildPaymentRadioTile(
          value: PaymentMethod.dealerCredit30Days,
          title: 'Credit Payment – 30 Days',
          subtitle: dealer.credit30DaysApproved
              ? 'Approved • Net 30 Days terms (Available Limit: ${Formatters.formatCurrency(dealer.availableCredit)})'
              : 'Credit not approved by administrator',
          icon: Icons.calendar_month,
          enabled: dealer.credit30DaysApproved,
        ),
        _buildPaymentRadioTile(
          value: PaymentMethod.dealerCredit90Days,
          title: 'Credit Payment – 90 Days',
          subtitle: dealer.credit90DaysApproved
              ? 'Approved • Net 90 Days terms (Available Limit: ${Formatters.formatCurrency(dealer.availableCredit)})'
              : 'Requires Zoho credit approval (Only for selected dealers)',
          icon: Icons.stars,
          enabled: dealer.credit90DaysApproved,
        ),
      ],
    );
  }

  Widget _buildPaymentRadioTile({
    required PaymentMethod value,
    required String title,
    required String subtitle,
    required IconData icon,
    bool enabled = true,
  }) {
    final isSelected = _selectedPaymentMethod == value;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        enabled: enabled,
        leading: Icon(icon, color: enabled ? (isSelected ? AppColors.primary : AppColors.textSecondary) : Colors.grey),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: enabled ? (isSelected ? AppColors.primary : AppColors.textPrimary) : Colors.grey,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 11, color: enabled ? AppColors.textSecondary : Colors.red.shade400),
        ),
        trailing: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade400,
              width: 2,
            ),
          ),
          child: isSelected
              ? Center(
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                  ),
                )
              : null,
        ),
        onTap: enabled ? () => setState(() => _selectedPaymentMethod = value) : null,
      ),
    );
  }
}
