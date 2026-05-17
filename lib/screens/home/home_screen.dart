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
          // First Order Reward Banner
          SliverToBoxAdapter(
            child: _FirstOrderBanner(
                completed: auth.appUser?.firstOrderCompleted ?? false),
          ),
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
          SliverToBoxAdapter(
            child: products.loadingCategories
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
  final bool completed;
  const _FirstOrderBanner({required this.completed});

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
                Text(
                  completed
                      ? 'You\'ve earned 50 points!'
                      : 'Earn 50 Points on Your First Order!',
                  style: const TextStyle(
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
                  child: Text(
                    completed ? '✅ Reward Claimed' : '🎁 Welcome Reward',
                    style: const TextStyle(
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
  const _ServicesRow({
    required this.onScanTap,
    required this.onPrescriptionTap,
  });

  @override
  Widget build(BuildContext context) {
    final services = <({String icon, String label, VoidCallback onTap})>[
      (icon: '📷', label: 'Scan / AR', onTap: onScanTap),
      (icon: '📋', label: 'Upload Prescription', onTap: onPrescriptionTap),
      // TODO: route to mobility aids catalog when available
      (icon: '♿', label: 'Mobility Aids', onTap: () {}),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          for (var i = 0; i < services.length; i++) ...[
            Expanded(
              child: GestureDetector(
                onTap: services[i].onTap,
                child: Container(
                  height: 132,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(services[i].icon,
                          style: const TextStyle(fontSize: 28)),
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
            if (i != services.length - 1) const SizedBox(width: 12),
          ],
        ],
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
      (emoji: '💊', color: Color(0xFFE8F4F8)),
      (emoji: '🍼', color: Color(0xFFFFF0E8)),
      (emoji: '🧴', color: Color(0xFFE8F9EE)),
      (emoji: '💉', color: Color(0xFFF3EAF8)),
      (emoji: '🩺', color: Color(0xFFFFF8E8)),
    ];

    final cats = products.categories;
    final count = cats.isNotEmpty ? cats.length : fallbackCats.length;

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final emoji = cats.isNotEmpty
              ? cats[i].emoji
              : fallbackCats[i % fallbackCats.length].emoji;
          final color = i < fallbackCats.length
              ? fallbackCats[i].color
              : AppColors.primaryLight;
          final catId = cats.isNotEmpty ? cats[i].id : null;

          return GestureDetector(
            onTap: () => context.push(
              '/products',
              extra: catId != null ? {'categoryId': catId} : null,
            ),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 30)),
              ),
            ),
          );
        },
      ),
    );
  }
}

