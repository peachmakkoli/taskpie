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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: OneContext().builder,
      debugShowCheckedModeBanner: false,
      title: 'TaskPie',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.indigo),
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
