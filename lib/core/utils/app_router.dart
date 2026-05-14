import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/app_order.dart';
import '../../providers/auth_provider.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/home/main_shell.dart';
import '../../screens/product/product_list_screen.dart';
import '../../screens/product/product_detail_screen.dart';
import '../../screens/cart/cart_screen.dart';
import '../../screens/checkout/checkout_screen.dart';
import '../../screens/checkout/order_success_screen.dart';
import '../../screens/scanner/scanner_screen.dart';
import '../../screens/scanner/scan_result_screen.dart';
import '../../screens/addresses/addresses_screen.dart';
import '../../screens/orders/orders_screen.dart';
import '../../screens/notifications/notifications_screen.dart';
import '../../screens/favorites/favorites_screen.dart';

GoRouter buildRouter(BuildContext context) {
  return GoRouter(
    initialLocation: '/',
    redirect: (ctx, state) {
      final auth = ctx.read<AuthProvider>();
      final loggedIn = auth.isLoggedIn;
      final loc = state.uri.path;

      final publicRoutes = ['/login', '/signup', '/'];
      if (!loggedIn && !publicRoutes.contains(loc)) {
        return '/login';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (_, __) => const SignupScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const MainShell(),
      ),
      GoRoute(
        path: '/products',
        builder: (ctx, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final catId = extra?['categoryId'] as String?;
          final subId = extra?['subcategoryId'] as String?;
          final subSubId = extra?['subSubcategoryId'] as String?;
          final title = extra?['title'] as String?;
          return ProductListScreen(
            categoryId: catId,
            subcategoryId: subId,
            subSubcategoryId: subSubId,
            title: title,
          );
        },
      ),
      GoRoute(
        path: '/product/:id',
        builder: (ctx, state) {
          return ProductDetailScreen(
              productId: state.pathParameters['id']!);
        },
      ),
      GoRoute(
        path: '/cart',
        builder: (_, __) => const CartScreen(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (_, __) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/order-success',
        builder: (ctx, state) {
          final order = state.extra as AppOrder;
          return OrderSuccessScreen(order: order);
        },
      ),
      GoRoute(
        path: '/scanner',
        builder: (_, __) => const ScannerScreen(),
      ),
      GoRoute(
        path: '/scan-result',
        builder: (ctx, state) {
          final barcode = state.extra as String;
          return ScanResultScreen(barcode: barcode);
        },
      ),
      GoRoute(
        path: '/addresses',
        builder: (_, __) => const AddressesScreen(),
      ),
      GoRoute(
        path: '/orders',
        builder: (_, __) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/favorites',
        builder: (_, __) => const FavoritesScreen(),
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
}
