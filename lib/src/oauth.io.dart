import 'package:http/http.dart' as http;
//import the io version
import 'package:openid_client/openid_client_io.dart';
// use url launcher package
import 'package:url_launcher/url_launcher.dart';

Future<TokenResponse> authentication(
    Uri uri, String clientId, List<String> scopes) async {
  // create the client
  var issuer = await Issuer.discover(uri);
  var client = Client(issuer, clientId);

  // create a function to open a browser with an url
  // ignore: always_declare_return_types
  urlLauncher(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceWebView: true);
    } else {
      throw 'Could not launch $url';
    }
  }

  // create an authenticator
  var authenticator = Authenticator(client,
      scopes: scopes, port: 4000, urlLancher: urlLauncher);

  // starts the authentication
  var c = await authenticator.authorize();

  // close the webview when finished
  await closeWebView();

  // return the user info
  return await c.getTokenResponse();
}

void logout(
  Uri uri,
  String? idTokenString,
  _,
) {
  http.get(Uri.parse(uri.toString() +
      '/protocol/openid-connect/logout?id_token_hint=$idTokenString'));
}
