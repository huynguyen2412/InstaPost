import 'dart:io';

import 'package:flutter/material.dart';
import 'package:insta_post/src/ui/landing_page.dart';
import 'package:provider/provider.dart';
import 'package:insta_post/src/models/user_state_model.dart';

void main() {
  HttpOverrides.global = new MyHttpOverrides();
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserStateModel(),
      child: MyApp(),
    )
  );
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Insta_post',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LandingPage(),
      // home: PreviewPostList(title: "Foo_bar"),
    );
  }
}


