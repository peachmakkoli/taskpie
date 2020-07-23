import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:one_context/one_context.dart';

import 'package:taskpie/screens/login/landing_page.dart';

Future<void> main() async {
  await DotEnv().load('.env');
  await SyncfusionLicense.registerLicense(DotEnv().env['SF_LICENSE_KEY']);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static const MaterialColor carolinablue =
      MaterialColor(_carolinabluePrimaryValue, <int, Color>{
    50: Color(0xFFE0F4FD),
    100: Color(0xFFB3E4FA),
    200: Color(0xFF80D3F6),
    300: Color(0xFF4DC1F2),
    400: Color(0xFF26B3F0),
    500: Color(_carolinabluePrimaryValue),
    600: Color(0xFF009EEB),
    700: Color(0xFF0095E8),
    800: Color(0xFF008BE5),
    900: Color(0xFF007BE0),
  });
  static const int _carolinabluePrimaryValue = 0xFF00A6ED;

  static const MaterialColor carolinablueAccent =
      MaterialColor(_carolinablueAccentValue, <int, Color>{
    100: Color(0xFFFFFFFF),
    200: Color(_carolinablueAccentValue),
    400: Color(0xFFA1CFFF),
    700: Color(0xFF88C2FF),
  });
  static const int _carolinablueAccentValue = 0xFFD4E9FF;

  static const MaterialColor coral =
      MaterialColor(_coralPrimaryValue, <int, Color>{
    50: Color(0xFFFFEEEF),
    100: Color(0xFFFFD5D8),
    200: Color(0xFFFFB9BE),
    300: Color(0xFFFF9DA4),
    400: Color(0xFFFF8891),
    500: Color(_coralPrimaryValue),
    600: Color(0xFFFF6B75),
    700: Color(0xFFFF606A),
    800: Color(0xFFFF5660),
    900: Color(0xFFFF434D),
  });
  static const int _coralPrimaryValue = 0xFFFF737D;

  static const MaterialColor coralAccent =
      MaterialColor(_coralAccentValue, <int, Color>{
    100: Color(0xFFFFFFFF),
    200: Color(_coralAccentValue),
    400: Color(0xFFFFEBEC),
    700: Color(0xFFFFD1D3),
  });
  static const int _coralAccentValue = 0xFFFFFFFF;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: OneContext().builder,
      debugShowCheckedModeBanner: false,
      title: 'TaskPie',
      theme: ThemeData(
        primarySwatch: coral,
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Color(0xFFF46262)),
          border: OutlineInputBorder(
            gapPadding: 10,
          ),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LandingPage(),
    );
  }
}
