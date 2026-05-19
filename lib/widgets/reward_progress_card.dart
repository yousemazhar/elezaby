import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';

class RewardProgressCard extends StatelessWidget {
  final int points;

  const RewardProgressCard({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    final progress =
        (points / AppConstants.pointsToNextDiscount).clamp(0.0, 1.0);
    final remaining = AppConstants.pointsToNextDiscount - points;

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.rewardCardGradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x260087C8)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,

                child:Image.asset('assets/icons/star.png', width: 17, height: 17),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reward Points',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textNavy),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '$points pts',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          Text(
            remaining > 0
                ? '$remaining pts until your next discount'
                : 'You\'ve unlocked a discount!',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0x260087C8),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
              Text(
                '200',
                style: TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
