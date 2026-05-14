import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/category.dart';
import '../../models/subcategory.dart';
import '../../models/sub_subcategory.dart';
import '../../providers/product_provider.dart';
import '../../widgets/global_app_bar.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  String? _activeCatId;
  String? _expandedSubId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<ProductProvider>();
      if (provider.categories.isEmpty || provider.subcategories.isEmpty) {
        await provider.loadShopTaxonomy();
      }
      if (!mounted) return;
      if (_activeCatId == null && provider.categories.isNotEmpty) {
        setState(() {
          _activeCatId = provider.categories.first.id;
          final subs = provider.subcategoriesFor(_activeCatId!);
          _expandedSubId = subs.isNotEmpty ? subs.first.id : null;
        });
      }
    });
  }

  void _onSelectCategory(String id, List<Subcategory> subsForCat) {
    setState(() {
      _activeCatId = id;
      _expandedSubId = subsForCat.isNotEmpty ? subsForCat.first.id : null;
    });
  }

  void _toggleSub(String id) {
    setState(() {
      _expandedSubId = _expandedSubId == id ? null : id;
    });
  }

  void _goToSubcategoryProducts(String subcategoryId, String title) {
    context.push('/products', extra: {
      'subcategoryId': subcategoryId,
      'title': title,
    });
  }

  void _goToSubSubcategoryProducts(String subSubcategoryId, String title) {
    context.push('/products', extra: {
      'subSubcategoryId': subSubcategoryId,
      'title': title,
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final categories = provider.categories;
    final loading = provider.loadingShopTaxonomy;

    return Scaffold(
      appBar: const GlobalAppBar(title: 'Shop', showBackButton: true),
      body: loading && categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : categories.isEmpty
              ? const Center(
                  child: Text('No categories yet',
                      style: TextStyle(color: AppColors.textMuted)),
                )
              : _buildBody(provider, categories),
    );
  }

  Widget _buildBody(ProductProvider provider, List<Category> categories) {
    final activeCat = categories.firstWhere(
      (c) => c.id == _activeCatId,
      orElse: () => categories.first,
    );
    final subs = provider.subcategoriesFor(activeCat.id);

    return Row(
      children: [
        // Sidebar
        Container(
          width: 120,
          color: AppColors.surface,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: categories.length,
            itemBuilder: (_, i) {
              final cat = categories[i];
              final isActive = cat.id == activeCat.id;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _onSelectCategory(
                    cat.id, provider.subcategoriesFor(cat.id)),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 20, horizontal: 10),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : Colors.transparent,
                    borderRadius: isActive
                        ? const BorderRadius.horizontal(
                            right: Radius.circular(8))
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text(cat.emoji,
                          style: const TextStyle(fontSize: 22)),
                      const SizedBox(height: 4),
                      Text(
                        cat.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color:
                              isActive ? Colors.white : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Content panel
        Expanded(
          child: subs.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(activeCat.emoji,
                            style: const TextStyle(fontSize: 36)),
                        const SizedBox(height: 8),
                        Text(activeCat.name,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark)),
                        const SizedBox(height: 8),
                        const Text('No subcategories yet',
                            style:
                                TextStyle(color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 100),
                  itemCount: subs.length,
                  itemBuilder: (_, i) {
                    final sub = subs[i];
                    final isExpanded = _expandedSubId == sub.id;
                    final subSubs = provider.subSubcategoriesFor(sub.id);
                    return _SubcategoryCard(
                      sub: sub,
                      isExpanded: isExpanded,
                      subSubs: subSubs,
                      onHeaderTap: () => _toggleSub(sub.id),
                      onSubSubTap: (ss) => _goToSubSubcategoryProducts(
                          ss.id, ss.name),
                      onSeeAll: () =>
                          _goToSubcategoryProducts(sub.id, sub.name),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _SubcategoryCard extends StatelessWidget {
  final Subcategory sub;
  final bool isExpanded;
  final List<SubSubcategory> subSubs;
  final VoidCallback onHeaderTap;
  final VoidCallback onSeeAll;
  final ValueChanged<SubSubcategory> onSubSubTap;

  const _SubcategoryCard({
    required this.sub,
    required this.isExpanded,
    required this.subSubs,
    required this.onHeaderTap,
    required this.onSeeAll,
    required this.onSubSubTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isExpanded ? Colors.white : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: isExpanded
            ? const [
                BoxShadow(
                    color: Color(0x140087C8),
                    blurRadius: 10,
                    offset: Offset(0, 2)),
              ]
            : const [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onHeaderTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                        child: Text(sub.emoji,
                            style: const TextStyle(fontSize: 20))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      sub.name,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_left,
                    color: AppColors.textDark,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            if (subSubs.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: subSubs.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisExtent: 110,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (_, i) {
                    final ss = subSubs[i];
                    return GestureDetector(
                      onTap: () => onSubSubTap(ss),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Center(
                                child: Text(ss.emoji,
                                    style: const TextStyle(fontSize: 24))),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            ss.name,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textDark),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
              child: GestureDetector(
                onTap: onSeeAll,
                child: const Center(
                  child: Text(
                    'SEE ALL PRODUCTS',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
