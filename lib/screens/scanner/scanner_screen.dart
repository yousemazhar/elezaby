import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';

const _kTutorialSeenKey = 'scanner_tutorial_seen_v1';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _ctrl = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool _scanning = true;
  bool _showUsageGuide = false;
  bool _tutorialChecked = false;
  bool _fetching = false;
  Product? _product;
  String? _scannedBarcode;
  bool _notFound = false;

  @override
  void initState() {
    super.initState();
    _loadTutorialState();
  }

  Future<void> _loadTutorialState() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(_kTutorialSeenKey) ?? false;
    if (!mounted) return;
    setState(() {
      _showUsageGuide = !seen;
      _tutorialChecked = true;
    });
  }

  Future<void> _dismissTutorial() async {
    setState(() => _showUsageGuide = false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kTutorialSeenKey, true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (!_scanning || _fetching) return;
    final barcode = capture.barcodes.firstOrNull?.rawValue;
    if (barcode == null || barcode.isEmpty) return;

    setState(() {
      _scanning = false;
      _fetching = true;
      _scannedBarcode = barcode;
      _notFound = false;
    });

    final p = await context.read<ProductProvider>().fetchByBarcode(barcode);
    if (!mounted) return;
    setState(() {
      _product = p;
      _notFound = p == null;
      _fetching = false;
    });
  }

  void _rescan() {
    setState(() {
      _product = null;
      _scannedBarcode = null;
      _notFound = false;
      _scanning = true;
    });
    _ctrl.start();
  }

  @override
  Widget build(BuildContext context) {
    final showingResult = _product != null || _notFound || _fetching;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(controller: _ctrl, onDetect: _onDetect),

          _ScanOverlay(dim: !showingResult),

          // AR overlays around the cutout (where the barcode sits in view)
          if (_fetching) const _ArLoading(),
          if (_product != null) _ArProductOverlay(product: _product!),
          if (_notFound && _scannedBarcode != null)
            _ArNotFound(barcode: _scannedBarcode!),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'AR Scan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.flash_on, color: Colors.white),
                    onPressed: () => _ctrl.toggleTorch(),
                  ),
                ],
              ),
            ),
          ),

          // Bottom action / instruction
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomBar(
              product: _product,
              showingResult: showingResult,
              onRescan: _rescan,
            ),
          ),

          // Tutorial — only on first launch
          if (_tutorialChecked && _showUsageGuide)
            _UsageGuideModal(onDismiss: _dismissTutorial),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final Product? product;
  final bool showingResult;
  final VoidCallback onRescan;
  const _BottomBar({
    required this.product,
    required this.showingResult,
    required this.onRescan,
  });

  @override
  Widget build(BuildContext context) {
    if (product != null) {
      final auth = context.read<AuthProvider>();
      final cart = context.read<CartProvider>();
      final uid = auth.appUser?.uid ?? '';
      return Container(
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(220),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white54),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: onRescan,
                child: const Text('Scan Again'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: uid.isEmpty || product!.stock == 0
                    ? null
                    : () {
                        cart.addToCart(uid, product!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Added to cart!'),
                            backgroundColor: AppColors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                child: const Text('Add to Cart'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.textDark,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => context.push('/product/${product!.id}'),
                child: const Text('Details'),
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      color: Colors.black.withAlpha(190),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Row(
        children: [
          const Icon(Icons.qr_code_scanner, color: Colors.white, size: 28),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Align a barcode inside the frame — AR details will appear around it',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.4),
            ),
          ),
          if (showingResult)
            GestureDetector(
              onTap: onRescan,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Retry',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScanOverlay extends StatelessWidget {
  final bool dim;
  const _ScanOverlay({required this.dim});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (dim) Container(color: Colors.black.withAlpha(100)),
        Center(
          child: Container(
            width: 240,
            height: 170,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                if (dim) const _ScanLine(),
                const Positioned(top: -2, left: -2, child: _Corner(topLeft: true)),
                const Positioned(top: -2, right: -2, child: _Corner(topRight: true)),
                const Positioned(
                    bottom: -2, left: -2, child: _Corner(bottomLeft: true)),
                const Positioned(
                    bottom: -2, right: -2, child: _Corner(bottomRight: true)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Corner extends StatelessWidget {
  final bool topLeft;
  final bool topRight;
  final bool bottomLeft;
  final bool bottomRight;

  const _Corner({
    this.topLeft = false,
    this.topRight = false,
    this.bottomLeft = false,
    this.bottomRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        border: Border(
          top: topLeft || topRight
              ? const BorderSide(color: AppColors.primary, width: 3)
              : BorderSide.none,
          bottom: bottomLeft || bottomRight
              ? const BorderSide(color: AppColors.primary, width: 3)
              : BorderSide.none,
          left: topLeft || bottomLeft
              ? const BorderSide(color: AppColors.primary, width: 3)
              : BorderSide.none,
          right: topRight || bottomRight
              ? const BorderSide(color: AppColors.primary, width: 3)
              : BorderSide.none,
        ),
        borderRadius: BorderRadius.only(
          topLeft: topLeft ? const Radius.circular(6) : Radius.zero,
          topRight: topRight ? const Radius.circular(6) : Radius.zero,
          bottomLeft: bottomLeft ? const Radius.circular(6) : Radius.zero,
          bottomRight: bottomRight ? const Radius.circular(6) : Radius.zero,
        ),
      ),
    );
  }
}

class _ScanLine extends StatefulWidget {
  const _ScanLine();

  @override
  State<_ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<_ScanLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2));
    _anim = Tween<double>(begin: 0, end: 1).animate(_ctrl)
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
      top: _anim.value * 150,
      left: 0,
      right: 0,
      child: Container(
        height: 2,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, Color(0xFF00BFEF), Colors.transparent],
          ),
        ),
      ),
    );
  }
}

class _ArLoading extends StatelessWidget {
  const _ArLoading();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 220),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(220),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF00BFEF).withAlpha(128)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Color(0xFF00BFEF)),
            ),
            SizedBox(width: 10),
            Text('Identifying product…',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _ArNotFound extends StatelessWidget {
  final String barcode;
  const _ArNotFound({required this.barcode});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 220),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(230),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.red.withAlpha(160)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Product not found',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(barcode,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _ArProductOverlay extends StatefulWidget {
  final Product product;
  const _ArProductOverlay({required this.product});

  @override
  State<_ArProductOverlay> createState() => _ArProductOverlayState();
}

class _ArProductOverlayState extends State<_ArProductOverlay>
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
    final size = MediaQuery.of(context).size;
    final centerY = size.height / 2;
    final centerX = size.width / 2;
    // Cutout is 240x170 centered.
    const cutoutW = 240.0;
    const cutoutH = 170.0;
    final topOfCutout = centerY - cutoutH / 2;
    final bottomOfCutout = centerY + cutoutH / 2;
    final leftOfCutout = centerX - cutoutW / 2;
    final rightOfCutout = centerX + cutoutW / 2;
    final p = widget.product;
    final flag = p.origin.toLowerCase().contains('egypt') ? '🇪🇬' : '🌍';

    return Stack(
      children: [
        // Top-left: product name + price card (with connecting line to cutout)
        Positioned(
          top: topOfCutout - 110 + _anim.value,
          left: 16,
          right: 16,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(235),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: const Color(0xFF00BFEF).withAlpha(160)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(110),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        p.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'EGP ${p.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                            color: Color(0xFF00BFEF),
                            fontSize: 13,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                Container(width: 2, height: 30, color: Colors.white60),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Right side: origin badge
        Positioned(
          top: topOfCutout - 4,
          left: rightOfCutout + 6,
          child: _ArPill(
            color: const Color(0xFFFFC800),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(flag, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  p.origin.isNotEmpty ? p.origin : 'Origin',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),

        // Right side: stock badge
        Positioned(
          top: topOfCutout + 30,
          left: rightOfCutout + 6,
          child: _ArPill(
            color: p.stock > 0 ? AppColors.green : AppColors.red,
            child: Text(
              p.stock > 0 ? 'In Stock' : 'Out',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),

        // Left side: manufacturer
        if (p.manufacturer.isNotEmpty)
          Positioned(
            top: topOfCutout + 4,
            right: size.width - leftOfCutout + 6,
            child: _ArPill(
              color: const Color(0xFF00BFEF),
              child: Text(
                p.manufacturer,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),

        // Left side: dosage form
        if (p.dosageForm.isNotEmpty)
          Positioned(
            top: topOfCutout + 38,
            right: size.width - leftOfCutout + 6,
            child: _ArPill(
              color: AppColors.primary,
              child: Text(
                p.dosageForm,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),

        // Bottom: details card under barcode
        Positioned(
          top: bottomOfCutout + 24 - _anim.value,
          left: 24,
          right: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
              ),
              Container(width: 2, height: 18, color: Colors.white60),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(235),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFF00BFEF).withAlpha(140)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (p.concentration.isNotEmpty)
                      _ArDetailRow(
                          icon: Icons.science_outlined,
                          label: p.concentration),
                    if (p.activeIngredient.isNotEmpty)
                      _ArDetailRow(
                          icon: Icons.biotech_outlined,
                          label: p.activeIngredient),
                    if (p.rewardPoints > 0)
                      _ArDetailRow(
                          icon: Icons.workspace_premium_outlined,
                          label: '+${p.rewardPoints} points'),
                    if (p.usageSteps.isNotEmpty)
                      _ArDetailRow(
                          icon: Icons.info_outline,
                          label: p.usageSteps.first,
                          maxLines: 2),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ArPill extends StatelessWidget {
  final Color color;
  final Widget child;
  const _ArPill({required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(235),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(180)),
        boxShadow: [
          BoxShadow(color: color.withAlpha(80), blurRadius: 10),
        ],
      ),
      child: child,
    );
  }
}

class _ArDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int maxLines;
  const _ArDetailRow(
      {required this.icon, required this.label, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF00BFEF)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}

class _UsageGuideModal extends StatefulWidget {
  final VoidCallback onDismiss;
  const _UsageGuideModal({required this.onDismiss});

  @override
  State<_UsageGuideModal> createState() => _UsageGuideModalState();
}

class _UsageGuideModalState extends State<_UsageGuideModal> {
  int _step = 0;

  static const _steps = [
    _GuideStep(
      emoji: '📷',
      title: 'Open Camera',
      desc: 'Allow camera access and point your phone at the product barcode',
    ),
    _GuideStep(
      emoji: '🔍',
      title: 'Scan the Barcode',
      desc:
          'Hold steady over the barcode. The blue line will scan automatically',
    ),
    _GuideStep(
      emoji: '✨',
      title: 'See AR Details',
      desc:
          'Product info, origin, and category appear as augmented reality overlays around the barcode',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final step = _steps[_step];
    return Container(
      color: Colors.black.withAlpha(153),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'How to Scan',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_steps.length, (i) {
                  final active = i == _step;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color:
                          active ? AppColors.primary : AppColors.divider,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  gradient: AppColors.rewardCardGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                    child: Text(step.emoji,
                        style: const TextStyle(fontSize: 36))),
              ),
              const SizedBox(height: 14),
              Text(
                step.title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark),
              ),
              const SizedBox(height: 6),
              Text(
                step.desc,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  if (_step > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _step--),
                        child: const Text('Back'),
                      ),
                    ),
                  if (_step > 0) const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _step < _steps.length - 1
                          ? () => setState(() => _step++)
                          : widget.onDismiss,
                      child: Text(_step < _steps.length - 1
                          ? 'Next'
                          : 'Start Scanning'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideStep {
  final String emoji, title, desc;
  const _GuideStep(
      {required this.emoji, required this.title, required this.desc});
}
