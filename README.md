# El Ezaby

A Flutter + Firebase pharmacy shopping app modelled on El Ezaby.

- **Package:** `com.example.elezaby`
- **Firebase project:** `elezaby-6cfd9`

## Features

- Browse products by category with Arabic/English names
- Cart and checkout with delivery fee + order tracking
- Favorites and reward points (earned per order)
- Barcode scanning via `mobile_scanner` with simulated AR overlay
- Google Sign-In + email/password auth
- Cached product imagery via `cached_network_image`

## Tech Stack

- **State management:** `provider`
- **Routing:** `go_router`
- **Backend:** Firebase Auth, Firestore, Cloud Functions
- **Scanning:** `mobile_scanner` (runs in its own isolate)

## Project Structure

```
lib/
  main.dart         Firebase init + runApp
  app.dart          MaterialApp.router with GoRouter
  core/             constants, theme, router
  models/           AppUser, Product, Category, CartItem, AppOrder
  services/         Auth, Product, Cart, Order, Reward, Seed
  providers/        Auth, Product, Cart, Favorites, Reward
  screens/          one folder per screen group
  widgets/          reusable widgets
```

## Firestore Collections

- `users/{uid}` — name, email, phone, rewardPoints, firstOrderCompleted, createdAt
- `products/{id}` — name, nameArabic, price, imageUrl, categoryId, barcode, manufacturer, origin, stock, rewardPoints, isOffer, usageSteps, description
- `categories/{id}` — name, emoji, sortOrder
- `carts/{uid}/items/{itemId}` — productId, quantity, price, addedAt
- `favorites/{uid}/items/{itemId}` — productId, addedAt
- `orders/{id}` — userId, items, subtotal, deliveryFee, total, status, rewardPointsEarned, createdAt

## Getting Started

1. Install Flutter (matching the SDK constraint in `pubspec.yaml`).
2. Install deps:
   ```
   flutter pub get
   ```
3. Configure Firebase (generates `firebase_options.dart`):
   ```
   flutterfire configure --project=elezaby-6cfd9
   ```
4. Add your Android debug SHA-1 to the Firebase console (required for Google Sign-In).
5. Deploy backend pieces as needed:
   ```
   firebase deploy --only firestore:rules
   firebase deploy --only functions
   ```
6. Run the app:
   ```
   flutter run
   ```

## Seeding Demo Data

Use the **Seed Demo Data** button on the Profile screen (dev only). It creates 5 categories + 10 products with test barcodes prefixed `TEST-`.

## Theme

| Token | Value |
|---|---|
| Primary blue | `#0087C8` |
| Dark blue | `#006FA8` |
| Light blue bg | `#EAF8FC` |
| Lighter blue bg | `#D5F1FA` |
| Bottom nav bg | `#DDF5FC` |
| Dark text | `#30343B` |
| Muted text | `#9AA5B0` |
| Green (rewards) | `#20A766` |
| Red badge | `#FF3B30` |

## Deployment

The app is deployed to Firebase Hosting for the `elezaby-6cfd9` project.

### Web build + hosting

```
flutter build web --release
firebase deploy --only hosting
```

The `public/` directory is the configured hosting target (see `firebase.json`). Build artifacts from `build/web` should be copied/pointed there before deploy.

### Backend pieces

Deploy independently as they change:

```
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
firebase deploy --only functions
firebase deploy --only storage
```

Full deploy (all targets):

```
firebase deploy
```

### Pre-deploy checklist

- `flutter analyze` exits clean.
- `firebase_options.dart` is up to date (`flutterfire configure` if not).
- Android release SHA-1 added to Firebase console for Google Sign-In.
- App Check debug tokens registered for any dev/emulator clients.
- Cloud Functions deployed **before** clients that depend on new callable signatures.

## Development Notes

- Run `flutter analyze` after every change — the project requires zero warnings.
- All async Firebase calls must surface loading / error / empty states.
- Never block the UI isolate; keep scanning and heavy work off the main thread.
