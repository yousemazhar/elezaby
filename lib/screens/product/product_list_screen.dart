import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/global_app_bar.dart';

class ProductListScreen extends StatefulWidget {
  final String? categoryId;
  final String? subcategoryId;
  final String? subSubcategoryId;
  final String? title;

  const ProductListScreen({
    super.key,
    this.categoryId,
    this.subcategoryId,
    this.subSubcategoryId,
    this.title,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchCtrl = TextEditingController();
  List<Product>? _searchResults;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts(
            categoryId: widget.categoryId,
            subcategoryId: widget.subcategoryId,
            subSubcategoryId: widget.subSubcategoryId,
          );
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSearch(String q) async {
    if (q.isEmpty) {
      setState(() => _searchResults = null);
      return;
    }
    final results = await context.read<ProductProvider>().search(q);
    setState(() => _searchResults = results);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final displayList = _searchResults ?? provider.products;

    return Scaffold(
      appBar: GlobalAppBar(
        title: widget.title ?? 'All Products',
        showBackButton: true,
        showSearch: true,
        searchController: _searchCtrl,
        onSearchChanged: _onSearch,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Row(
              children: [
                Text(
                  (widget.categoryId != null ||
                          widget.subcategoryId != null ||
                          widget.subSubcategoryId != null)
                      ? 'Products'
                      : 'All Products',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${displayList.length}',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          if (provider.loadingProducts)
            const Expanded(
                child: Center(child: CircularProgressIndicator()))
          else if (displayList.isEmpty)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('😔', style: TextStyle(fontSize: 48)),
                    SizedBox(height: 12),
                    Text('No products found',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted)),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                itemCount: displayList.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.70,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, i) => ProductCard(
                  product: displayList[i],
                  onTap: () =>
                      context.push('/product/${displayList[i].id}'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
