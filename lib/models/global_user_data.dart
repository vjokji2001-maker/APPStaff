class GlobalUserData {
  static final GlobalUserData _instance = GlobalUserData._internal();

  factory GlobalUserData() {
    return _instance;
  }

  GlobalUserData._internal();

  Map<String, dynamic>? _fullResponse;
  Map<String, dynamic>? _userData;

  /// Store the entire API response (including "data", "status_code", etc.)
  void setFullResponse(Map<String, dynamic> response) {
    _fullResponse = response;
    
    // Also extract and store just the "data" part for convenience if it exists
    if (response.containsKey('data') && response['data'] is Map) {
      _userData = response['data'] as Map<String, dynamic>;
    } else {
      _userData = response;
    }
  }

  /// Get the entire raw response
  Map<String, dynamic>? get fullResponse => _fullResponse;

  /// Get just the user data object
  Map<String, dynamic>? get userData => _userData;

  /// Clear the data (e.g., on logout)
  void clear() {
    _fullResponse = null;
    _userData = null;
  }
}
