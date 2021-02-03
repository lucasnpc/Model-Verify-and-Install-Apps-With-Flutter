import 'dart:io';

import 'package:flutter/material.dart';

import 'AppWidget.dart';

main(List<String> args) async {
  HttpOverrides.global = new MyHttpOverrides();

  runApp(AppWidget());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    HttpClient client = super.createHttpClient(context);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  }
}
