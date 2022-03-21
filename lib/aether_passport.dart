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

  static Future logout({
    required Uri uri, //Same uri from authenticate method
    String? idTokenString, //Used only in mobile logout
    String? redirectString, //Used only in web logout
  }) async {
    if (idTokenString == null && redirectString == null) {
      throw new UnimplementedError(
          'Define idTokenString for mobile logout or redirectString for web logout.');
    }
    await oauth.logout(uri, idTokenString, redirectString);
  }
}

extension AetherTokenResponseExtensions on TokenResponse {
  String get idTokenString => this.toJson()['id_token'];
}
