// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'package:flutter/foundation.dart';
import 'package:openid_client/openid_client.dart';

import 'src/oauth.dart'
    if (dart.library.html) 'src/oauth.web.dart'
    if (dart.library.io) 'src/oauth.io.dart' as oauth;

abstract class Passport {
  Passport._();

  static Future<TokenResponse?> authentication(
      Uri uri, String clientId, List<String> scopes) async {
    return oauth.authentication(uri, clientId, scopes);
  }

  static Future<TokenResponse?> processOAuth() async {
    return oauth.processOAuth();
  }

  static void setWebCache(String value) {
    if (!kIsWeb) return;
    window.sessionStorage['aether_passport:value'] = value;
  }

  /// The value is only read once, it will be cleared after reading.
  static String? getWebCache() {
    if (!kIsWeb) return null;
    final value = window.sessionStorage['aether_passport:value'];
    window.sessionStorage.remove('aether_passport:value');
    return value;
  }
}

extension AetherTokenResponseExtensions on TokenResponse {
  String get idTokenString => this.toJson()['id_token'];
}
