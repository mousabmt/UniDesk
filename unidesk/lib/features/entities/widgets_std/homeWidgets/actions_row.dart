import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/constants.dart';
import '../../../language/langProvider.dart';

class QuickActionItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}


class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LangProvider>(); // ✅
    const spacing = 10.0;

    final actions = [
      QuickActionItem(
        icon: Icons.payment_outlined,
        label: lang.translate('electronic_payment'),
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coming soon')),
        ),
      ),
      QuickActionItem(
        icon: Icons.headset_mic_outlined,
        label: lang.translate('technical_support'),
        onTap: () => context.push('/technical-support'),
      ),
      QuickActionItem(
        icon: Icons.book_outlined,
        label: lang.translate('current_semester'),
        onTap: () => context.push('/current-semester'),
      ),
    ];

    return Row(
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          Expanded(child: _QuickActionCard(item: actions[i])),
          if (i != actions.length - 1) const SizedBox(width: spacing),
        ],
      ],
    );
  }
}
class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.item});

  final QuickActionItem item;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: item.label,
      child: Material(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 90, // ✅ fixed height — consistent across devices
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 8,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8), // ✅ icon background
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.icon,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11, // ✅ slightly smaller to avoid wrapping
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}