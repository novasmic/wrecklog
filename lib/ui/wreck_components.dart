import 'package:flutter/material.dart';
import 'wreck_theme.dart';

enum WreckStatus { inStock, sold, notListed, scrap, listed }

class WreckStatusStyle {
  final Color bg;
  final Color fg;
  final String label;

  const WreckStatusStyle(this.bg, this.fg, this.label);

  static WreckStatusStyle of(WreckStatus status) {
    switch (status) {
      case WreckStatus.inStock:
        return const WreckStatusStyle(WreckTheme.ok, Colors.black, 'IN STOCK');
      case WreckStatus.sold:
        return const WreckStatusStyle(WreckTheme.info, Colors.black, 'SOLD');
      case WreckStatus.notListed:
        return const WreckStatusStyle(WreckTheme.warn, Colors.black, 'NOT LISTED');
      case WreckStatus.scrap:
        return const WreckStatusStyle(WreckTheme.bad, Colors.white, 'SCRAP');
      case WreckStatus.listed:
        return const WreckStatusStyle(WreckTheme.accent, Colors.black, 'LISTED');
    }
  }
}

/// Small label/value row used inside cards.
class WreckMetaRow extends StatelessWidget {
  final String leftLabel;
  final String leftValue;
  final String? rightLabel;
  final String? rightValue;

  const WreckMetaRow({
    super.key,
    required this.leftLabel,
    required this.leftValue,
    this.rightLabel,
    this.rightValue,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      children: [
        Text(leftLabel, style: t.bodySmall),
        const SizedBox(width: 6),
        Text(leftValue, style: t.bodyMedium?.copyWith(color: WreckTheme.text0, fontWeight: FontWeight.w600)),
        const Spacer(),
        if (rightLabel != null && rightValue != null) ...[
          Text(rightLabel!, style: t.bodySmall),
          const SizedBox(width: 6),
          Text(rightValue!, style: t.bodyMedium?.copyWith(color: WreckTheme.text0, fontWeight: FontWeight.w600)),
        ],
      ],
    );
  }
}

/// Status badge (ONLY place we use strong color).
class WreckStatusBadge extends StatelessWidget {
  final WreckStatus status;

  const WreckStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final s = WreckStatusStyle.of(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: s.bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        s.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: s.fg,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
      ),
    );
  }
}

/// A compact action chip that looks "clickable" (distinct from badges).
class WreckActionChip extends StatelessWidget {
  final IconData? icon;
  final String label;
  final VoidCallback? onTap;

  const WreckActionChip({
    super.key,
    this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(WreckTheme.r12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: WreckTheme.surface,
          borderRadius: BorderRadius.circular(WreckTheme.r12),
          border: Border.all(color: WreckTheme.border, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: WreckTheme.text1),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: WreckTheme.text0,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Primary button (accent).
class WreckPrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  const WreckPrimaryButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon ?? Icons.add, size: 18),
      label: Text(label),
    );
  }
}

/// Secondary button (neutral).
class WreckGhostButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  const WreckGhostButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon ?? Icons.tune, size: 18),
      label: Text(label),
    );
  }
}

/// A dense, scannable "part row card" (table-like).
class WreckPartCard extends StatelessWidget {
  final String title;
  final int qty;
  final double askPrice;
  final WreckStatus status;
  final String acquiredDate; // e.g. "Feb 10, 2026"
  final VoidCallback? onMarkSold;
  final VoidCallback? onScrap;
  final VoidCallback? onEdit;

  const WreckPartCard({
    super.key,
    required this.title,
    required this.qty,
    required this.askPrice,
    required this.status,
    required this.acquiredDate,
    this.onMarkSold,
    this.onScrap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(WreckTheme.s12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _money(askPrice),
                  style: t.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: WreckTheme.text0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                WreckStatusBadge(status: status),
                const SizedBox(width: 10),
                Text('Qty $qty', style: t.bodySmall),
                const Spacer(),
                Text(
                  acquiredDate,
                  style: t.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: WreckActionChip(
                    icon: Icons.check_circle_outline,
                    label: 'Mark Sold',
                    onTap: onMarkSold,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: WreckActionChip(
                    icon: Icons.delete_outline,
                    label: 'Scrap',
                    onTap: onScrap,
                  ),
                ),
                const SizedBox(width: 10),
                WreckActionChip(
                  icon: Icons.edit,
                  label: 'Edit',
                  onTap: onEdit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _money(double v) {
    // simple formatting without intl
    final s = v.toStringAsFixed(0);
    return '\$$s';
  }
}