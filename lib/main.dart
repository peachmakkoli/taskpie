// Image Credit: App logo by Freepik: http://www.freepik.com/
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
  static const MaterialColor slateblue =
      MaterialColor(_slatebluePrimaryValue, <int, Color>{
    50: Color(0xFFE8F1F8),
    100: Color(0xFFC5DBEE),
    200: Color(0xFF9FC4E2),
    300: Color(0xFF79ACD6),
    400: Color(0xFF5C9ACE),
    500: Color(_slatebluePrimaryValue),
    600: Color(0xFF3980BF),
    700: Color(0xFF3175B8),
    800: Color(0xFF296BB0),
    900: Color(0xFF1B58A3),
  });
  static const int _slatebluePrimaryValue = 0xFF3F88C5;

  static const MaterialColor slateblueAccent =
      MaterialColor(_slateblueAccentValue, <int, Color>{
    100: Color(0xFFDAEAFF),
    200: Color(_slateblueAccentValue),
    400: Color(0xFF74AEFF),
    700: Color(0xFF5B9FFF),
  });
  static const int _slateblueAccentValue = 0xFFA7CCFF;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: OneContext().builder,
      debugShowCheckedModeBanner: false,
      title: 'TaskPie',
      theme: ThemeData(
        primarySwatch: slateblue,
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: slateblue),
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
