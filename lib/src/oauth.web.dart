import 'package:openid_client/openid_client_browser.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<TokenResponse?> authentication(
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
    html.window.sessionStorage.remove("aether_passport:url");
    authenticator.authorize(); // this will redirect the browser
  } else {
    // return the user info
    return await c.getTokenResponse();
  }
}

Future<TokenResponse?> processOAuth() async {
  final authUrl = html.window.sessionStorage["aether_passport:url"];
  if (authUrl == null || authUrl.isEmpty || !authUrl.contains('callback.html'))
    return null;
  html.window.sessionStorage.remove("aether_passport:url");

  //final state = html.window.sessionStorage["openid_client:state"];
  //if (state == null || state.isEmpty) return null;

  var uri = Uri(query: Uri.parse(authUrl).fragment);
  var queryParameters = uri.queryParameters;

  return TokenResponse.fromJson(queryParameters);
}
