import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/global_app_bar.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const GlobalAppBar(title: 'Notifications', showBackButton: true),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_outlined,
                  size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            const Text(
              'No notifications yet',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark),
            ),
            const SizedBox(height: 6),
            const Text(
              'You\'ll be notified about orders and offers here',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
