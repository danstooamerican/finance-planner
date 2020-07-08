import 'package:auto_size_text/auto_size_text.dart';
import 'package:financeplanner/app_localizations.dart';
import 'package:financeplanner/dependency_injection_config.dart';
import 'package:financeplanner/views/login_view/login_viewmodel.dart';
import 'package:financeplanner/views/main_view/main_screen.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key}) : super(key: key);

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
  Widget build(BuildContext buildContext) {
    return ViewModelBuilder<LoginViewModel>.nonReactive(
      builder: (context, model, child) {
        return Scaffold(
          body: AnimatedBuilder(
            animation: _animationController,
            builder: (context, _) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: FlareActor(
                      'assets/animations/background.flr',
                      animation: "idle",
                      fit: BoxFit.fill,
                    ),
                  ),
                  Positioned(
                    top: 100,
                    left: 16,
                    right: 16,
                    child: AutoSizeText(
                      AppLocalizations.of(buildContext).translate('app-title'),
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
                  Positioned.fill(
                    left: 16,
                    right: 16,
                    top: 160,
                    child: Container(
                      child: Hero(
                        tag: 'wallet',
                        child: FlareActor(
                          'assets/animations/wallet.flr',
                          animation: 'Idle',
                          fit: BoxFit.fitWidth,
                          alignment: Alignment.topCenter,
                        ),
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
                        AppLocalizations.of(buildContext).translate('login-google'),
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      onPressed: () => _login(context, model, "google"),
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
                        AppLocalizations.of(context).translate('login-facebook'),
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      onPressed: () => _login(context, model, "facebook"),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
      viewModelBuilder: () => locator<LoginViewModel>(),
    );
  }

  Future<void> _login(BuildContext context, LoginViewModel model, String authService) async {
    bool success = await model.login(authService);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(),
        ),
      );
    } else {
      final snackBar = SnackBar(
        content: Text(
          AppLocalizations.of(context).translate('login-error'),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.fixed,
      );

      Scaffold.of(context).showSnackBar(snackBar);
    }
  }
}
