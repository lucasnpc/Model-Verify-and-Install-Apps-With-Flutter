import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'HomePage.dart';

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    return MaterialApp(
      theme:
          ThemeData(primarySwatch: Colors.blue, brightness: Brightness.light),
      initialRoute: "/",
      routes: {
        '/': (context) => HomePage(platform),
      },
    );
  }
}
