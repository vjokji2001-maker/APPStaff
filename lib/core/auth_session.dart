class AuthSession {
  final String accessToken;
  final String? refreshToken;
  final DateTime expiryTime;
  final String userId;
  final String clinicId;
  final String zoneId;
  final String branchId;
  final int subscriptionRemainingDays;

  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.expiryTime,
    required this.userId,
    required this.clinicId,
    required this.zoneId,
    required this.branchId,
    this.subscriptionRemainingDays = 0,
  });

  bool get isExpired => DateTime.now().isAfter(expiryTime);

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final token = (json['token'] ?? json['accessToken'] ?? '').toString();
    final refreshToken = (json['refreshToken'] ?? json['refresh_token'])
        ?.toString();
    final expiryValue = json['expirytime'] ?? json['expiryTime'];
    final subscriptionDays =
        int.tryParse(
          (json['subscription_remaining_days'] ??
                  json['subscriptionRemainingDays'] ??
                  0)
              .toString(),
        ) ??
        0;

    return AuthSession(
      accessToken: token,
      refreshToken: refreshToken,
      expiryTime:
          _parseExpiry(expiryValue) ??
          DateTime.now().add(const Duration(days: 1)),
      userId: (json['userId'] ?? json['UserId'] ?? '').toString(),
      clinicId: (json['clinicid'] ?? json['clinicId'] ?? '').toString(),
      zoneId: (json['zoneid'] ?? json['ZONEID'] ?? '').toString(),
      branchId: (json['branch_id'] ?? json['branchId'] ?? '').toString(),
      subscriptionRemainingDays: subscriptionDays,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': accessToken,
      'refreshToken': refreshToken,
      'expirytime': expiryTime.toIso8601String(),
      'userId': userId,
      'clinicid': clinicId,
      'zoneid': zoneId,
      'branch_id': branchId,
      'subscription_remaining_days': subscriptionRemainingDays,
    };
  }

  static DateTime? _parseExpiry(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;

    final raw = value.toString();
    try {
      return DateTime.parse(raw.replaceFirst(' ', 'T'));
    } catch (_) {
      return null;
    }
  }
}
