import 'package:flutter/material.dart';
import 'package:flutter_buycycle/Screens/Dashboard.dart';
import 'package:flutter_buycycle/Screens/LoginScreen.dart';
import 'package:flutter_buycycle/Screens/MyAdsPage.dart';
import 'package:flutter_buycycle/Screens/RegistrationScreen.dart';
import 'package:flutter_buycycle/Screens/SellScreen.dart';
import 'package:flutter_buycycle/Screens/WelcomeScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        DashBoard.id: (context) => DashBoard(),
        SellScreen.id: (context) => SellScreen(),
        MyAdsPage.id: (context) => MyAdsPage(),
      },
    );
  }
}
