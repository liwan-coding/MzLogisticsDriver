class AppConfig {
  const AppConfig._();

  static const String _apiBaseUrlFromEnv = String.fromEnvironment('API_BASE_URL');

  /// Local MoveX API. Override with `--dart-define=API_BASE_URL=...`.
  static const String apiBaseUrlDefault = 'https://movexapi.liwan.om/api/v1';

  static String get apiBaseUrl {
    if (_apiBaseUrlFromEnv.isNotEmpty) return _apiBaseUrlFromEnv;
    return apiBaseUrlDefault;
  }

  static const String demoEmail = 'driver@omanhaulers.om';
  static const String demoPassword = 'Password123!';
  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const String tokenStorageKey = 'mz_driver_token';
  static const String localeStorageKey = 'mz_driver_locale';

  /// Temporarily hidden until live tracking is ready to ship.
  static const bool liveTrackingEnabled = false;

  /// Automatic background location sharing for active trips. When enabled the
  /// driver app runs a foreground service that keeps posting the driver's GPS
  /// position for the active trip even while the app is backgrounded or the
  /// task has been swiped away.
  static const bool backgroundTrackingEnabled = true;

  /// How often the background service captures and uploads a location fix.
  static const Duration backgroundTrackingInterval = Duration(seconds: 15);

  /// SharedPreferences key holding the trip id the background service reports
  /// for. Shared with the background isolate, which cannot reach Riverpod.
  static const String activeTripStorageKey = 'mz_driver_active_trip';

  /// Android notification channel used by the tracking foreground service.
  /// Created in `DriverApplication`; the id must match that class.
  static const String trackingChannelId = 'mz_driver_tracking';
}
