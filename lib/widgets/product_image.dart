import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class ProductImage extends StatelessWidget {
  final String imageUrl;
  final double iconSize;
  final BoxFit fit;

  const ProductImage({
    super.key,
    required this.imageUrl,
    this.iconSize = 40,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _FallbackProductImage(iconSize: iconSize);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      placeholder: (_, __) => _FallbackProductImage(iconSize: iconSize),
      errorWidget: (_, __, ___) => _FallbackProductImage(iconSize: iconSize),
    );
  }
}

class _FallbackProductImage extends StatelessWidget {
  final double iconSize;

  const _FallbackProductImage({required this.iconSize});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.medication_rounded,
        size: iconSize,
        color: AppColors.primary,
      ),
    );
  }
}
