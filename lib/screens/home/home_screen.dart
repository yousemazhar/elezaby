import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/address_provider.dart';
import '../../widgets/global_app_bar.dart';
import '../../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _deliveryTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadCategories();
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final products = context.watch<ProductProvider>();
    final addressProvider = context.watch<AddressProvider>();
    final defaultAddress = addressProvider.defaultAddress;

    return Scaffold(
      appBar: const GlobalAppBar(showSearch: true),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _DeliveryTabs(
                selected: _deliveryTab,
                onSelect: (i) => setState(() => _deliveryTab = i),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 4)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.location_on,
                      color: AppColors.primary, size: 14),
                  const SizedBox(width: 4),
                  const Text('Delivers to ',
                      style:
                          TextStyle(fontSize: 13, color: AppColors.textMuted)),
                  Flexible(
                    child: Text(
                      defaultAddress?.displayLine ?? 'Add an address',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: defaultAddress != null
                              ? AppColors.primary
                              : AppColors.textMuted),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => context.push('/addresses'),
                    child: const Text('Change',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary)),
                  ),
                ],
              ),
            ),
          ),
          // First Order Reward Banner (hidden once completed)
          if (!(auth.appUser?.firstOrderCompleted ?? false))
            const SliverToBoxAdapter(child: _FirstOrderBanner()),
          // Services
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text('Services',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark)),
            ),
          ),
          SliverToBoxAdapter(
            child: _ServicesRow(
              onScanTap: () => context.push('/scanner'),
              onPrescriptionTap: () => context.push('/prescription-upload'),
              onArVideoTap: () => context.push('/scanner-video'),
            ),
          ),
          // Categories
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Shop by category',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                  GestureDetector(
                    onTap: () => context.push('/shop'),
                    child: const Text('See All ›',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary)),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: (products.loadingCategories ||
                    !products.categoryImagesLoaded)
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _CategoriesRow(products: products),
          ),
          // Featured products
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Featured Products',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                  GestureDetector(
                    onTap: () => context.push('/products'),
                    child: const Text('See All ›',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary)),
                  ),
                ],
              ),
            ),
          ),
          if (products.loadingProducts)
            const SliverToBoxAdapter(
                child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator())))
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final p = products.products[i];
                    return ProductCard(
                      product: p,
                      onTap: () => context.push('/product/${p.id}'),
                    );
                  },
                  childCount: products.products.length > 6
                      ? 6
                      : products.products.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.70,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DeliveryTabs extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;
  const _DeliveryTabs({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE9F2F5),
        borderRadius: BorderRadius.circular(18),
      ),
      child:


      Row(
        children: [
          _Tab(
              label: 'Home Delivery',
              active: selected == 0,
              onTap: () => onSelect(0)),
          _Tab(
              label: 'Pharmacy Pickup',
              active: selected == 1,
              onTap: () => onSelect(1)),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Tab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: active ? AppColors.primaryLighter : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: active ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _FirstOrderBanner extends StatelessWidget {
  const _FirstOrderBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      height: 132,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              ),
              shape: BoxShape.circle,
            ),
            child:
                const Center(child: Text('⭐', style: TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'FIRST ORDER REWARD',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white70,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Earn 50 Points on Your First Order!',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(46),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '🎁 Welcome Reward',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServicesRow extends StatelessWidget {
  final VoidCallback onScanTap;
  final VoidCallback onPrescriptionTap;
  final VoidCallback onArVideoTap;
  const _ServicesRow({
    required this.onScanTap,
    required this.onPrescriptionTap,
    required this.onArVideoTap,
  });

  @override
  Widget build(BuildContext context) {
    final services = <({Widget icon, String label, VoidCallback onTap})>[
      (
        icon: Image.asset('assets/icons/scan_AR.png', width: 52, height: 52),
        label: 'Scan / AR',
        onTap: onScanTap,
      ),
      (
        icon: Image.asset('assets/icons/AR_video.png', width: 60, height: 60),
        label: 'Scan for tutorial',
        onTap: onArVideoTap,
      ),
      (
        icon: Image.asset('assets/icons/Prescription.png', width: 60, height: 60),
        label: 'Upload Prescription',
        onTap: onPrescriptionTap,
      ),
      (
        icon: Image.asset('assets/icons/mobility_aids.png', width: 60, height: 60),
        label: 'Mobility Aids',
        onTap: () {
          context.push('/products', extra: {
            'categoryId': 'mobility_aids',
            'title': 'mobility aids',
          });
        },
      ),
    ];

    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: services.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) => GestureDetector(
          onTap: services[i].onTap,
          child: Container(
            width: 110,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            padding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                services[i].icon,
                const SizedBox(height: 8),
                Text(
                  services[i].label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textNavy,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoriesRow extends StatelessWidget {
  final ProductProvider products;
  const _CategoriesRow({required this.products});

  @override
  Widget build(BuildContext context) {
    const fallbackCats = [
      (name: 'Medicines', emoji: '💊', color: Color(0xFFE8F4F8)),
      (name: 'Baby', emoji: '🍼', color: Color(0xFFFFF0E8)),
      (name: 'Personal Care', emoji: '🧴', color: Color(0xFFE8F9EE)),
      (name: 'Injections', emoji: '💉', color: Color(0xFFF3EAF8)),
      (name: 'Medical', emoji: '🩺', color: Color(0xFFFFF8E8)),
    ];

    final cats = products.categoriesWithProducts;
    final useFallback = cats.isEmpty;
    final count = useFallback ? fallbackCats.length : cats.length;

    final half = (count / 2).ceil();
    final topIndexes = List<int>.generate(half, (i) => i);
    final bottomIndexes =
        List<int>.generate(count - half, (i) => i + half);

    Widget buildRow(List<int> indexes) {
      return SizedBox(
        height: 110,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: indexes.length,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (context, idx) {
            final i = indexes[idx];
            final emoji = useFallback
                ? fallbackCats[i % fallbackCats.length].emoji
                : cats[i].emoji;
            final name = useFallback
                ? fallbackCats[i % fallbackCats.length].name
                : cats[i].name;
            final color = i < fallbackCats.length
                ? fallbackCats[i].color
                : AppColors.primaryLight;
            final catId = useFallback ? null : cats[i].id;
            final imageUrls = catId != null
                ? (products.categoryImages[catId] ?? const <String>[])
                : const <String>[];

            return GestureDetector(
              onTap: () => context.push(
                '/products',
                extra: catId != null ? {'categoryId': catId} : null,
              ),
              child: SizedBox(
                width: 80,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _CategoryAvatar(
                      imageUrls: imageUrls,
                      emoji: emoji,
                      background: color,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    return Column(
      children: [
        buildRow(topIndexes),
        const SizedBox(height: 10),
        if (bottomIndexes.isNotEmpty) buildRow(bottomIndexes),
      ],
    );
  }
}

class _CategoryAvatar extends StatefulWidget {
  final List<String> imageUrls;
  final String emoji;
  final Color background;
  const _CategoryAvatar({
    required this.imageUrls,
    required this.emoji,
    required this.background,
  });

  @override
  State<_CategoryAvatar> createState() => _CategoryAvatarState();
}

class _CategoryAvatarState extends State<_CategoryAvatar> {
  int _attempt = 0;

  @override
  void didUpdateWidget(covariant _CategoryAvatar old) {
    super.didUpdateWidget(old);
    if (old.imageUrls != widget.imageUrls) _attempt = 0;
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _attempt < widget.imageUrls.length;
    final url = hasImage ? widget.imageUrls[_attempt] : null;

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: widget.background,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: url != null
          ? CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 150),
              placeholder: (_, __) => Center(
                child: Text(widget.emoji, style: const TextStyle(fontSize: 28)),
              ),
              errorWidget: (_, __, ___) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) setState(() => _attempt++);
                });
                return Center(
                  child:
                      Text(widget.emoji, style: const TextStyle(fontSize: 28)),
                );
              },
            )
          : Center(
              child: Text(widget.emoji, style: const TextStyle(fontSize: 28)),
            ),
    );
  }
}
