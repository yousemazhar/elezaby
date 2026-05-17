import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/app_order.dart';
import '../../providers/auth_provider.dart';
import '../../services/order_service.dart';
import '../../widgets/global_app_bar.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _orderService = OrderService();
  late Future<List<AppOrder>> _future;

  @override
  void initState() {
    super.initState();
    final uid = context.read<AuthProvider>().appUser!.uid;
    _future = _orderService.fetchUserOrders(uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const GlobalAppBar(title: 'My Orders', showBackButton: true),
      body: FutureBuilder<List<AppOrder>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Text('Failed to load orders: ${snap.error}',
                  style: const TextStyle(color: AppColors.textMuted)),
            );
          }
          final orders = snap.data ?? [];
          if (orders.isEmpty) {
            return const _EmptyOrders();
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) => _OrderCard(order: orders[i]),
          );
        },
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    return Center(
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
            child: const Icon(Icons.shopping_bag_outlined,
                size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          const Text('No orders yet',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          const SizedBox(height: 6),
          const Text('Your order history will appear here',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final AppOrder order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.status);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${order.id.length > 8 ? order.id.substring(0, 8).toUpperCase() : order.id.toUpperCase()}',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _capitalize(order.status),
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (order.isPrescription)
            Row(
              children: [
                const Text('📋', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  'Prescription · ${order.prescriptionImages.length} image${order.prescriptionImages.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            )
          else
            Text(
              '${order.items.length} item${order.items.length == 1 ? '' : 's'}',
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          if (order.address.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              order.address,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (order.isPrescription && order.notes.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              order.notes,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDate(order.createdAt),
                style:
                    const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              if (!order.isPrescription)
                Text(
                  'EGP ${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary),
                ),
            ],
          ),
          if (order.rewardPointsEarned > 0) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.stars_rounded,
                    size: 14, color: AppColors.green),
                const SizedBox(width: 4),
                Text(
                  '+${order.rewardPointsEarned} points earned',
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.green,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppColors.green;
      case 'pending':
        return const Color(0xFFFF9500);
      case 'cancelled':
        return AppColors.red;
      default:
        return AppColors.textMuted;
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}
