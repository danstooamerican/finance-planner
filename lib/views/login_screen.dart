import 'package:financeplanner/models/app_state.dart';
import 'package:financeplanner/models/models.dart';
import 'package:financeplanner/views/main_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:redux/redux.dart';

import '../app_localizations.dart';

class LoginScreen extends StatelessWidget {
  final Store<AppState> store;

  LoginScreen({Key key, this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).translate('login')),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.red,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
                      title: Text(
                        AppLocalizations.of(context).translate('login-google'),
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      leading: Icon(FontAwesomeIcons.google),
                      onTap: () =>
                          _login(context, "/oauth2/authorize/google?redirect_uri=myandroidapp://oauth2/redirect"),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.blue,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
                      title: Text(
                        AppLocalizations.of(context).translate('login-facebook'),
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      leading: Icon(FontAwesomeIcons.facebookF),
                      onTap: () =>
                          _login(context, "/oauth2/authorize/google?redirect_uri=myandroidapp://oauth2/redirect"),
                    ),
                  ),
                ),
              ],
            ),
            Divider(
              indent: 8,
              endIndent: 8,
              thickness: 2,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login(BuildContext context, String authUrl) async {
    final result = await FlutterWebAuth.authenticate(
      url: GlobalConfiguration().getString("backend") + authUrl,
      callbackUrlScheme: "myandroidapp",
    ).catchError((e) {
      return null;
    });

    if (result != null) {
      final token = Uri.parse(result).queryParameters['token'];

      final storage = FlutterSecureStorage();
      await storage.write(key: "jwt", value: "Bearer " + token);

      _goToMainScreen(context);
    }
  }

  void _goToMainScreen(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(
          store: store,
        ),
      ),
    );
  }
}
