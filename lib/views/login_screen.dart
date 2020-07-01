import 'package:auto_size_text/auto_size_text.dart';
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

class LoginScreen extends StatefulWidget {
  final Store<AppState> store;

  LoginScreen({Key key, this.store}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LoginScreenState();
  }
}

class LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  double _offset = 70;

  AnimationController _animationController;

  Animation<double> google;
  Animation<double> facebook;
  Animation<double> icon;

  LoginScreenState() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 700),
      vsync: this,
    );

    google = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          0.0,
          0.9,
          curve: Curves.ease,
        ),
      ),
    );

    facebook = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          0.0,
          0.6,
          curve: Curves.ease,
        ),
      ),
    );

    icon = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          0.0,
          1.0,
          curve: Curves.ease,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: widget.store,
      child: Material(
          child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, _) {
          return Stack(
            children: [
              Positioned(
                top: 100,
                left: 16,
                right: 16,
                child: AutoSizeText(
                  "Finance Planner",
                  minFontSize: 40,
                  maxFontSize: 50,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontFamily: "Roboto",
                    fontStyle: FontStyle.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                top: 160,
                child: Opacity(
                  opacity: icon.value,
                  child: Icon(
                    Icons.attach_money,
                    size: 400,
                    color: Colors.green,
                  ),
                ),
              ),
              Positioned(
                bottom: 170 + _offset * google.value,
                left: 32,
                right: 32,
                child: RaisedButton.icon(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  icon: Icon(FontAwesomeIcons.google),
                  color: Colors.red,
                  label: Text(
                    "Login with Google",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  onPressed: () => _login(context, "google"),
                ),
              ),
              Positioned(
                bottom: 90 + _offset * facebook.value,
                left: 32,
                right: 32,
                child: RaisedButton.icon(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  icon: Icon(FontAwesomeIcons.facebookF),
                  color: Colors.blue,
                  label: Text(
                    "Login with Facebook",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  onPressed: () => _login(context, "facebook"),
                ),
              ),
            ],
          );
        },
      )),
    );
  }

  Future<void> _login(BuildContext context, String authService) async {
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
          store: widget.store,
        ),
      ),
    );
  }
}
