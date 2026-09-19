import 'package:flutter/material.dart';

/// Enterprise Hospital HR Theme
/// All colors, gradients, text styles, and design tokens for the MY HR module
class HRTheme {
  HRTheme._();

  // ── Primary Palette ──────────────────────────────────────────────────────
  static const Color primaryDeep = Color(0xFF0D1B4B);
  static const Color primaryDark = Color(0xFF1A237E);
  static const Color primaryMid = Color(0xFF283593);
  static const Color primaryLight = Color(0xFF3949AB);
  static const Color primaryAccent = Color(0xFF5C6BC0);

  // ── Teal/Cyan Accent ─────────────────────────────────────────────────────
  static const Color teal = Color(0xFF00897B);
  static const Color tealLight = Color(0xFF4DB6AC);
  static const Color cyan = Color(0xFF0289A1);
  static const Color cyanLight = Color(0xFF4FC3F7);

  // ── Status Colors ─────────────────────────────────────────────────────────
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFF57F17);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color error = Color(0xFFC62828);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF0277BD);
  static const Color infoLight = Color(0xFFE3F2FD);
  static const Color pending = Color(0xFFE65100);
  static const Color pendingLight = Color(0xFFFFF3E0);

  // ── Neutrals ─────────────────────────────────────────────────────────────
  static const Color white = Colors.white;
  static const Color bgLight = Color(0xFFF0F2F8);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color bgDark = Color(0xFF121212);
  static const Color bgCardDark = Color(0xFF1E1E2E);
  static const Color textPrimary = Color(0xFF0D1B2A);
  static const Color textSecondary = Color(0xFF546E7A);
  static const Color textHint = Color(0xFF90A4AE);
  static const Color divider = Color(0xFFECEFF1);
  static const Color dividerDark = Color(0xFF2D2D44);

  // ── Module Colors ─────────────────────────────────────────────────────────
  static const Color attendance = Color(0xFF1565C0);
  static const Color leave = Color(0xFF2E7D32);
  static const Color payroll = Color(0xFF6A1B9A);
  static const Color shift = Color(0xFF00695C);
  static const Color profile = Color(0xFF283593);
  static const Color documents = Color(0xFF4527A0);
  static const Color performance = Color(0xFFAD1457);
  static const Color training = Color(0xFF00838F);
  static const Color assets = Color(0xFF37474F);
  static const Color loan = Color(0xFFBF360C);
  static const Color expenses = Color(0xFF558B2F);
  static const Color requests = Color(0xFF0277BD);
  static const Color approvals = Color(0xFF6D4C41);
  static const Color notifications = Color(0xFF1A237E);
  static const Color calendar = Color(0xFF004D40);
  static const Color policies = Color(0xFF4E342E);
  static const Color settings = Color(0xFF37474F);

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0D1B4B), Color(0xFF1A237E), Color(0xFF283593)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tealGradient = LinearGradient(
    colors: [Color(0xFF004D40), Color(0xFF00897B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF4A148C), Color(0xFF6A1B9A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient errorGradient = LinearGradient(
    colors: [Color(0xFFB71C1C), Color(0xFFC62828)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFE65100), Color(0xFFEF6C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF006064), Color(0xFF0289A1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Shadows ────────────────────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: primaryDark.withValues(alpha: 0.18),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get subtleShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  // ── Border Radii ──────────────────────────────────────────────────────────
  static const double radiusXS = 4;
  static const double radiusSM = 8;
  static const double radiusMD = 12;
  static const double radiusLG = 16;
  static const double radiusXL = 20;
  static const double radiusXXL = 28;
  static const double radiusFull = 999;

  // ── Spacing ───────────────────────────────────────────────────────────────
  static const double spaceXS = 4;
  static const double spaceSM = 8;
  static const double spaceMD = 12;
  static const double spaceLG = 16;
  static const double spaceXL = 20;
  static const double spaceXXL = 24;
  static const double space32 = 32;

  // ── Icon sizes ────────────────────────────────────────────────────────────
  static const double iconSM = 16;
  static const double iconMD = 20;
  static const double iconLG = 24;
  static const double iconXL = 32;
  static const double iconXXL = 48;

  // ── Module gradient helper ────────────────────────────────────────────────
  static LinearGradient moduleGradient(Color color) => LinearGradient(
    colors: [color.withValues(alpha: 0.85), color],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Status badge types
enum HRStatus {
  approved,
  pending,
  rejected,
  active,
  inactive,
  paid,
  due,
  overdue,
}

extension HRStatusX on HRStatus {
  String get label {
    switch (this) {
      case HRStatus.approved:
        return 'Approved';
      case HRStatus.pending:
        return 'Pending';
      case HRStatus.rejected:
        return 'Rejected';
      case HRStatus.active:
        return 'Active';
      case HRStatus.inactive:
        return 'Inactive';
      case HRStatus.paid:
        return 'Paid';
      case HRStatus.due:
        return 'Due';
      case HRStatus.overdue:
        return 'Overdue';
    }
  }

  Color get color {
    switch (this) {
      case HRStatus.approved:
        return HRTheme.success;
      case HRStatus.pending:
        return HRTheme.pending;
      case HRStatus.rejected:
        return HRTheme.error;
      case HRStatus.active:
        return HRTheme.teal;
      case HRStatus.inactive:
        return HRTheme.textSecondary;
      case HRStatus.paid:
        return HRTheme.success;
      case HRStatus.due:
        return HRTheme.warning;
      case HRStatus.overdue:
        return HRTheme.error;
    }
  }

  Color get bgColor {
    switch (this) {
      case HRStatus.approved:
        return HRTheme.successLight;
      case HRStatus.pending:
        return HRTheme.pendingLight;
      case HRStatus.rejected:
        return HRTheme.errorLight;
      case HRStatus.active:
        return const Color(0xFFE0F2F1);
      case HRStatus.inactive:
        return const Color(0xFFECEFF1);
      case HRStatus.paid:
        return HRTheme.successLight;
      case HRStatus.due:
        return HRTheme.warningLight;
      case HRStatus.overdue:
        return HRTheme.errorLight;
    }
  }

  IconData get icon {
    switch (this) {
      case HRStatus.approved:
        return Icons.check_circle_rounded;
      case HRStatus.pending:
        return Icons.schedule_rounded;
      case HRStatus.rejected:
        return Icons.cancel_rounded;
      case HRStatus.active:
        return Icons.radio_button_checked;
      case HRStatus.inactive:
        return Icons.radio_button_unchecked;
      case HRStatus.paid:
        return Icons.verified_rounded;
      case HRStatus.due:
        return Icons.warning_amber_rounded;
      case HRStatus.overdue:
        return Icons.error_rounded;
    }
  }
}
