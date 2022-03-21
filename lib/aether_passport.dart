// ignore: avoid_web_libraries_in_flutter
import 'package:openid_client/openid_client.dart';

import 'src/oauth.dart'
    if (dart.library.html) 'src/oauth.web.dart'
    if (dart.library.io) 'src/oauth.io.dart' as oauth;

abstract class Passport {
  Passport._();

  static Future<TokenResponse> authenticate(
      {required Uri uri,
      required String clientId,
      List<String>? scopes}) async {
    return oauth.authentication(uri, clientId, scopes ?? const []);
  }

  static void logout({
    required Uri uri, //Same uri from authenticate method
    String? idToken, //Used only in mobile logout
    String? redirectUri, //Used only in web logout
  }) {
    if (idToken == null && redirectUri == null) {
      throw new UnimplementedError(
          'Define idToken for mobile logout or redirectUri for web logout.');
    }
    oauth.logout(uri, idToken, redirectUri);
  }
}

extension AetherTokenResponseExtensions on TokenResponse {
  String get idTokenString => this.toJson()['id_token'];
}
