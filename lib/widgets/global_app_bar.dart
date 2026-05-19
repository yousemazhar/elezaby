import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../providers/cart_provider.dart';
import 'app_search_bar.dart';

class GlobalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final bool showSearch;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;

  const GlobalAppBar({
    super.key,
    this.title,
    this.showBackButton = false,
    this.showSearch = false,
    this.searchController,
    this.onSearchChanged,
  });

  @override
  Size get preferredSize => Size.fromHeight(showSearch ? 168 : 92);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
              child: SizedBox(
                height: 48,
                child: Row(
                  children: [
                    SizedBox(
                      width: 48,
                      child: showBackButton
                          ? IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.go('/home');
                                }
                              },
                            )
                          : null,
                    ),
                    Expanded(
                      child: title == null
                          ? const _ElezabyLogo()
                          : Text(
                              title!,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                    const CartAppBarAction(),
                  ],
                ),
              ),
            ),
            if (showSearch) ...[
              const SizedBox(height: 12),
              AppSearchBar(
                controller: searchController,
                onChanged: onSearchChanged,
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class CartAppBarAction extends StatelessWidget {
  final Color iconColor;
  final Color backgroundColor;

  const CartAppBarAction({
    super.key,
    this.iconColor = Colors.white,
    this.backgroundColor = const Color(0x2EFFFFFF),
  });

  @override
  Widget build(BuildContext context) {
    final itemCount = context.select<CartProvider, int>((cart) => cart.itemCount);

    return GestureDetector(
      onTap: () => context.push('/cart'),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              'assets/icons/cart.png',
              width: 22,
              height: 22,
              color: iconColor,
            ),
          ),
          if (itemCount > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: AppColors.red,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                  child: Text(
                    itemCount > 99 ? '99+' : '$itemCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ElezabyLogo extends StatelessWidget {
  const _ElezabyLogo();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/elezaby_logo_white.png',
      height: 36,
      fit: BoxFit.contain,
    );
  }
}
