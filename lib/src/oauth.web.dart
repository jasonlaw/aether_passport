// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';
import 'dart:async';
import 'package:openid_client/openid_client_browser.dart';
import 'package:url_launcher/url_launcher.dart';

Future _launchURL(String url) async {
  if (!await launch(
    url,
    webOnlyWindowName: '_self',
  )) throw 'Could not launch $url';
}

Future<TokenResponse> authentication(
    Uri uri, String clientId, List<String> scopes) async {
  // create the client
  var issuer = await Issuer.discover(uri);
  var client = Client(issuer, clientId);

  // create an authenticator
  var authenticator = Authenticator(client, scopes: scopes);

  // Our current app URL
  final currentUri = Uri.base;

// Generate the URL redirection to our static.html page
  final redirectUri = Uri(
    host: currentUri.host,
    scheme: currentUri.scheme,
    port: currentUri.port,
    path: '/callback.html',
  );

  authenticator.flow.redirectUri = redirectUri;

  // get the credential
  var c = await authenticator.credential;

  if (c == null) {
    // starts the authentication
    //html.window.sessionStorage.remove("aether_passport:url");
    return await authenticator
        .authorizeWithPopup(); // this will redirect the browser
  } else {
    // return the user info
    return await c.getTokenResponse();
  }
}

Future logout(
  Uri uri,
  String? token,
  String? redirectUri,
) async {
  String redirect = uri.toString() +
      '/protocol/openid-connect/logout?redirect_uri=$redirectUri';
  String encodedRedirectUri = Uri.encodeComponent(redirect);
  Uri base = Uri(
    scheme: Uri.base.scheme,
    host: Uri.base.host,
    port: Uri.base.port,
  );
  _launchURL(base.toString() + '/logout.html?redirect_uri=$encodedRedirectUri');
}

extension AetherAuthenticatorExtensions on Authenticator {
  Future<TokenResponse> authorizeWithPopup({
    int popupHeight = 640,
    int popupWidth = 480,
  }) async {
    _forgetCredentials();
    html.window.localStorage['openid_client:state'] = flow.state;

    final top = (html.window.outerHeight - popupHeight) / 2 +
        (html.window.screen?.available.top ?? 0);
    final left = (html.window.outerWidth - popupWidth) / 2 +
        (html.window.screen?.available.left ?? 0);

    var options =
        'width=$popupWidth,height=$popupHeight,toolbar=no,location=no,directories=no,status=no,menubar=no,copyhistory=no&top=$top,left=$left';

    final child = html.window.open(
      flow.authenticationUri.toString(),
      "aether_passport",
      options,
    );

    final c = new Completer<TokenResponse>();
    html.window.onMessage.first.then((event) {
      final url = event.data.toString();
      final uri = Uri(query: Uri.parse(url).fragment);
      final queryParameters = uri.queryParameters;
      final response = TokenResponse.fromJson(queryParameters);

      html.window.localStorage['openid_client:auth'] =
          json.encode(queryParameters);

      c.complete(response);
      child.close();
    });

    return await c.future;
  }

  void _forgetCredentials() {
    html.window.localStorage.remove('openid_client:state');
    html.window.localStorage.remove('openid_client:auth');
  }
}
