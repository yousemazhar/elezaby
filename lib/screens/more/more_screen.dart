import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/global_app_bar.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accountItems = <_AccountItem>[
      _AccountItem('👤', 'Profile', () => context.push('/profile')),
      _AccountItem('🛍️', 'My Orders', () => context.push('/orders')),
      const _AccountItem('📖', 'Online Magazine', null),
      _AccountItem('📍', 'Addresses', () => context.push('/addresses')),
    ];

    const aboutItems = <_AboutItem>[
      _AboutItem('🔗', 'Share The App'),
      _AboutItem('⭐', 'Rate On The App Store'),
      _AboutItem('❓', 'Help and Support'),
      _AboutItem('📄', 'Terms and Conditions'),
      _AboutItem('❔', 'FAQs'),
      _AboutItem('📍', 'Branches'),
      _AboutItem('🛡️', 'Privacy Policy'),
      _AboutItem('ⓘ', 'About Us'),
    ];

    return Scaffold(
      appBar: const GlobalAppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          const _SectionHeader('Your Account'),
          for (final item in accountItems) _AccountRow(item: item),

          const _SectionHeader('About The App'),
          for (final item in aboutItems) _AboutRow(item: item),
          const SizedBox(height: 20),

        ],
      ),
    );
  }
}

class _AccountItem {
  final String icon;
  final String label;
  final VoidCallback? onTap;
  final String trailing;
  final bool hideIcon;
  const _AccountItem(this.icon, this.label, this.onTap,
      {this.trailing = '▶', this.hideIcon = false});
}

class _AboutItem {
  final String icon;
  final String label;
  const _AboutItem(this.icon, this.label);
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 20),
      color: AppColors.divider,
    );
  }
}

class _AccountRow extends StatelessWidget {
  final _AccountItem item;
  const _AccountRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            if (!item.hideIcon) ...[
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child:
                    Text(item.icon, style: const TextStyle(fontSize: 14)),
              ),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Text(
                item.label,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark),
              ),
            ),
            Text(item.trailing,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  final _AboutItem item;
  const _AboutRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(item.icon, style: const TextStyle(fontSize: 13)),
          ),
          const SizedBox(width: 14),
          Text(
            item.label,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark),
          ),
        ],
      ),
    );
  }
}
