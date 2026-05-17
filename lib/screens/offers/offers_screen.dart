import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/global_app_bar.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadOffers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>();

    return Scaffold(
      appBar: const GlobalAppBar(title: 'Today\'s Offers'),
      body: Column(
        children: [
          // Banner

          if (products.loadingProducts)
            const Expanded(
                child: Center(child: CircularProgressIndicator()))
          else if (products.offers.isEmpty)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🏷️', style: TextStyle(fontSize: 56)),
                    SizedBox(height: 16),
                    Text(
                      'No offers right now',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                itemCount: products.offers.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.70,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, i) => ProductCard(
                  product: products.offers[i],
                  onTap: () =>
                      context.push('/product/${products.offers[i].id}'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
