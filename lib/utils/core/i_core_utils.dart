abstract class ICoreUtils {
  /// Returns true if the given [url] is a valid HTTP or HTTPS URL.
  bool isHttpUrl(String url);

  /// Creates a URL that ends with :// if the provided URL didn't have it.
  String createSafeUrl(String url);

  /// Creates a URL that ends with / if the provided URL didn't have it.
  String createPlainUrl(String url);

  /// Formats a native URL for the given [appUrl] and [wcUri].
  /// metamask:// is a native URL
  Uri? formatNativeUrl(String? appUrl, String wcUri);

  /// Formats a universal URL for the given [appUrl] and [wcUri].
  /// https://metamask.app.link/ is a universal URL
  Uri? formatUniversalUrl(String? appUrl, String wcUri);

  /// Returns the user agent string. Used with the explorer and other API endpoints.
  String getUserAgent();

  Map<String, String> getAPIHeaders(String projectId, [String? referer]);
}
