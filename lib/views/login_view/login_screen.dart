import 'package:auto_size_text/auto_size_text.dart';
import 'package:financeplanner/app_localizations.dart';
import 'package:financeplanner/dependency_injection_config.dart';
import 'package:financeplanner/views/login_view/login_viewmodel.dart';
import 'package:financeplanner/views/main_view/main_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginScreenState();
  }
}

class LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  LoginViewModel _viewModel;

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

    _viewModel = locator<LoginViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, _) {
          return Stack(
            children: [
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
                    fontStyle: FontStyle.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Positioned(
                bottom: _calcAnimationPosition(170, google.value),
                left: 32,
                right: 32,
                child: _getLoginButton(
                  FontAwesomeIcons.google,
                  Colors.red,
                  "google",
                ),
              ),
              Positioned(
                bottom: _calcAnimationPosition(90, facebook.value),
                left: 32,
                right: 32,
                child: _getLoginButton(
                  FontAwesomeIcons.facebookF,
                  Colors.blue,
                  "facebook",
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _getLoginButton(IconData icon, Color color, String loginMethod) {
    return RaisedButton.icon(
      padding: const EdgeInsets.symmetric(vertical: 12),
      icon: Icon(icon),
      color: color,
      label: Text(
        AppLocalizations.of(context).translate('login-' + loginMethod),
        style: TextStyle(
          fontSize: 20,
        ),
      ),
      onPressed: () => _login(context, _viewModel, loginMethod),
    );
  }

  double _calcAnimationPosition(double start, double progress) {
    final double _offset = 70;

    return start + _offset * progress;
  }

  Future<void> _login(BuildContext context, LoginViewModel model, String authService) async {
    bool success = await model.login(authService);

    if (success) {
      _navigateToMainScreen();
    } else {
      _displayLoginError();
    }
  }

  void _navigateToMainScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(),
      ),
    );
  }

  void _displayLoginError() {
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
