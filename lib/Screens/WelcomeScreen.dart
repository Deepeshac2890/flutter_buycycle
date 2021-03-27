/*
Created By: Deepesh Acharya
Maintained By: Deepesh Acharya
*/

import 'dart:ui';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_buycycle/Components/ReusablePaddingWidget.dart';
import 'package:flutter_buycycle/Screens/LoginScreen.dart';
import 'package:flutter_buycycle/Screens/RegistrationScreen.dart';

/*
For Personal Reference
* Elements Used here :
Not much is being Used Here.
*/

class WelcomeScreen extends StatefulWidget {
  static String id = 'Welcome_Screen';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    // This needs to be added in each Screen's build method to prevent Landscape mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset(
                      'assets/Bike.gif',
                      height: 100.0,
                      width: 150.0,
                    ),
                  ),
                ),
                TypewriterAnimatedTextKit(
                  text: ['BUYCYCLE'],
                  textStyle: TextStyle(
                    fontSize: 35.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            Paddy(
                    op: () {
                      Navigator.pushNamed(context, LoginScreen.id);
                    },
                    textVal: 'Log In',
                    bColor: Colors.lightBlue)
                .getPadding(),
            Paddy(
                    op: () {
                      Navigator.pushNamed(context, RegistrationScreen.id);
                    },
                    textVal: 'Register',
                    bColor: Colors.blue)
                .getPadding(),
          ],
        ),
      ),
    );
  }
}
