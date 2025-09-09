import 'package:flutter/foundation.dart';

enum AppRole { admin, tenant, staff }

AppRole parseRole(String s) {
  switch (s.toLowerCase()) {
    case 'admin':
      return AppRole.admin;
    case 'staff':
      return AppRole.staff;
    default:
      return AppRole.tenant;
  }
}

/// Central place to resolve per-role, per-platform base URLs
/// with sensible defaults for dev (Web / Android emulator / real device).
class AppEnv {
  static final AppRole role =
      parseRole(const String.fromEnvironment('APP_ROLE', defaultValue: 'tenant'));

  /// Global override (applies everywhere)
  static const String _global =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');

  // Role-specific overrides (optional)
  static const String _webAdmin =
      String.fromEnvironment('API_BASE_URL_WEB_ADMIN', defaultValue: '');
  static const String _webTenant =
      String.fromEnvironment('API_BASE_URL_WEB_TENANT', defaultValue: '');
  static const String _webStaff =
      String.fromEnvironment('API_BASE_URL_WEB_STAFF', defaultValue: '');

  static const String _androidAdmin =
      String.fromEnvironment('API_BASE_URL_ANDROID_ADMIN', defaultValue: '');
  static const String _androidTenant =
      String.fromEnvironment('API_BASE_URL_ANDROID_TENANT', defaultValue: '');
  static const String _androidStaff =
      String.fromEnvironment('API_BASE_URL_ANDROID_STAFF', defaultValue: '');

  /// 👉 REPLACE this with your actual LAN IP for real Android device
  static const String _lanHost = "http://192.168.x.x:8000";

  /// Pick the most specific override, otherwise fallback to sensible defaults.
  static String resolveBaseUrl({AppRole? overrideRole}) {
    final r = overrideRole ?? role;

    if (kIsWeb) {
      if (r == AppRole.admin && _webAdmin.isNotEmpty) return _webAdmin;
      if (r == AppRole.tenant && _webTenant.isNotEmpty) return _webTenant;
      if (r == AppRole.staff && _webStaff.isNotEmpty) return _webStaff;

      if (_global.isNotEmpty) return _global;

      // ✅ Default host for Web build
      return "http://localhost:8000";
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      if (r == AppRole.admin && _androidAdmin.isNotEmpty) return _androidAdmin;
      if (r == AppRole.tenant && _androidTenant.isNotEmpty) return _androidTenant;
      if (r == AppRole.staff && _androidStaff.isNotEmpty) return _androidStaff;

      if (_global.isNotEmpty) return _global;

      // ✅ Default host for Android emulator
      //    Use LAN IP if running on a physical device
      return _lanHost.isNotEmpty ? _lanHost : "http://10.0.2.2:8000";
    }

    // Desktop / iOS simulator
    if (_global.isNotEmpty) return _global;

    // ✅ Default host for desktop/iOS
    return "http://localhost:8000";
  }
}
