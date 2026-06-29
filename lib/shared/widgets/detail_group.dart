import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';
import '../../theme/app_theme.dart';

/// Grouped card with hairline dividers between rows — the Graphite Pro
/// "filas densas" (1Password-like) container. Shared across every screen so the
/// look stays consistent (UX overhaul L0 kit).
class DetailGroup extends StatelessWidget {
  const DetailGroup({super.key, required this.children, this.margin});

  final List<Widget> children;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    if (children.isEmpty) return const SizedBox.shrink();
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      items.add(children[i]);
      if (i != children.length - 1) {
        items.add(Divider(height: 1, thickness: 1, color: p.divider));
      }
    }
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(AppTheme.rCard),
        border: Border.all(color: p.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: items),
    );
  }
}

/// Uppercase muted section label above a [DetailGroup] (e.g. "AVANZADO").
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.text, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text.toUpperCase(),
              style: TextStyle(
                color: p.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Dense, stateless key/value row for plain (non-secret) values. Use inside a
/// [DetailGroup]. For secrets that need reveal/decrypt, screens keep their own
/// stateful row.
class KvRow extends StatelessWidget {
  const KvRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.mono = false,
    this.multiline = false,
    this.valueColor,
    this.trailing,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData? icon;
  final bool mono;
  final bool multiline;
  final Color? valueColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final labelWidget = Text(
      label,
      style: TextStyle(
        color: p.textMuted,
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    final valueStyle = TextStyle(
      color: valueColor ?? p.textPrimary,
      fontSize: 14,
      height: multiline ? 1.45 : 1.2,
      fontFamily: mono ? AppTheme.monoFamily : null,
    );

    final Widget content;
    if (multiline) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: p.textMuted, size: 16),
                const SizedBox(width: 8),
              ],
              Expanded(child: labelWidget),
              ?trailing,
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: valueStyle),
        ],
      );
    } else {
      content = Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: p.textMuted, size: 16),
            const SizedBox(width: 10),
          ],
          SizedBox(width: 84, child: labelWidget),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: valueStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ?trailing,
        ],
      );
    }

    final padded = Padding(
      padding: EdgeInsets.fromLTRB(14, multiline ? 12 : 10, 8, multiline ? 12 : 10),
      child: content,
    );
    if (onTap == null) return padded;
    return InkWell(onTap: onTap, child: padded);
  }
}
