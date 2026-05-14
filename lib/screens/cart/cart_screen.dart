import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/cart_item.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/free_shipping_card.dart';
import '../../widgets/app_button.dart';
import '../../widgets/global_app_bar.dart';
import '../../widgets/product_image.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final cart = context.watch<CartProvider>();
    final uid = auth.appUser?.uid ?? '';

    return Scaffold(
      appBar: const GlobalAppBar(title: 'My Cart', showBackButton: true),
      body: Column(
        children: [
          if (cart.items.isEmpty)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🛒', style: TextStyle(fontSize: 64)),
                    SizedBox(height: 16),
                    Text(
                      'Your cart is empty',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Add products to get started',
                      style:
                          TextStyle(fontSize: 14, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                children: [
                  // Points earned
                  if (cart.totalRewardPoints > 0) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.greenLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Text('⭐', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 10),
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
                    const SizedBox(height: 12),
                  ],
                  FreeShippingCard(subtotal: cart.subtotal),
                  const SizedBox(height: 12),
                  const Text(
                    'Items',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark),
                  ),
                  const SizedBox(height: 10),
                  ...cart.items.map(
                    (item) => _CartItemTile(
                      item: item,
                      uid: uid,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 100),
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: cart.items.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                boxShadow: [
                  BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 16,
                      offset: Offset(0, -4)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal',
                          style: TextStyle(
                              fontSize: 14, color: AppColors.textMuted)),
                      Text(
                        'EGP ${cart.subtotal.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Delivery',
                          style: TextStyle(
                              fontSize: 14, color: AppColors.textMuted)),
                      Text(
                        cart.deliveryFee == 0
                            ? 'FREE'
                            : 'EGP ${cart.deliveryFee.toStringAsFixed(0)}',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: cart.deliveryFee == 0
                                ? AppColors.green
                                : AppColors.textDark),
                      ),
                    ],
                  ),
                  const Divider(height: 20, color: AppColors.divider),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark)),
                      Text(
                        'EGP ${cart.total.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Proceed to Checkout',
                    onPressed: () => context.push('/checkout'),
                  ),
                ],
              ),
            ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final String uid;
  const _CartItemTile({required this.item, required this.uid});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/product/${item.productId}'),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ProductImage(imageUrl: item.imageUrl, iconSize: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'EGP ${item.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _QtyButton(
                      icon: Icons.remove,
                      onTap: () =>
                          cart.updateQuantity(uid, item.id, item.quantity - 1),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${item.quantity}',
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark),
                    ),
                    const SizedBox(width: 12),
                    _QtyButton(
                      icon: Icons.add,
                      onTap: () =>
                          cart.updateQuantity(uid, item.id, item.quantity + 1),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textMuted, size: 20),
            onPressed: () => cart.removeItem(uid, item.id),
          ),
        ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.divider, width: 1.5),
        ),
        child: Icon(icon, size: 20, color: AppColors.textDark),
      ),
    );
  }
}
