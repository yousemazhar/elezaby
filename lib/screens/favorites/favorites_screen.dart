import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/global_app_bar.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().appUser?.uid;
      if (uid != null) {
        context.read<FavoritesProvider>().loadFavoriteProducts(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavoritesProvider>();

    return Scaffold(
      appBar: const GlobalAppBar(title: 'Favourites'),
      body: Column(
        children: [
          if (favs.loading)
            const Expanded(
                child: Center(child: CircularProgressIndicator()))
          else if (favs.favoriteProducts.isEmpty)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('💔', style: TextStyle(fontSize: 56)),
                    SizedBox(height: 16),
                    Text(
                      'No favourites yet',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap the heart icon on products to save them',
                      style: TextStyle(
                          fontSize: 14, color: AppColors.textMuted),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: favs.favoriteProducts.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.70,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, i) => ProductCard(
                  product: favs.favoriteProducts[i],
                  onTap: () => context
                      .push('/product/${favs.favoriteProducts[i].id}'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
