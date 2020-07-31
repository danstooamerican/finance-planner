import 'package:financeplanner/app_localizations.dart';
import 'package:financeplanner/dependency_injection_config.dart';
import 'package:financeplanner/services/login_service.dart';
import 'package:financeplanner/views/login_view/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LogoutButton extends StatelessWidget {
  static final int _logoutButton = 1;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _logoutButton,
          child: Text(AppLocalizations.of(context).translate('logout')),
        ),
      ],
      initialValue: _logoutButton,
      onSelected: (value) {
        if (value == _logoutButton) {
          _logout(context);
        }
      },
      icon: Icon(Icons.settings),
    );
  }

  Future<void> _logout(BuildContext context) async {
    LoginService loginService = locator<LoginService>();

    await loginService.logout();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }
}
