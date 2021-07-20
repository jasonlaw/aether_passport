# aether_passport

Aether Passport package project.

## Getting Started

**Example**
~~~dart
      var o = await Passport.authenticate(
          uri: Uri.parse('http://localhost:8080/auth/realms/aether-passport'),
          clientId: 'aether-billing',
          scopes: ['email', 'profile']);
~~~


**For Web**:
1. Copy callback.html and place inside web root folder.
2. **Passport.processOAuth** for OAuth redirection processing, place before runApp.
~~~dart
  var tokenResponse = await Passport.processOAuth();
  if (tokenResponse != null) {
    await LoginRepository.signInAndSync(idToken: tokenResponse.idTokenString);
  }
~~~



