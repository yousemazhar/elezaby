import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/address.dart';
import '../../providers/address_provider.dart';
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
  Address? _selected;
  bool _placing = false;

  Future<void> _placeOrder() async {
    final selected = _selected;
    if (selected == null) return;

    setState(() => _placing = true);
    try {
      final auth = context.read<AuthProvider>();
      final cart = context.read<CartProvider>();
      final user = auth.appUser!;

      final order = await OrderService().placeOrder(
        userId: user.uid,
        items: cart.items,
        address: selected.fullAddress,
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

  Future<void> _pickAddress(List<Address> addresses) async {
    final picked = await showModalBottomSheet<Address>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _AddressPickerSheet(
        addresses: addresses,
        selectedId: _selected?.id,
      ),
    );
    if (picked != null && mounted) {
      setState(() => _selected = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final addressProvider = context.watch<AddressProvider>();
    final addresses = addressProvider.addresses;

    // Auto-select default (or first) address once available.
    if (_selected == null && addresses.isNotEmpty) {
      _selected = addressProvider.defaultAddress ?? addresses.first;
    } else if (_selected != null &&
        !addresses.any((a) => a.id == _selected!.id)) {
      _selected = addresses.isNotEmpty
          ? (addressProvider.defaultAddress ?? addresses.first)
          : null;
    }

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
                _AddressSelector(
                  selected: _selected,
                  loading: addressProvider.loading,
                  hasAddresses: addresses.isNotEmpty,
                  onChange: () => _pickAddress(addresses),
                  onAdd: () => context.push('/addresses'),
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
                        Image.asset('assets/icons/star.png', width: 26, height: 26),
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
          label: _selected == null
              ? 'Select Delivery Address'
              : 'Place Order  •  EGP ${cart.total.toStringAsFixed(0)}',
          loading: _placing,
          onPressed: _selected == null ? null : _placeOrder,
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

class _AddressSelector extends StatelessWidget {
  final Address? selected;
  final bool loading;
  final bool hasAddresses;
  final VoidCallback onChange;
  final VoidCallback onAdd;

  const _AddressSelector({
    required this.selected,
    required this.loading,
    required this.hasAddresses,
    required this.onChange,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    if (loading && selected == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
        ),
      );
    }

    if (!hasAddresses) {
      return GestureDetector(
        onTap: onAdd,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary, width: 1.2),
          ),
          child: const Row(
            children: [
              Icon(Icons.add_location_alt_outlined,
                  color: AppColors.primary),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Add a delivery address',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary),
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.primary),
            ],
          ),
        ),
      );
    }

    final addr = selected!;
    return GestureDetector(
      onTap: onChange,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on_outlined,
                color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(addr.label,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark)),
                      if (addr.isDefault) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Default',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(addr.fullAddress,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textMuted)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Text('Change',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}

class _AddressPickerSheet extends StatelessWidget {
  final List<Address> addresses;
  final String? selectedId;

  const _AddressPickerSheet({
    required this.addresses,
    required this.selectedId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Choose Delivery Address',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          const SizedBox(height: 14),
          ...addresses.map((a) {
            final isSel = a.id == selectedId;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(a),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSel ? AppColors.primary : Colors.transparent,
                      width: 1.4,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isSel
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: isSel
                            ? AppColors.primary
                            : AppColors.textMuted,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.label,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark)),
                            const SizedBox(height: 4),
                            Text(a.fullAddress,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 4),
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to addresses screen for adding new
              Future.microtask(() {
                // ignore: use_build_context_synchronously
                GoRouter.of(context).push('/addresses');
              });
            },
            icon: const Icon(Icons.add, color: AppColors.primary),
            label: const Text('Add new address',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
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
