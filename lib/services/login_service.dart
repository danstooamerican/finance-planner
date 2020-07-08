import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class LoginService {
  Future<bool> login(String authService) async {
    final result = await FlutterWebAuth.authenticate(
      url: GlobalConfiguration().getString("backend") +
          "/oauth2/authorize/" +
          authService +
          "?redirect_uri=financeplanner://oauth2/redirect",
      callbackUrlScheme: "financeplanner",
    ).catchError((e) {
      return null;
    });

    if (result != null) {
      final token = Uri.parse(result).queryParameters['token'];

      if (token != null) {
        final storage = FlutterSecureStorage();
        await storage.write(key: "jwt", value: "Bearer " + token);

        return true;
      }
    }

    return false;
  }
}
