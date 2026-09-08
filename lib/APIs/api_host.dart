// =============================================================
//  api_host.dart — Central Server Configuration
//  Staff Mate App
// =============================================================
//
//  HOW TO SWITCH YOUR SERVER (for each developer):
//  ─────────────────────────────────────────────────
//  1. Find your server IP in the HOSTS map below
//  2. Change CURRENT_KEY to your server's key name
//  3. Change CURRENT_KEY_HR to your HR server's key name
//
//  Example:
//    static const String CURRENT_KEY    = 'LOCAL_DEV_1';
//    static const String CURRENT_KEY_HR = 'HRMS';
//
//  To add a new server, add a new entry in HOSTS map:
//    'MY_SERVER': '192.168.x.x',
//
//  DO NOT hardcode IPs directly in API call files.
//  Always use ApiEndpoints or ApiHost methods.
// =============================================================

class ApiHost {
  // ─────────────────────────────────────────────────────────
  //  SERVER REGISTRY
  //  Add your server IP here with a unique key name.
  //  Keys are used in CURRENT_KEY to select active server.
  // ─────────────────────────────────────────────────────────
  static const Map<String, String> HOSTS = {
    // ── Production / Staging Servers ──
    'TEST_SERVER':   '103.159.239.203',
    'SM_222':        '103.159.239.222',
    'SM_139':        '139.162.51.34',
    'BTGH':          '103.188.18.211',
    'RKH':           '103.215.164.99',
    'RKH_NEW':       '203.194.107.6',
    'NEW_SERVER':    '94.136.188.27',
    'ABDM_222':      'saas.smartcarehis.com',

    // ── HR Server ──
    'HRMS':          '103.177.84.241',

    // ── Client / On-premise Servers ──
    'Aureus':        '172.16.0.10',
    'Aureus_Static': '117.236.139.98',
    'RKH_LOCAL':     '10.0.16.2',
    'LMH_LIVE':      '172.24.1.10',
    'LMH_Static':    '49.248.253.211',
    'New_Life':      '192.168.29.49',

    // ── Local Development (add your own IP here) ──
    //  Run `ipconfig` (Windows) or `ifconfig` (Mac/Linux) to find your IP.
    'SECURITY_TEST': '192.168.1.13',
    'sclyte_local':  '192.168.1.194',
    'LOCAL_DEV_1':   '192.168.0.121',
    'LOCAL_DEV_2':   '192.168.0.175',
    'LOCAL_DEV_3':   '192.168.0.154',
    'LOCAL_DEV_4':   '192.168.0.194',
    'LOCAL_DEV_5':   '192.168.0.179',
    'LOCAL_DEV_6':   '192.168.1.3',
    'LOCAL_DEV_7':   '192.168.0.137',
    'LOCAL_DEV_8':   '192.168.1.38',
    'LOCAL_DEV_9':   '192.168.1.14',
    'LOCAL_DEV_10':   '192.168.1.19',
  };

  // ─────────────────────────────────────────────────────────
  //  ⚙️  ACTIVE SERVER — CHANGE THIS TO SWITCH ENVIRONMENT
  // ─────────────────────────────────────────────────────────
  //
  //  Main app server key  → change to your server key
  static const String CURRENT_KEY    = 'SM_222';
  //
  //  HR module server key → change to your HR server key
  static const String CURRENT_KEY_HR = 'HRMS';
  //
  // ─────────────────────────────────────────────────────────

  // ── Protocol & Ports ──
  static const String PROTOCOL        = 'http';
  static const int    SAM_PORT        = 9091;
  static const int    APP_PORT        = 8443;
  static const int    LOGIN_PORT      = 443;
  static const int    SMART_CARE_PORT = 80;

  // ─────────────────────────────────────────────────────────
  //  Computed Hosts (do not edit)
  // ─────────────────────────────────────────────────────────
  static String get activeHost   => HOSTS[CURRENT_KEY]    ?? HOSTS['SECURITY_TEST']!;
  static String get activeHostHr => HOSTS[CURRENT_KEY_HR] ?? HOSTS['HRMS']!;
  static String get remoteAddr   => activeHost;

  // ─────────────────────────────────────────────────────────
  //  Base URLs (do not edit — derived from activeHost above)
  // ─────────────────────────────────────────────────────────
  static String get appBaseUrl           => '$PROTOCOL://$activeHost:$SMART_CARE_PORT';
  static String get loginBaseUrl         => '$PROTOCOL://$activeHost:$LOGIN_PORT';
  static String get smartcareMainBaseUrl => '$appBaseUrl/smartcaremain';
  static String get ipdBaseUrl           => '$appBaseUrl/ipd';
  static String get securityBaseUrl      => '$appBaseUrl/security';
  static String get billingBaseUrl       => '$appBaseUrl/billing';
  static String get masterBaseUrl        => '$appBaseUrl/master';
  static String get sclyteBaseUrl        => '$appBaseUrl/sclyte';
  static String get samBaseUrl           => '$PROTOCOL://$activeHost:$SAM_PORT';
  static String get smartcarePortalUrl   => '$PROTOCOL://$activeHost:$SMART_CARE_PORT/SMARTCARE';
  static String get hrBaseUrl            => '$PROTOCOL://$activeHostHr:9099';

  // Backward-compatible aliases
  static String get baseUrl    => '$smartcareMainBaseUrl/';
  static String get billingUrl => '$billingBaseUrl/';
  static String get masterUrl  => '$masterBaseUrl/';

  // ─────────────────────────────────────────────────────────
  //  Utility
  // ─────────────────────────────────────────────────────────

  /// Build a full URL from a base and a relative path.
  static String buildUrl(String base, String path) {
    final cleanBase = base.replaceAll(RegExp(r'/+$'), '');
    final cleanPath = path.replaceAll(RegExp(r'^/+'), '');
    return '$cleanBase/$cleanPath';
  }

  /// Print current config to debug console (call from main() if needed).
  static void printConfig() {
    // ignore: avoid_print
    print('''
════════════════════════════════════
    🌐  API HOST CONFIGURATION
════════════════════════════════════
  Current Key  : $CURRENT_KEY
  Active Host  : $activeHost
  HR Key       : $CURRENT_KEY_HR
  HR Host      : $activeHostHr
  Protocol     : $PROTOCOL
────────────────────────────────────
  App Base     : $appBaseUrl
  Security     : $securityBaseUrl
  Login URL    : $loginBaseUrl
  SmartCare    : $smartcareMainBaseUrl
  IPD          : $ipdBaseUrl
  Billing      : $billingBaseUrl
  Master       : $masterBaseUrl
  Sclyte       : $sclyteBaseUrl
  HR           : $hrBaseUrl
  Portal       : $smartcarePortalUrl
════════════════════════════════════
⚠️  Chrome Web: use "Flutter Web (Disable CORS)"
    launch config to avoid CORS errors.
════════════════════════════════════
    ''');
  }
}
