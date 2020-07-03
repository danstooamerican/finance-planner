import 'package:financeplanner/views/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LogoutButton extends StatelessWidget {
  static final int _logoutButton = 1;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _logoutButton,
          child: Text("Logout"),
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

  void _logout(BuildContext context) {
    FlutterSecureStorage().delete(key: "jwt");

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }
}
