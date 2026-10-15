import 'package:staff_mate/api/api_service.dart';
import 'package:staff_mate/core/api_result.dart';
import 'package:staff_mate/core/auth_session.dart';
import 'package:staff_mate/services/session_manger.dart';

class AppAuthService {
  const AppAuthService();

  Future<ApiResult<AuthSession>> login({
    required String userName,
    required String password,
  }) async {
    try {
      final response = await ApiService.loginUser(userName, password);
      if (response == null) {
        return ApiResult.failure(
          const ApiFailure(message: 'Login failed. Please try again.'),
        );
      }

      final payload = response['data'];
      if (payload == null || payload is! Map<String, dynamic>) {
        return ApiResult.failure(
          const ApiFailure(message: 'Invalid login response.'),
        );
      }

      final session = AuthSession.fromJson(payload);
      // Password authentication is provisional until the OTP succeeds.
      if (session.accessToken.isEmpty ||
          session.userId.isEmpty ||
          session.clinicId.isEmpty) {
        return ApiResult.failure(
          const ApiFailure(
            message: 'Incomplete login response. Please contact support.',
          ),
        );
      }
      // OTP services need these headers, but startup must not trust this session.
      await SessionManager.set2FAVerified(verified: false);
      await SessionManager.saveSession(
        bearer: SessionManager.authScheme,
        token: session.accessToken,
        clinicId: session.clinicId,
        subscriptionRemainingDays: session.subscriptionRemainingDays,
        userId: session.userId,
        zoneid: session.zoneId,
        expiryTime: session.expiryTime.toIso8601String(),
        branchId: int.tryParse(session.branchId) ?? 1,
        refreshToken: session.refreshToken,
        tokenExpiry: session.expiryTime,
      );
      return ApiResult.success(session);
    } catch (error) {
      return ApiResult.failure(
        ApiFailure(message: 'Authentication error: $error'),
      );
    }
  }

  Future<ApiResult<AuthSession>> refreshSession() async {
    try {
      final refreshed = await ApiService.refreshUserToken();
      if (!refreshed) {
        return ApiResult.failure(
          const ApiFailure(message: 'Session refresh failed.'),
        );
      }

      final session = await _readStoredSession();
      if (session == null) {
        return ApiResult.failure(
          const ApiFailure(message: 'No stored session found.'),
        );
      }

      return ApiResult.success(session);
    } catch (error) {
      return ApiResult.failure(ApiFailure(message: 'Refresh error: $error'));
    }
  }

  Future<void> logout({bool full = false}) async {
    if (full) {
      await SessionManager.fullLogout();
      ApiService.clearSession();
      return;
    }

    await SessionManager.clearSession();
    ApiService.clearSession();
  }

  Future<AuthSession?> _readStoredSession() async {
    final data = await SessionManager.getSession();
    final accessToken = (data['auth_token'] ?? data['access_token'] ?? '')
        .toString();
    if (accessToken.isEmpty) {
      return null;
    }

    final expiry = data['token_expiry'] is DateTime
        ? data['token_expiry'] as DateTime
        : DateTime.now().add(const Duration(days: 1));

    final subscriptionRemainingDays =
        int.tryParse((data['subscription_remaining_days'] ?? 0).toString()) ??
        0;

    return AuthSession(
      accessToken: accessToken,
      refreshToken: (data['refresh_token'] ?? '').toString(),
      expiryTime: expiry,
      userId: (data['userId'] ?? '').toString(),
      clinicId: (data['clinicId'] ?? '').toString(),
      zoneId: (data['zoneid'] ?? '').toString(),
      branchId: (data['branchId'] ?? '').toString(),
      subscriptionRemainingDays: subscriptionRemainingDays,
    );
  }
}
