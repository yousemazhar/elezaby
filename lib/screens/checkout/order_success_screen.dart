import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/app_order.dart';
import '../../widgets/app_button.dart';

class OrderSuccessScreen extends StatelessWidget {
  final AppOrder order;

  const OrderSuccessScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
          child: Column(
            children: [
              // Success circle
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient135,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x4D0087C8),
                      blurRadius: 32,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('✓', style: TextStyle(fontSize: 44, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Order Confirmed! 🎉',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Your order is on its way.\nThank you for shopping with elezaby!',
                style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // First order reward card
              if (order.isFirstOrder) ...[
                const _FirstOrderRewardCard(points: AppConstants.firstOrderRewardPoints),
                const SizedBox(height: 16),
              ],

              // Regular reward points card
              if (order.rewardPointsEarned > 0) ...[
                Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.rewardCardGradient,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0x260087C8)),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 32)),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Points Earned',
                            style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textMuted),
                          ),
                          Text(
                            '+${order.rewardPointsEarned} pts',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Order summary
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _OrderRow('Order ID',
                        '#${order.id.substring(0, 8).toUpperCase()}'),
                    const Divider(color: AppColors.divider, height: 16),
                    _OrderRow('Items', '${order.items.length} items'),
                    const SizedBox(height: 6),
                    _OrderRow('Delivery',
                        order.deliveryFee == 0 ? 'FREE' : 'EGP ${order.deliveryFee.toStringAsFixed(0)}'),
                    const SizedBox(height: 6),
                    _OrderRow(
                      'Total',
                      'EGP ${order.total.toStringAsFixed(0)}',
                      bold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              AppButton(
                label: 'Back to Home',
                onPressed: () => context.go('/home'),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'View Profile & Points',
                outlined: true,
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FirstOrderRewardCard extends StatelessWidget {
  final int points;
  const _FirstOrderRewardCard({required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF8E8), Color(0xFFFFF3D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF5C842), width: 1.5),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                    child: Text('🎁', style: TextStyle(fontSize: 22))),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.textDark,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'FIRST ORDER BONUS',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '+$points pts',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFE8920A),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Congratulations! You\'ve earned your first-order welcome bonus. '
            'Keep shopping to unlock more rewards and discounts!',
            style: TextStyle(
                fontSize: 13, color: AppColors.textDark, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _OrderRow(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14, color: AppColors.textMuted)),
        Text(value,
            style: TextStyle(
                fontSize: bold ? 16 : 14,
                fontWeight:
                    bold ? FontWeight.w800 : FontWeight.w600,
                color: AppColors.textDark)),
      ],
    );
  }
}
