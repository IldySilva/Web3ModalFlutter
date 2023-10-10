import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3modal_flutter/constants/string_constants.dart';
import 'package:web3modal_flutter/utils/core/i_core_utils.dart';
import 'package:web3modal_flutter/utils/w3m_logger.dart';

class CoreUtils extends ICoreUtils {
  @override
  bool isHttpUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  @override
  String createSafeUrl(String url) {
    if (url.isEmpty) return url;

    String safeUrl = url;
    if (!safeUrl.contains('://')) {
      safeUrl = url.replaceAll('/', '').replaceAll(':', '');
      safeUrl = '$safeUrl://';
    }
    return safeUrl;
  }

  @override
  String createPlainUrl(String url) {
    if (url.isEmpty) return url;

    String plainUrl = url;
    if (!plainUrl.endsWith('/')) {
      plainUrl = '$url/';
    }
    return plainUrl;
  }

  @override
  Uri? formatNativeUrl(String? appUrl, String wcUri) {
    if (appUrl == null || appUrl.isEmpty) return null;

    if (isHttpUrl(appUrl)) {
      return formatUniversalUrl(appUrl, wcUri);
    }

    String safeAppUrl = createSafeUrl(appUrl);
    String encodedWcUrl = Uri.encodeComponent(wcUri);
    W3MLoggerUtil.logger.i('Encoded WC URL: $encodedWcUrl');

    return Uri.parse('${safeAppUrl}wc?uri=$encodedWcUrl');
  }

  @override
  Uri? formatUniversalUrl(String? appUrl, String wcUri) {
    if (appUrl == null || appUrl.isEmpty) return null;

    if (!isHttpUrl(appUrl)) {
      return formatNativeUrl(appUrl, wcUri);
    }
    String plainAppUrl = appUrl;
    if (!appUrl.endsWith('/')) {
      plainAppUrl = '$appUrl/';
    }

    String encodedWcUrl = Uri.encodeComponent(wcUri);
    W3MLoggerUtil.logger.i('Encoded WC URL: $encodedWcUrl');

    return Uri.parse('${plainAppUrl}wc?uri=$encodedWcUrl');
  }

  @override
  String getUserAgent() {
    String userAgent = '${StringConstants.X_SDK_TYPE}'
        '-flutter-'
        '${StringConstants.X_SDK_VERSION}/'
        '${WalletConnectUtils.getOS()}';
    return userAgent;
  }

  @override
  Map<String, String> getAPIHeaders(String projectId, [String? referer]) {
    return {
      'x-project-id': projectId,
      'x-sdk-type': StringConstants.X_SDK_TYPE,
      'x-sdk-version': 'flutter-${StringConstants.X_SDK_VERSION}',
      'user-agent': getUserAgent(),
      'referer': referer ?? '',
    };
  }
}
