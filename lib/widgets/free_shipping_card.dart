import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';

class FreeShippingCard extends StatelessWidget {
  final double subtotal;

  const FreeShippingCard({super.key, required this.subtotal});

  @override
  Widget build(BuildContext context) {
    final progress =
        (subtotal / AppConstants.freeShippingThreshold).clamp(0.0, 1.0);
    final remaining = AppConstants.freeShippingThreshold - subtotal;
    final achieved = subtotal >= AppConstants.freeShippingThreshold;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/icons/delivery.png',
                    width: 22,
                    height: 22,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achieved
                          ? 'You\'ve unlocked free delivery! 🎉'
                          : 'Add EGP ${remaining.toStringAsFixed(0)} for free delivery',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const Text(
                      'Free shipping on orders over EGP 500',
                      style:
                          TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0x260087C8),
              valueColor: AlwaysStoppedAnimation<Color>(
                achieved ? AppColors.green : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
