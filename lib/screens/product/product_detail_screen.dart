import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/cart_item.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/product_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/global_app_bar.dart';
import '../../widgets/product_image.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Try from provider first
    final provider = context.read<ProductProvider>();
    Product? p;
    try {
      p = provider.products.firstWhere((x) => x.id == widget.productId);
    } catch (_) {
      p = await ProductService().fetchById(widget.productId);
    }
    if (mounted) {
      setState(() {
        _product = p;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_product == null) {
      return const Scaffold(
        appBar: GlobalAppBar(title: 'Product', showBackButton: true),
        body: Center(child: Text('Product not found')),
      );
    }
    return _ProductDetailBody(product: _product!);
  }
}

class _ProductDetailBody extends StatelessWidget {
  final Product product;
  const _ProductDetailBody({required this.product});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final cart = context.watch<CartProvider>();
    final favs = context.watch<FavoritesProvider>();
    final uid = auth.appUser?.uid ?? '';
    final isFav = favs.isFavorite(product.id);
    CartItem? cartItem;
    for (final i in cart.items) {
      if (i.productId == product.id) {
        cartItem = i;
        break;
      }
    }
    final inCart = cartItem != null;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.primaryLight,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textDark),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? AppColors.red : AppColors.textMuted,
                ),
                onPressed: uid.isEmpty
                    ? null
                    : () => favs.toggleFavorite(uid, product.id),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: CartAppBarAction(
                  iconColor: AppColors.textDark,
                  backgroundColor: Colors.white,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.primaryLight,
                child: ProductImage(imageUrl: product.imageUrl, iconSize: 80),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.isOffer)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('SPECIAL OFFER',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ),
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  if (product.nameArabic.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        product.nameArabic,
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.textMuted),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'EGP ${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const Spacer(),
                      if (product.rewardPoints > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.greenLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Earn ${product.rewardPoints} pts',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.green,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: product.stock > 0
                              ? AppColors.greenLight
                              : const Color(0xFFFFEEEE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.stock > 0
                              ? 'In Stock (${product.stock})'
                              : 'Out of Stock',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: product.stock > 0
                                ? AppColors.green
                                : AppColors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: 12),
                  // Details
                  _DetailSection(
                    title: 'Product Details',
                    children: [
                      if (product.activeIngredient.isNotEmpty)
                        _DetailRow(
                            'Active Ingredient', product.activeIngredient),
                      if (product.concentration.isNotEmpty)
                        _DetailRow('Concentration', product.concentration),
                      if (product.dosageForm.isNotEmpty)
                        _DetailRow('Form', product.dosageForm),
                      if (product.manufacturer.isNotEmpty)
                        _DetailRow('Manufacturer', product.manufacturer),
                      if (product.origin.isNotEmpty)
                        _DetailRow('Country of Origin', product.origin),
                    ],
                  ),
                  if (product.description.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _DetailSection(
                      title: 'Description',
                      children: [
                        Text(
                          product.description,
                          style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.5),
                        ),
                      ],
                    ),
                  ],
                  if (product.usageSteps.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _DetailSection(
                      title: 'How to Use',
                      children: product.usageSteps
                          .asMap()
                          .entries
                          .map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primaryLight,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${e.key + 1}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      e.value,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textSecondary,
                                          height: 1.4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Color(0x14000000),
                blurRadius: 16,
                offset: Offset(0, -4)),
          ],
        ),
        child: inCart
            ? SizedBox(
                height: 52,
                child: Material(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(26),
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    children: [
                      _QtyStepperButton(
                        icon: Icons.remove,
                        onTap: () {
                          final newQty = cartItem!.quantity - 1;
                          if (newQty <= 0) {
                            cart.removeItem(uid, cartItem.id);
                          } else {
                            cart.updateQuantity(uid, cartItem.id, newQty);
                          }
                        },
                      ),
                      SizedBox(
                        width: 36,
                        child: Center(
                          child: Text(
                            '${cartItem.quantity}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      _QtyStepperButton(
                        icon: Icons.add,
                        onTap: cartItem.quantity < product.stock
                            ? () => cart.updateQuantity(
                                uid, cartItem!.id, cartItem.quantity + 1)
                            : null,
                      ),
                      const SizedBox(width: 4),
                      Container(
                          width: 1, height: 24, color: Colors.white24),
                      Expanded(
                        child: InkWell(
                          onTap: () => context.push('/cart'),
                          child: Center(
                            child: Text(
                              'Go to Cart  •  EGP ${(product.price * cartItem.quantity).toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : AppButton(
                label: product.stock > 0 ? 'Add to Cart' : 'Out of Stock',
                onPressed: product.stock > 0 && uid.isNotEmpty
                    ? () => context.read<CartProvider>().addToCart(uid, product)
                    : null,
              ),
      ),
    );
  }
}

class _QtyStepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _QtyStepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 44,
        height: 52,
        child: Icon(
          icon,
          size: 22,
          color: enabled ? Colors.white : Colors.white38,
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _DetailSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark),
        ),
        const SizedBox(height: 10),
        ...children,
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style:
                    const TextStyle(fontSize: 13, color: AppColors.textMuted)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark)),
          ),
        ],
      ),
    );
  }
}
