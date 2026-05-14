# El Ezaby — Project Rules

## Project Overview
Flutter + Firebase pharmacy shopping app modelled on El Ezaby.
Package: `com.example.elezaby`
Firebase project: `elezaby-6cfd9`

## Flutter Rules (inherits global rules)
- Run `flutter analyze` after EVERY set of changes — zero warnings allowed.
- Use `Provider` (not Riverpod) for state management.
- Use `GoRouter` for all navigation.
- All async Firebase calls must show loading / error / empty states.
- Never block the UI isolate — barcode scanning runs in its own isolate via mobile_scanner.
- Use `CachedNetworkImage` for all product/category images.

## Firebase Setup Required (manual steps)
1. Google Sign-In → SHA-1 fingerprint must be added in Firebase console for Android.
2. Firestore rules must be deployed: `firebase deploy --only firestore:rules`.
3. After ANY function change: `firebase deploy --only functions`.
4. `firebase_options.dart` MUST be present (run `flutterfire configure` if missing).

## App Theme
- Primary blue: `#0087C8`
- Dark blue: `#006FA8`
- Light blue bg: `#EAF8FC`
- Lighter blue bg: `#D5F1FA`
- Bottom nav bg: `#DDF5FC`
- Dark text: `#30343B`
- Muted text: `#9AA5B0`
- Green (rewards): `#20A766`
- Red badge: `#FF3B30`

## Architecture
```
lib/
  main.dart         — Firebase init + runApp
  app.dart          — MaterialApp.router with GoRouter
  core/
    constants/      — AppColors, AppConstants
    theme/          — AppTheme
    utils/          — AppRouter
  models/           — AppUser, Product, Category, CartItem, AppOrder
  services/         — AuthService, ProductService, CartService, OrderService, RewardService, SeedService
  providers/        — AuthProvider, ProductProvider, CartProvider, FavoritesProvider, RewardProvider
  screens/          — one folder per screen group
  widgets/          — reusable widgets
```

## Firebase Data Model
- `users/{uid}` — name, email, phone, rewardPoints, firstOrderCompleted, createdAt
- `products/{id}` — name, nameArabic, price, imageUrl, categoryId, barcode, manufacturer, origin, stock, rewardPoints, isOffer, usageSteps, description
- `categories/{id}` — name, emoji, sortOrder
- `carts/{uid}/items/{itemId}` — productId, quantity, price, addedAt
- `favorites/{uid}/items/{itemId}` — productId, addedAt
- `orders/{id}` — userId, items, subtotal, deliveryFee, total, status, rewardPointsEarned, createdAt

## Barcode / AR
- Use `mobile_scanner` plugin only — no native camera calls.
- AR is simulated: floating overlay widgets on top of scanner view.
- Seed products have test barcodes starting with `TEST-`.

## Seeding
Run seed via Profile screen "Seed Demo Data" button (dev only).
Seed creates: 5 categories + 10 products + test barcodes.
