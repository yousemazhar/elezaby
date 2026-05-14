import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/order_service.dart';
import '../../services/reward_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/global_app_bar.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressCtrl =
      TextEditingController(text: '8 Street 9, Maadi, Cairo');
  bool _placing = false;

  @override
  void dispose() {
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    setState(() => _placing = true);
    try {
      final auth = context.read<AuthProvider>();
      final cart = context.read<CartProvider>();
      final user = auth.appUser!;

      final order = await OrderService().placeOrder(
        userId: user.uid,
        items: cart.items,
        address: _addressCtrl.text,
        isFirstOrder: !user.firstOrderCompleted,
      );

      final reward = RewardService();
      await reward.addPoints(user.uid, order.rewardPointsEarned);
      if (!user.firstOrderCompleted) {
        await reward.markFirstOrderCompleted(user.uid);
      }

      await cart.clearCart(user.uid);

      // Refresh user reward points
      await auth.refreshUserFromFirestore();

      if (!mounted) return;
      context.go('/order-success', extra: order);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order failed: $e'),
          backgroundColor: AppColors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: const GlobalAppBar(title: 'Checkout', showBackButton: true),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              children: [
                const _SectionTitle('Delivery Address'),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _addressCtrl,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.location_on_outlined,
                        color: AppColors.primary),
                    hintText: 'Enter delivery address',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                const _SectionTitle('Order Summary'),
                const SizedBox(height: 10),
                ...cart.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.medication_rounded,
                                color: AppColors.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.productName,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textDark)),
                                Text('x${item.quantity}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                          Text(
                            'EGP ${item.totalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark),
                          ),
                        ],
                      ),
                    )),
                const Divider(color: AppColors.divider, height: 24),
                _SummaryRow('Subtotal',
                    'EGP ${cart.subtotal.toStringAsFixed(0)}'),
                const SizedBox(height: 6),
                _SummaryRow(
                  'Delivery',
                  cart.deliveryFee == 0
                      ? 'FREE'
                      : 'EGP ${cart.deliveryFee.toStringAsFixed(0)}',
                  valueColor: cart.deliveryFee == 0
                      ? AppColors.green
                      : AppColors.textDark,
                ),
                const Divider(color: AppColors.divider, height: 24),
                _SummaryRow(
                  'Total',
                  'EGP ${cart.total.toStringAsFixed(0)}',
                  bold: true,
                ),
                const SizedBox(height: 16),
                if (cart.totalRewardPoints > 0)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.greenLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Text('⭐', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text(
                          'You\'ll earn ${cart.totalRewardPoints} reward points',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        color: Colors.white,
        child: AppButton(
          label: 'Place Order  •  EGP ${cart.total.toStringAsFixed(0)}',
          loading: _placing,
          onPressed: _placeOrder,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;
  const _SummaryRow(this.label, this.value,
      {this.valueColor, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: bold ? 16 : 14,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                color: bold ? AppColors.textDark : AppColors.textMuted)),
        Text(value,
            style: TextStyle(
                fontSize: bold ? 20 : 14,
                fontWeight: FontWeight.w700,
                color: valueColor ?? AppColors.textDark)),
      ],
    );
  }
}
