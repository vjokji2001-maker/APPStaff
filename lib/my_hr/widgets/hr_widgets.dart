import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/hr_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HR App Bar / Gradient Header
// ─────────────────────────────────────────────────────────────────────────────
class HRGradientHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showBack;
  final Widget? leading;

  const HRGradientHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.showBack = true,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 16,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        gradient: HRTheme.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(HRTheme.radiusXL),
          bottomRight: Radius.circular(HRTheme.radiusXL),
        ),
      ),
      child: Row(
        children: [
          if (showBack)
            GestureDetector(
              onTap: () => Navigator.maybePop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(HRTheme.radiusSM),
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              ),
            )
          else if (leading != null)
            leading!,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                      color: Colors.white, fontSize: 18,
                      fontWeight: FontWeight.w700, letterSpacing: 0.2,
                    )),
                if (subtitle != null)
                  Text(subtitle!,
                      style: GoogleFonts.poppins(
                        color: Colors.white70, fontSize: 12,
                        fontWeight: FontWeight.w400,
                      )),
              ],
            ),
          ),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status Badge
// ─────────────────────────────────────────────────────────────────────────────
class HRStatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;
  final IconData? icon;
  final double fontSize;

  const HRStatusBadge({
    super.key,
    required this.label,
    required this.color,
    required this.bgColor,
    this.icon,
    this.fontSize = 10,
  });

  factory HRStatusBadge.fromStatus(HRStatus status) => HRStatusBadge(
    label: status.label, color: status.color,
    bgColor: status.bgColor, icon: status.icon,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(HRTheme.radiusFull),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 1, color: color),
            const SizedBox(width: 3),
          ],
          Text(label,
              style: GoogleFonts.poppins(
                fontSize: fontSize, fontWeight: FontWeight.w600, color: color,
              )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info Row (label + value)
// ─────────────────────────────────────────────────────────────────────────────
class HRInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  final bool isLast;

  const HRInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: (iconColor ?? HRTheme.primaryDark).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(HRTheme.radiusXS),
                  ),
                  child: Icon(icon, size: 14, color: iconColor ?? HRTheme.primaryDark),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: GoogleFonts.poppins(
                          fontSize: 11, color: HRTheme.textSecondary,
                          fontWeight: FontWeight.w400,
                        )),
                    const SizedBox(height: 2),
                    Text(value,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: isDark ? Colors.white : HRTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(color: isDark ? HRTheme.dividerDark : HRTheme.divider, height: 1),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HR Card (white card with shadow)
// ─────────────────────────────────────────────────────────────────────────────
class HRCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final Color? color;
  final VoidCallback? onTap;

  const HRCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = color ?? (isDark ? HRTheme.bgCardDark : HRTheme.bgCard);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        padding: padding ?? const EdgeInsets.all(HRTheme.spaceLG),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(borderRadius ?? HRTheme.radiusMD),
          boxShadow: HRTheme.cardShadow,
        ),
        child: child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Header inside a page
// ─────────────────────────────────────────────────────────────────────────────
class HRSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;

  const HRSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 10),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: HRTheme.primaryDark),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Text(title,
                style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: HRTheme.primaryDark,
                )),
          ),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Text(actionLabel!,
                  style: GoogleFonts.poppins(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: HRTheme.cyan,
                  )),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Progress Bar
// ─────────────────────────────────────────────────────────────────────────────
class HRProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  final double height;
  final String? label;

  const HRProgressBar({
    super.key,
    required this.value,
    required this.color,
    this.height = 6,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!,
              style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textSecondary)),
          const SizedBox(height: 4),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(HRTheme.radiusFull),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            backgroundColor: color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: height,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Skeleton Loading Widget
// ─────────────────────────────────────────────────────────────────────────────
class HRSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const HRSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.radius = 6,
  });

  @override
  State<HRSkeleton> createState() => _HRSkeletonState();
}

class _HRSkeletonState extends State<HRSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width, height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(_anim.value),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty State Widget
// ─────────────────────────────────────────────────────────────────────────────
class HREmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const HREmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: HRTheme.primaryDark.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: HRTheme.primaryDark.withOpacity(0.5)),
            ),
            const SizedBox(height: 16),
            Text(title, textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w600,
                  color: HRTheme.textPrimary,
                )),
            const SizedBox(height: 6),
            Text(subtitle, textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 13, color: HRTheme.textSecondary)),
            if (actionLabel != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: HRTheme.primaryDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(HRTheme.radiusSM)),
                ),
                child: Text(actionLabel!, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HR Tab Bar
// ─────────────────────────────────────────────────────────────────────────────
class HRTabBar extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final Color? activeColor;

  const HRTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final active = activeColor ?? HRTheme.primaryDark;
    return Container(
      height: 44,
      color: isDark ? HRTheme.bgCardDark : Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: tabs.length,
        itemBuilder: (_, i) {
          final sel = i == selectedIndex;
          return GestureDetector(
            onTap: () => onTabChanged(i),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: sel ? active : Colors.transparent,
                borderRadius: BorderRadius.circular(HRTheme.radiusFull),
                border: sel ? null : Border.all(color: Colors.grey.shade300),
              ),
              child: Text(tabs[i],
                  style: GoogleFonts.poppins(
                    fontSize: 12, fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                    color: sel ? Colors.white : HRTheme.textSecondary,
                  )),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gradient Stat Card (for dashboard summary cards)
// ─────────────────────────────────────────────────────────────────────────────
class HRStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Gradient gradient;
  final String? subtitle;
  final VoidCallback? onTap;

  const HRStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(HRTheme.radiusMD),
          boxShadow: HRTheme.elevatedShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(HRTheme.radiusSM),
                  ),
                  child: Icon(icon, color: Colors.white, size: 18),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 12),
              ],
            ),
            const SizedBox(height: 8),
            Text(value,
                style: GoogleFonts.poppins(
                  fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white,
                )),
            const SizedBox(height: 1),
            Text(title,
                style: GoogleFonts.poppins(
                  fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white70,
                )),
            if (subtitle != null)
              Text(subtitle!,
                  style: GoogleFonts.poppins(
                    fontSize: 9, color: Colors.white54,
                  )),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Module Grid Tile (for HR Dashboard grid)
// ─────────────────────────────────────────────────────────────────────────────
class HRModuleTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int? badgeCount;

  const HRModuleTile({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? HRTheme.bgCardDark : Colors.white,
          borderRadius: BorderRadius.circular(HRTheme.radiusMD),
          boxShadow: HRTheme.cardShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 26),
                ),
                if (badgeCount != null && badgeCount! > 0)
                  Positioned(
                    top: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text('$badgeCount',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(label,
                  textAlign: TextAlign.center,
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11, fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : HRTheme.textPrimary,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Simple Bar Chart (no external package)
// ─────────────────────────────────────────────────────────────────────────────
class HRBarChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final Color barColor;
  final double maxValue;
  final double barWidth;

  const HRBarChart({
    super.key,
    required this.values,
    required this.labels,
    required this.barColor,
    required this.maxValue,
    this.barWidth = 28,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(values.length, (i) {
          final pct = maxValue > 0 ? (values[i] / maxValue).clamp(0.0, 1.0) : 0.0;
          final isHighlighted = values[i] == values.reduce((a, b) => a > b ? a : b);
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('${values[i].toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(fontSize: 9, color: HRTheme.textSecondary)),
              const SizedBox(height: 2),
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutBack,
                width: barWidth,
                height: (90 * pct).clamp(4.0, 90.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isHighlighted
                        ? [barColor, barColor.withOpacity(0.7)]
                        : [barColor.withOpacity(0.6), barColor.withOpacity(0.3)],
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ),
              const SizedBox(height: 4),
              Text(labels[i],
                  style: GoogleFonts.poppins(
                    fontSize: 9, fontWeight: FontWeight.w500,
                    color: isHighlighted ? barColor : HRTheme.textSecondary,
                  )),
            ],
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Circular Progress Indicator (custom styled)
// ─────────────────────────────────────────────────────────────────────────────
class HRCircularProgress extends StatelessWidget {
  final double value;
  final String label;
  final String centerText;
  final Color color;
  final double size;

  const HRCircularProgress({
    super.key,
    required this.value,
    required this.label,
    required this.centerText,
    required this.color,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: size, height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: size, height: size,
                child: CircularProgressIndicator(
                  value: value.clamp(0.0, 1.0),
                  strokeWidth: 7,
                  backgroundColor: color.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text(centerText,
                  style: GoogleFonts.poppins(
                    fontSize: 14, fontWeight: FontWeight.w800, color: color,
                  )),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textSecondary)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Timeline Item
// ─────────────────────────────────────────────────────────────────────────────
class HRTimelineItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final Color color;
  final IconData icon;
  final bool isLast;

  const HRTimelineItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
    required this.icon,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(icon, size: 18, color: color),
            ),
            if (!isLast)
              Container(width: 2, height: 40, color: color.withOpacity(0.2)),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(title,
                    style: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : HRTheme.textPrimary,
                    )),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: GoogleFonts.poppins(fontSize: 12, color: HRTheme.textSecondary)),
                const SizedBox(height: 3),
                Text(time,
                    style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textHint)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search Bar
// ─────────────────────────────────────────────────────────────────────────────
class HRSearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const HRSearchBar({super.key, required this.hint, this.onChanged, this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: isDark ? HRTheme.bgCardDark : Colors.white,
        borderRadius: BorderRadius.circular(HRTheme.radiusSM),
        boxShadow: HRTheme.subtleShadow,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: GoogleFonts.poppins(fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(fontSize: 13, color: HRTheme.textHint),
          prefixIcon: const Icon(Icons.search, size: 20, color: HRTheme.textHint),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Announcement Card
// ─────────────────────────────────────────────────────────────────────────────
class HRAnnounceCard extends StatelessWidget {
  final String title;
  final String content;
  final String date;
  final String priority;

  const HRAnnounceCard({
    super.key,
    required this.title,
    required this.content,
    required this.date,
    required this.priority,
  });

  Color get _priorityColor {
    switch (priority.toLowerCase()) {
      case 'high': return HRTheme.error;
      case 'medium': return HRTheme.warning;
      default: return HRTheme.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? HRTheme.bgCardDark : Colors.white,
        borderRadius: BorderRadius.circular(HRTheme.radiusMD),
        border: Border.all(color: _priorityColor.withOpacity(0.3)),
        boxShadow: HRTheme.subtleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: _priorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(HRTheme.radiusFull),
                ),
                child: Text(priority,
                    style: GoogleFonts.poppins(
                      fontSize: 10, fontWeight: FontWeight.w600, color: _priorityColor,
                    )),
              ),
              const Spacer(),
              Text(date,
                  style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textHint)),
            ],
          ),
          const SizedBox(height: 8),
          Text(title,
              style: GoogleFonts.poppins(
                fontSize: 13, fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : HRTheme.textPrimary,
              )),
          const SizedBox(height: 4),
          Text(content, maxLines: 2, overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(fontSize: 12, color: HRTheme.textSecondary)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Primary Action Button
// ─────────────────────────────────────────────────────────────────────────────
class HRPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final bool isLoading;

  const HRPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? HRTheme.primaryDark,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(HRTheme.radiusSM)),
        ),
        child: isLoading
            ? const SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : icon != null
                ? Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                    Text(label,
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                  ])
                : Text(label,
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Divider with label
// ─────────────────────────────────────────────────────────────────────────────
class HRDividerLabel extends StatelessWidget {
  final String label;
  const HRDividerLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Expanded(child: Divider()),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(label,
            style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textHint)),
      ),
      const Expanded(child: Divider()),
    ]);
  }
}
