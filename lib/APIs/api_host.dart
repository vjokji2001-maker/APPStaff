// --------------------- Host Configuration ---------------------
class ApiHost {
  // Host mappings - exactly like your React HOSTS object
  static const Map<String, String> HOSTS = {
    'TEST_SERVER': '103.159.239.203',
    'SM_222': '103.159.239.222',
    'SM_139': '139.162.51.34',
    'New_Life': '192.168.29.49',
    'Aureus': '172.16.0.10',
    'Aureus_Static': '117.236.139.98',
    'RKH': '103.215.164.99',
    'RKH_LOCAL': '10.0.16.2',
    'RKH_NEW': '203.194.107.6',
    'BTGH': '103.188.18.211',
    'ABDM_222': 'saas.smartcarehis.com',
    'SECURITY_TEST': '192.168.1.13',
    // 'SECURITY_TEST': 'test.smartcarehis.com',
    'LMH_LIVE': '172.24.1.10',
    'HRMS': '103.177.84.241',
    'NEW_SERVER': '94.136.188.27',
    'LMH_Static': '49.248.253.211',
    'LOCAL_DEV_1': '192.168.0.121',
    'LOCAL_DEV_2': '192.168.0.175',
    'LOCAL_DEV_3': '192.168.0.154',
    'LOCAL_DEV_4': '192.168.0.194',
    'LOCAL_DEV_5': '192.168.0.179',
    'LOCAL_DEV_6': '192.168.1.3',
    'LOCAL_DEV_7': '192.168.0.137',
    'LOCAL_DEV_8': '192.168.1.38',
    'LOCAL_DEV_9': '192.168.1.14',
    'sclyte_local': '192.168.1.194'

  };

  // --------------------- Active Configuration ---------------------
  // Change this to switch environments (like CURRENT_KEY in React)
  static const String CURRENT_KEY = 'SM_222';
  static const String CURRENT_KEY_HR = 'HRMS';
  
  // Protocol and ports
  static const String PROTOCOL = 'http';
  static const int SAM_PORT = 9091;
  static const int APP_PORT = 8443;
  static const int LOGIN_PORT = 443;
  static const int SMART_CARE_PORT = 80;

  // --------------------- Computed Properties ---------------------
  /// Get the active host based on CURRENT_KEY
  static String get activeHost => HOSTS[CURRENT_KEY] ?? HOSTS['SECURITY_TEST']!;
  static String get activeHostHr => HOSTS[CURRENT_KEY_HR] ?? HOSTS['HRMS']!;
  static String get remoteAddr => activeHost;

  // --------------------- Base URLs ---------------------
  static String get appBaseUrl => '$PROTOCOL://$activeHost:$SMART_CARE_PORT';
  static String get loginBaseUrl => '$PROTOCOL://$activeHost:$LOGIN_PORT';
  static String get smartcareMainBaseUrl => '$appBaseUrl/smartcaremain';
  static String get ipdBaseUrl => '$appBaseUrl/ipd';
  static String get securityBaseUrl => '$appBaseUrl/security';
  static String get billingBaseUrl => '$appBaseUrl/billing';
  static String get masterBaseUrl => '$appBaseUrl/master'; 
  static String get sclyteBaseUrl => '$appBaseUrl/sclyte';
  static String get samBaseUrl => '$PROTOCOL://$activeHost:$SAM_PORT';
  static String get smartcarePortalUrl => '$PROTOCOL://$activeHost:$SMART_CARE_PORT/SMARTCARE';
  static String get hrBaseUrl => '$PROTOCOL://$activeHostHr:9099';


  /// Backward-compatible aliases
  static String get baseUrl => '$smartcareMainBaseUrl/';
  static String get billingUrl => '$billingBaseUrl/';
  static String get masterUrl => '$masterBaseUrl/';

  // --------------------- Utility Method ---------------------
  /// Build URL with path (like your React generateApiUrl)
  static String buildUrl(String base, String path) {
    final cleanBase = base.replaceAll(RegExp(r'/+$'), '');
    final cleanPath = path.replaceAll(RegExp(r'^/+'), '');
    return '$cleanBase/$cleanPath';
  }

  // --------------------- Debug Helper ---------------------
  static void printConfig() {
    // ignore: avoid_print
    print('''
    ════════════════════════════════════
        🌐 API HOST CONFIGURATION
    ════════════════════════════════════
    Current Key : $CURRENT_KEY
    Active Host : $activeHost
    Remote Addr : $remoteAddr
    Protocol    : $PROTOCOL  
    App Base    : $appBaseUrl
    Security Base : $securityBaseUrl
    Login URL   : $loginBaseUrl
    Main Base   : $smartcareMainBaseUrl
    IPD Base URL: $ipdBaseUrl
    Billing URL : $billingBaseUrl
    Master URL  : $masterBaseUrl
    Sclyte URL  : $sclyteBaseUrl
    SmartCare   : $smartcarePortalUrl
    ════════════════════════════════════
    ⚠️ CORS NOTE: If running in Chrome Web, use
       "Flutter Web (Disable CORS)" launch config
    ════════════════════════════════════
    ''');
  }
}
