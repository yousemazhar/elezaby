import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import 'app_search_bar.dart';

class GlobalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final bool showGreeting;
  final bool showSearch;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;

  const GlobalAppBar({
    super.key,
    this.title,
    this.showBackButton = false,
    this.showGreeting = false,
    this.showSearch = false,
    this.searchController,
    this.onSearchChanged,
  });

  @override
  Size get preferredSize => Size.fromHeight(showSearch ? 196 : 112);

  @override
  Widget build(BuildContext context) {
    final firstName = context
            .select<AuthProvider, String?>((auth) => auth.appUser?.name)
            ?.split(' ')
            .first ??
        'there';

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
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
            if (showGreeting) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Good day, $firstName',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
            if (showSearch) ...[
              const SizedBox(height: 10),
              AppSearchBar(
                controller: searchController,
                onChanged: onSearchChanged,
              ),
            ],
            const SizedBox(height: 12),
            Container(
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              ),
            ),
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
            child: Icon(
              Icons.shopping_bag_outlined,
              color: iconColor,
              size: 22,
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'el',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontStyle: FontStyle.italic,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: 'ezaby',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const Text(
          'العزبي',
          style: TextStyle(
            fontSize: 11,
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
