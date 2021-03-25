import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_buycycle/Components/ReusablePaddingWidget.dart';
import 'package:flutter_buycycle/Screens/Dashboard.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../Constants.dart';

class LoginScreen extends StatefulWidget {
  static String id = 'Login_Screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

final FirebaseAuth fa = FirebaseAuth.instance;

class _LoginScreenState extends State<LoginScreen> {
  bool isSpinning = false;
  String emailId;
  String passwd;

  void login() async {
    setState(() {
      isSpinning = true;
    });
    try {
      final user =
          await fa.signInWithEmailAndPassword(email: emailId, password: passwd);
      if (user != null) {
        setState(() {
          isSpinning = false;
        });
        Navigator.pushNamed(context, DashBoard.id);
      }
    } catch (e) {
      print(e);
      setState(() {
        isSpinning = false;
        Alert(
                context: context,
                title: "Please Try Again",
                desc: "Invalid Credentials")
            .show();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: isSpinning,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset(
                      'assets/Bike.gif',
                      height: 200.0,
                      width: 200.0,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              GestureDetector(
                onHorizontalDragDown: (DragDownDetails) {
                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                },
                child: TextField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    emailId = value;
                  },
                  decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter Your Email',
                  ),
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              GestureDetector(
                onHorizontalDragDown: (DragDownDetails) {
                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                },
                child: TextField(
                  textAlign: TextAlign.center,
                  obscureText: true,
                  onChanged: (value) {
                    passwd = value;
                  },
                  decoration: kTextFieldDecoration,
                ),
              ),
              SizedBox(
                height: 24.0,
              ),
              Paddy(
                      op: () {
                        login();
                      },
                      textVal: 'Login',
                      bColor: Colors.blue)
                  .getPadding(),
            ],
          ),
        ),
      ),
    );
  }
}
