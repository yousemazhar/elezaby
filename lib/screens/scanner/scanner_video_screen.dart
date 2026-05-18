import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../core/constants/app_colors.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';

class ScannerVideoScreen extends StatefulWidget {
  const ScannerVideoScreen({super.key});

  @override
  State<ScannerVideoScreen> createState() => _ScannerVideoScreenState();
}

class _ScannerVideoScreenState extends State<ScannerVideoScreen> {
  final MobileScannerController _ctrl = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool _scanning = true;
  bool _fetching = false;
  Product? _product;
  String? _scannedBarcode;
  bool _notFound = false;

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

    if (p != null && p.videoUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No video available for this product'),
          duration: Duration(seconds: 2),
        ),
      );
      setState(() {
        _fetching = false;
        _scanning = true;
        _scannedBarcode = null;
      });
      return;
    }

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

          if (!showingResult) Container(color: Colors.black.withAlpha(100)),

          // Cutout frame
          if (_product == null)
            Center(
              child: Container(
                width: 240,
                height: 170,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

          if (_fetching) const _ArLoading(),
          if (_product != null && _product!.videoUrl.isNotEmpty)
            _ArVideoOverlay(product: _product!),
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
                      'AR Video',
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

          // Bottom bar
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
    final p = product;
    if (p != null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(230),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (p.imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: p.imageUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => const SizedBox(
                          width: 56,
                          height: 56,
                          child:
                              Icon(Icons.medication, color: Colors.white54)),
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        p.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
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
              ],
            ),
            const SizedBox(height: 10),
            if (p.manufacturer.isNotEmpty)
              _MinimalRow(icon: Icons.factory_outlined, text: p.manufacturer),
            if (p.activeIngredient.isNotEmpty)
              _MinimalRow(
                  icon: Icons.biotech_outlined,
                  text: p.concentration.isNotEmpty
                      ? '${p.activeIngredient} • ${p.concentration}'
                      : p.activeIngredient),
            const SizedBox(height: 12),
            Row(
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
                    onPressed: () => context.push('/product/${p.id}'),
                    child: const Text('Details'),
                  ),
                ),
              ],
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
          const Icon(Icons.play_circle_outline,
              color: Colors.white, size: 28),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Scan a product barcode to watch its instructional video',
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

class _MinimalRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MinimalRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF00BFEF)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
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
                style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _ArVideoOverlay extends StatefulWidget {
  final Product product;
  const _ArVideoOverlay({required this.product});

  @override
  State<_ArVideoOverlay> createState() => _ArVideoOverlayState();
}

class _ArVideoOverlayState extends State<_ArVideoOverlay> {
  VideoPlayerController? _videoCtrl;
  bool _initError = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    final ctrl =
        VideoPlayerController.networkUrl(Uri.parse(widget.product.videoUrl));
    _videoCtrl = ctrl;
    try {
      await ctrl.initialize();
      await ctrl.setLooping(true);
      await ctrl.setVolume(1);
      await ctrl.play();
    } catch (_) {
      if (mounted) setState(() => _initError = true);
      return;
    }
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant _ArVideoOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product.videoUrl != widget.product.videoUrl) {
      _videoCtrl?.dispose();
      _videoCtrl = null;
      _initError = false;
      _initVideo();
    }
  }

  @override
  void dispose() {
    _videoCtrl?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    final c = _videoCtrl;
    if (c == null || !c.value.isInitialized) return;
    setState(() {
      if (c.value.isPlaying) {
        c.pause();
      } else {
        c.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topInset = MediaQuery.of(context).padding.top;
    final videoWidth = size.width - 32;
    final ctrl = _videoCtrl;
    final isReady = ctrl != null && ctrl.value.isInitialized;
    final aspect = isReady ? ctrl.value.aspectRatio : 16 / 9;

    return Positioned(
      top: topInset + 56,
      left: 16,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(235),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF00BFEF).withAlpha(160)),
          boxShadow: [
            BoxShadow(
                color: AppColors.primary.withAlpha(110), blurRadius: 18),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: videoWidth,
                child: AspectRatio(
                  aspectRatio: aspect,
                  child: _initError
                      ? const Center(
                          child: Text(
                            'Could not load video',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : isReady
                          ? GestureDetector(
                              onTap: _togglePlayPause,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  VideoPlayer(ctrl),
                                  if (!ctrl.value.isPlaying)
                                    Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child: const Icon(Icons.play_arrow,
                                          color: Colors.white, size: 36),
                                    ),
                                ],
                              ),
                            )
                          : const Center(
                              child: SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF00BFEF)),
                              ),
                            ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                widget.product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
