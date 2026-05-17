import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/auth_provider.dart';
import 'product_image.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final cart = context.watch<CartProvider>();
    final favs = context.watch<FavoritesProvider>();
    final uid = auth.appUser?.uid ?? '';
    final isFav = favs.isFavorite(product.id);
    final inCart = cart.items.any((i) => i.productId == product.id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x140087C8),
              blurRadius: 12,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ProductImage(imageUrl: product.imageUrl),
                ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: GestureDetector(
                    onTap: uid.isEmpty
                        ? null
                        : () => favs.toggleFavorite(uid, product.id),
                    child: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? AppColors.red : AppColors.textMuted,
                      size: 20,
                    ),
                  ),
                ),
                if (product.rewardPoints > 0)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.greenLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Earn ${product.rewardPoints} pts',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.green,
                        ),
                      ),
                    ),
                  ),
                if (product.isOffer)
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'OFFER',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 32,
              child: Text(
                product.name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'EGP ${product.price.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const Spacer(),
            if (inCart)
              _QuantityBar(product: product, uid: uid)
            else
              _AddButton(product: product, uid: uid),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final Product product;
  final String uid;
  const _AddButton({required this.product, required this.uid});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: uid.isEmpty
          ? null
          : () => context.read<CartProvider>().addToCart(uid, product),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient135,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Add to Cart',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _QuantityBar extends StatelessWidget {
  final Product product;
  final String uid;
  const _QuantityBar({required this.product, required this.uid});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final item = cart.items.firstWhere((i) => i.productId == product.id);
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient135,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context
                .read<CartProvider>()
                .updateQuantity(uid, item.id, item.quantity - 1),
            child: const Text(
              '−',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            '${item.quantity}',
            style: const TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
          ),
          GestureDetector(
            onTap: () => context
                .read<CartProvider>()
                .updateQuantity(uid, item.id, item.quantity + 1),
            child: const Text(
              '+',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
