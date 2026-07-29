import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// ENTERPRISE DESIGN SYSTEM – Design Tokens
/// Inspired by Google Workspace · Microsoft 365 · Workday · Darwinbox · Keka
/// ─────────────────────────────────────────────────────────────────────────────
library ds_tokens;

// ═══════════════════════════════════════════════════════════════════════════════
// COLOR PALETTE
// ═══════════════════════════════════════════════════════════════════════════════
class DSColors {
  DSColors._();

  // ── Brand Primary (Deep Indigo) ──────────────────────────────────────────
  static const Color primary50  = Color(0xFFE8EAF6);
  static const Color primary100 = Color(0xFFC5CAE9);
  static const Color primary200 = Color(0xFF9FA8DA);
  static const Color primary300 = Color(0xFF7986CB);
  static const Color primary400 = Color(0xFF5C6BC0);
  static const Color primary500 = Color(0xFF3F51B5); // base
  static const Color primary600 = Color(0xFF283593); // header/appbar
  static const Color primary700 = Color(0xFF1A237E); // dark brand
  static const Color primary800 = Color(0xFF0D1B4B); // deepest
  static const Color primary900 = Color(0xFF080D2E);

  // ── Teal Accent (secondary) ───────────────────────────────────────────────
  static const Color teal50  = Color(0xFFE0F2F1);
  static const Color teal100 = Color(0xFFB2DFDB);
  static const Color teal200 = Color(0xFF80CBC4);
  static const Color teal300 = Color(0xFF4DB6AC);
  static const Color teal400 = Color(0xFF26A69A);
  static const Color teal500 = Color(0xFF009688); // base
  static const Color teal600 = Color(0xFF00897B);
  static const Color teal700 = Color(0xFF00796B);
  static const Color teal800 = Color(0xFF00695C);
  static const Color teal900 = Color(0xFF004D40);

  // ── Status: Success ───────────────────────────────────────────────────────
  static const Color green50  = Color(0xFFE8F5E9);
  static const Color green100 = Color(0xFFC8E6C9);
  static const Color green500 = Color(0xFF4CAF50);
  static const Color green600 = Color(0xFF2E7D32);
  static const Color green700 = Color(0xFF1B5E20);

  // ── Status: Warning ───────────────────────────────────────────────────────
  static const Color amber50  = Color(0xFFFFF8E1);
  static const Color amber100 = Color(0xFFFFECB3);
  static const Color amber500 = Color(0xFFFFC107);
  static const Color amber600 = Color(0xFFFFB300);
  static const Color amber700 = Color(0xFFF57F17);
  static const Color amber800 = Color(0xFFE65100);

  // ── Status: Danger ────────────────────────────────────────────────────────
  static const Color red50   = Color(0xFFFFEBEE);
  static const Color red100  = Color(0xFFFFCDD2);
  static const Color red500  = Color(0xFFF44336);
  static const Color red600  = Color(0xFFE53935);
  static const Color red700  = Color(0xFFC62828);
  static const Color red800  = Color(0xFFB71C1C);

  // ── Status: Info ─────────────────────────────────────────────────────────
  static const Color blue50   = Color(0xFFE3F2FD);
  static const Color blue100  = Color(0xFFBBDEFB);
  static const Color blue500  = Color(0xFF2196F3);
  static const Color blue600  = Color(0xFF1E88E5);
  static const Color blue700  = Color(0xFF0277BD);
  static const Color blue800  = Color(0xFF01579B);

  // ── Purple ────────────────────────────────────────────────────────────────
  static const Color purple50  = Color(0xFFF3E5F5);
  static const Color purple100 = Color(0xFFE1BEE7);
  static const Color purple500 = Color(0xFF9C27B0);
  static const Color purple600 = Color(0xFF8E24AA);
  static const Color purple700 = Color(0xFF6A1B9A);
  static const Color purple800 = Color(0xFF4A148C);

  // ── Orange ───────────────────────────────────────────────────────────────
  static const Color orange50  = Color(0xFFFFF3E0);
  static const Color orange500 = Color(0xFFFF9800);
  static const Color orange600 = Color(0xFFFB8C00);
  static const Color orange700 = Color(0xFFEF6C00);
  static const Color orange800 = Color(0xFFE65100);

  // ── Neutrals (Light theme) ────────────────────────────────────────────────
  static const Color white       = Color(0xFFFFFFFF);
  static const Color grey50      = Color(0xFFFAFAFA);
  static const Color grey100     = Color(0xFFF5F5F5);
  static const Color grey150     = Color(0xFFF0F2F8); // bg
  static const Color grey200     = Color(0xFFEEEEEE);
  static const Color grey300     = Color(0xFFE0E0E0);
  static const Color grey400     = Color(0xFFBDBDBD);
  static const Color grey500     = Color(0xFF9E9E9E);
  static const Color grey600     = Color(0xFF757575);
  static const Color grey700     = Color(0xFF616161);
  static const Color grey800     = Color(0xFF424242);
  static const Color grey900     = Color(0xFF212121);

  // ── Dark theme surfaces ───────────────────────────────────────────────────
  static const Color dark900     = Color(0xFF0A0D1A);
  static const Color dark800     = Color(0xFF111322);
  static const Color dark750     = Color(0xFF141829);
  static const Color dark700     = Color(0xFF1A1F35);
  static const Color dark600     = Color(0xFF222840);
  static const Color dark500     = Color(0xFF2C3354);
  static const Color darkCard    = Color(0xFF1C2138);
  static const Color darkSurface = Color(0xFF161B30);

  // ── Semantic tokens ───────────────────────────────────────────────────────
  // Light mode
  static const Color bgLight      = grey150;
  static const Color surfaceLight = white;
  static const Color cardLight    = white;
  static const Color dividerLight = grey200;
  static const Color textPrimL    = grey900;
  static const Color textSecL     = grey600;
  static const Color textHintL    = grey400;
  static const Color disabledL    = grey300;

  // Dark mode
  static const Color bgDark       = dark900;
  static const Color surfaceDark  = dark800;
  static const Color cardDark     = darkCard;
  static const Color dividerDark  = dark600;
  static const Color textPrimD    = Color(0xFFECEFF8);
  static const Color textSecD     = Color(0xFF8892B0);
  static const Color textHintD    = Color(0xFF4A5568);
  static const Color disabledD    = dark500;

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGrad = LinearGradient(
    colors: [primary800, primary600, primary500],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient tealGrad = LinearGradient(
    colors: [teal900, teal700, teal500],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient successGrad = LinearGradient(
    colors: [green700, green600, green500],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient dangerGrad = LinearGradient(
    colors: [red800, red700, red600],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient warningGrad = LinearGradient(
    colors: [amber800, amber700, amber600],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient infoGrad = LinearGradient(
    colors: [blue800, blue700, blue600],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient purpleGrad = LinearGradient(
    colors: [purple800, purple700, purple600],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient darkGlassGrad = LinearGradient(
    colors: [Color(0xFF1A1F35), Color(0xFF222840)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );

  // ── Module accent colors ──────────────────────────────────────────────────
  static const Color mAttendance  = Color(0xFF1565C0);
  static const Color mLeave       = Color(0xFF2E7D32);
  static const Color mPayroll     = Color(0xFF6A1B9A);
  static const Color mShift       = Color(0xFF00695C);
  static const Color mProfile     = Color(0xFF283593);
  static const Color mDocuments   = Color(0xFF4527A0);
  static const Color mPerformance = Color(0xFFAD1457);
  static const Color mTraining    = Color(0xFF006064);
  static const Color mAssets      = Color(0xFF37474F);
  static const Color mLoan        = Color(0xFFBF360C);
  static const Color mExpenses    = Color(0xFF33691E);
  static const Color mRequests    = Color(0xFF0277BD);
  static const Color mApprovals   = Color(0xFF4E342E);
  static const Color mCalendar    = Color(0xFF004D40);
  static const Color mPolicies    = Color(0xFF3E2723);
  static const Color mSettings    = Color(0xFF263238);
}

// ═══════════════════════════════════════════════════════════════════════════════
// TYPOGRAPHY SYSTEM
// ═══════════════════════════════════════════════════════════════════════════════
class DSTypography {
  DSTypography._();

  // Font families
  static const String fontPrimary   = 'Poppins';   // headings & UI labels
  static const String fontSecondary = 'Inter';      // body text (fallback: Poppins)

  // ── Scale ─────────────────────────────────────────────────────────────────
  static const double fsXXL  = 32; // Heading XL
  static const double fsXL   = 26; // Heading L
  static const double fsLG   = 22; // Heading M
  static const double fsMD   = 18; // Heading S
  static const double fsSM   = 16; // Title
  static const double fsBase = 14; // Body Large / Subtitle
  static const double fsBody = 13; // Body Medium
  static const double fsSub  = 12; // Body Small
  static const double fsXS   = 11; // Caption
  static const double fsXXS  = 10; // Label tiny
  static const double fsMicro = 9;  // Badge / tag

  // ── Weight ────────────────────────────────────────────────────────────────
  static const FontWeight wBlack      = FontWeight.w900;
  static const FontWeight wExtraBold  = FontWeight.w800;
  static const FontWeight wBold       = FontWeight.w700;
  static const FontWeight wSemiBold   = FontWeight.w600;
  static const FontWeight wMedium     = FontWeight.w500;
  static const FontWeight wRegular    = FontWeight.w400;
  static const FontWeight wLight      = FontWeight.w300;

  // ── Letter spacing ────────────────────────────────────────────────────────
  static const double lsTight    = -0.5;
  static const double lsNormal   =  0.0;
  static const double lsWide     =  0.5;
  static const double lsWidest   =  1.2;

  // ── Line heights ──────────────────────────────────────────────────────────
  static const double lhTight    = 1.2;
  static const double lhNormal   = 1.4;
  static const double lhRelaxed  = 1.6;
}

// ═══════════════════════════════════════════════════════════════════════════════
// SPACING SYSTEM  (4px & 8px grid)
// ═══════════════════════════════════════════════════════════════════════════════
class DSSpacing {
  DSSpacing._();

  static const double px1  = 1;
  static const double px2  = 2;
  static const double px4  = 4;
  static const double px6  = 6;
  static const double px8  = 8;
  static const double px10 = 10;
  static const double px12 = 12;
  static const double px14 = 14;
  static const double px16 = 16;
  static const double px20 = 20;
  static const double px24 = 24;
  static const double px28 = 28;
  static const double px32 = 32;
  static const double px40 = 40;
  static const double px48 = 48;
  static const double px56 = 56;
  static const double px64 = 64;
  static const double px80 = 80;

  // Semantic aliases
  static const double none   = 0;
  static const double xs     = px4;
  static const double sm     = px8;
  static const double md     = px12;
  static const double base   = px16;
  static const double lg     = px20;
  static const double xl     = px24;
  static const double xxl    = px32;
  static const double xxxl   = px48;

  // Page margins
  static const double pageH  = px16;  // horizontal
  static const double pageV  = px16;  // vertical
  static const double pageHT = px20;  // tablet horizontal
}

// ═══════════════════════════════════════════════════════════════════════════════
// BORDER RADIUS SYSTEM
// ═══════════════════════════════════════════════════════════════════════════════
class DSRadius {
  DSRadius._();

  static const double none    = 0;
  static const double xs      = 4;
  static const double sm      = 8;
  static const double md      = 12;
  static const double lg      = 16;
  static const double xl      = 20;
  static const double xxl     = 24;
  static const double xxxl    = 32;
  static const double full    = 999;

  static BorderRadius get cardRadius   => BorderRadius.circular(md);
  static BorderRadius get buttonRadius => BorderRadius.circular(sm);
  static BorderRadius get chipRadius   => BorderRadius.circular(full);
  static BorderRadius get inputRadius  => BorderRadius.circular(sm);
  static BorderRadius get sheetTop     => const BorderRadius.vertical(top: Radius.circular(xxl));
  static BorderRadius get dialogRadius => BorderRadius.circular(xl);
}

// ═══════════════════════════════════════════════════════════════════════════════
// SHADOW SYSTEM
// ═══════════════════════════════════════════════════════════════════════════════
class DSShadows {
  DSShadows._();

  static List<BoxShadow> get none => [];

  static List<BoxShadow> get xs => [
    BoxShadow(color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 4, offset: const Offset(0, 1)),
  ];

  static List<BoxShadow> get sm => [
    BoxShadow(color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 8, offset: const Offset(0, 2)),
    BoxShadow(color: Colors.black.withValues(alpha: 0.02),
        blurRadius: 2, offset: const Offset(0, 1)),
  ];

  static List<BoxShadow> get md => [
    BoxShadow(color: Colors.black.withValues(alpha: 0.08),
        blurRadius: 16, offset: const Offset(0, 4)),
    BoxShadow(color: Colors.black.withValues(alpha: 0.03),
        blurRadius: 4, offset: const Offset(0, 1)),
  ];

  static List<BoxShadow> get lg => [
    BoxShadow(color: Colors.black.withValues(alpha: 0.12),
        blurRadius: 24, offset: const Offset(0, 8)),
    BoxShadow(color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 6, offset: const Offset(0, 2)),
  ];

  static List<BoxShadow> get xl => [
    BoxShadow(color: Colors.black.withValues(alpha: 0.16),
        blurRadius: 40, offset: const Offset(0, 16)),
    BoxShadow(color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 8, offset: const Offset(0, 4)),
  ];

  static List<BoxShadow> primarySm(Color c) => [
    BoxShadow(color: c.withValues(alpha: 0.25),
        blurRadius: 12, offset: const Offset(0, 4)),
  ];

  static List<BoxShadow> primaryMd(Color c) => [
    BoxShadow(color: c.withValues(alpha: 0.30),
        blurRadius: 20, offset: const Offset(0, 8)),
  ];
}

// ═══════════════════════════════════════════════════════════════════════════════
// ELEVATION / Z-INDEX
// ═══════════════════════════════════════════════════════════════════════════════
class DSElevation {
  DSElevation._();
  static const double none     = 0;
  static const double xs       = 1;
  static const double sm       = 2;
  static const double md       = 4;
  static const double lg       = 8;
  static const double xl       = 16;
  static const double modal    = 24;
}

// ═══════════════════════════════════════════════════════════════════════════════
// ICON SIZES
// ═══════════════════════════════════════════════════════════════════════════════
class DSIcons {
  DSIcons._();
  static const double xs   = 14;
  static const double sm   = 16;
  static const double md   = 20;
  static const double lg   = 24;
  static const double xl   = 28;
  static const double xxl  = 32;
  static const double xxxl = 48;
}

// ═══════════════════════════════════════════════════════════════════════════════
// ANIMATION DURATIONS
// ═══════════════════════════════════════════════════════════════════════════════
class DSDuration {
  DSDuration._();
  static const Duration instant   = Duration(milliseconds: 100);
  static const Duration fast      = Duration(milliseconds: 150);
  static const Duration normal    = Duration(milliseconds: 250);
  static const Duration medium    = Duration(milliseconds: 350);
  static const Duration slow      = Duration(milliseconds: 500);
  static const Duration verySlow  = Duration(milliseconds: 800);
  static const Duration page      = Duration(milliseconds: 300);
}

// ═══════════════════════════════════════════════════════════════════════════════
// ANIMATION CURVES
// ═══════════════════════════════════════════════════════════════════════════════
class DSCurves {
  DSCurves._();
  static const Curve standard    = Curves.easeInOut;
  static const Curve enter       = Curves.easeOut;
  static const Curve exit        = Curves.easeIn;
  static const Curve emphasized  = Curves.easeInOutCubicEmphasized;
  static const Curve spring      = Curves.elasticOut;
  static const Curve bounce      = Curves.bounceOut;
  static const Curve decelerate  = Curves.decelerate;
}
