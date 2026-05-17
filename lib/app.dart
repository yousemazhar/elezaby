import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_router.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/address_provider.dart';
import 'services/notification_service.dart';

class ElezabyApp extends StatefulWidget {
  const ElezabyApp({super.key});

  @override
  State<ElezabyApp> createState() => _ElezabyAppState();
}

class _ElezabyAppState extends State<ElezabyApp> {
  late final AuthProvider _authProvider;
  late final CartProvider _cartProvider;
  late final FavoritesProvider _favoritesProvider;
  late final AddressProvider _addressProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider();
    _cartProvider = CartProvider();
    _favoritesProvider = FavoritesProvider();
    _addressProvider = AddressProvider();

    _authProvider.listenToAuthState();
    _authProvider.addListener(_onAuthChange);
  }

  String? _lastUid;

  void _onAuthChange() {
    final uid = _authProvider.appUser?.uid;
    if (uid != null) {
      _cartProvider.startListening(uid);
      _favoritesProvider.startListening(uid);
      _addressProvider.startListening(uid);
      NotificationService.instance.registerTokenForUser(uid);
      _lastUid = uid;
    } else {
      _cartProvider.stopListening();
      _favoritesProvider.stopListening();
      _addressProvider.stopListening();
      final prev = _lastUid;
      if (prev != null) {
        NotificationService.instance.unregisterTokenForUser(prev);
        _lastUid = null;
      }
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider.value(value: _cartProvider),
        ChangeNotifierProvider.value(value: _favoritesProvider),
        ChangeNotifierProvider.value(value: _addressProvider),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: Builder(
        builder: (ctx) {
          final router = buildRouter(ctx);
          return MaterialApp.router(
            title: 'elezaby',
            theme: AppTheme.light,
            routerConfig: router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
