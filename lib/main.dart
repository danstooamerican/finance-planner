import 'package:financeplanner/services/login_service.dart';
import 'package:financeplanner/views/login_view/login_screen.dart';
import 'package:financeplanner/views/main_view/main_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:global_configuration/global_configuration.dart';

import 'app_localizations.dart';
import 'dependency_injection_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalConfiguration().loadFromAsset("app_settings");

  setupLocator();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Finance App',
      theme: ThemeData.dark(),
      supportedLocales: [
        Locale('en', 'US'),
        Locale('de', 'DE'),
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode &&
              supportedLocale.countryCode == locale.countryCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      home: await _isLoggedIn() ? MainScreen() : LoginScreen(),
    ),
  );
}

Future<bool> _isLoggedIn() async {
  LoginService loginService = locator<LoginService>();

  return await loginService.isLoggedIn();
}
