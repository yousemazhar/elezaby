import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';

class ScanResultScreen extends StatefulWidget {
  final String barcode;
  const ScanResultScreen({super.key, required this.barcode});

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  Product? _product;
  bool _loading = true;
  bool _showArOverlay = false;

  @override
  void initState() {
    super.initState();
    _fetchProduct();
  }

  Future<void> _fetchProduct() async {
    final p = await context.read<ProductProvider>().fetchByBarcode(widget.barcode);
    if (mounted) setState(() { _product = p; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fake camera background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A1A1A), Color(0xFF2A2A2A)],
              ),
            ),
          ),

          // AR overlays if product found
          if (_product != null && _showArOverlay) ...[
            _ArProductLabel(product: _product!),
            Positioned(
              top: 80,
              right: 24,
              child: _ArOriginBadge(origin: _product!.origin),
            ),
          ],

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Scan Result',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (_product != null)
                    TextButton(
                      onPressed: () =>
                          setState(() => _showArOverlay = !_showArOverlay),
                      child: Text(
                        _showArOverlay ? 'Hide AR' : 'Show AR',
                        style: const TextStyle(
                            color: Color(0xFF00BFEF),
                            fontWeight: FontWeight.w700),
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),
          ),

          // Result panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _loading
                ? _LoadingPanel()
                : _product == null
                    ? _NotFoundPanel(barcode: widget.barcode)
                    : _ProductPanel(product: _product!),
          ),
        ],
      ),
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(32),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text('Searching for product...',
              style: TextStyle(
                  fontSize: 14, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _NotFoundPanel extends StatelessWidget {
  final String barcode;
  const _NotFoundPanel({required this.barcode});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('😔', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          const Text(
            'Product Not Found',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          Text(
            'Barcode: $barcode',
            style: const TextStyle(
                fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          const Text(
            'This product is not in our catalogue yet.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          AppButton(
            label: 'Scan Again',
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }
}

class _ProductPanel extends StatelessWidget {
  final Product product;
  const _ProductPanel({required this.product});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    final uid = auth.appUser?.uid ?? '';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Product header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Icon(Icons.medication_rounded,
                      size: 32, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.greenLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product.stock > 0 ? 'In Stock' : 'Out of Stock',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: product.stock > 0
                              ? AppColors.green
                              : AppColors.red,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.name,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'EGP ${product.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Detail chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (product.dosageForm.isNotEmpty)
                _Chip(product.dosageForm),
              if (product.manufacturer.isNotEmpty)
                _Chip(product.manufacturer),
              if (product.origin.isNotEmpty)
                _Chip('📍 ${product.origin}'),
              if (product.concentration.isNotEmpty)
                _Chip(product.concentration),
            ],
          ),
          if (product.usageSteps.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Usage',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textNavy),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.usageSteps.first,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Add to Cart',
                  onPressed: uid.isEmpty || product.stock == 0
                      ? null
                      : () {
                          cart.addToCart(uid, product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Added to cart!'),
                              backgroundColor: AppColors.green,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  label: 'View Details',
                  outlined: true,
                  onPressed: () =>
                      context.push('/product/${product.id}'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _ArProductLabel extends StatefulWidget {
  final Product product;
  const _ArProductLabel({required this.product});

  @override
  State<_ArProductLabel> createState() => _ArProductLabelState();
}

class _ArProductLabelState extends State<_ArProductLabel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3));
    _anim = Tween<double>(begin: 0, end: -6).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut))
      ..addListener(() => setState(() {}));
    _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 160 + _anim.value,
      left: 0,
      right: 0,
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(235),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFF00BFEF).withAlpha(128)),
              ),
              child: Column(
                children: [
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'EGP ${widget.product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                        color: Color(0xFF00BFEF),
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Container(width: 2, height: 30, color: Colors.white.withAlpha(178)),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(230),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArOriginBadge extends StatelessWidget {
  final String origin;
  const _ArOriginBadge({required this.origin});

  @override
  Widget build(BuildContext context) {
    final flag = origin.toLowerCase().contains('egypt') ? '🇪🇬' : '🌍';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(235),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFC800).withAlpha(100)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(flag, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 6),
          Text(
            origin.isNotEmpty ? origin : 'Unknown',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
