/*
Created By: Deepesh Acharya
Maintained By: Deepesh Acharya
*/
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_buycycle/Components/ReusablePaddingWidget.dart';
import 'package:flutter_buycycle/LanguageList.dart';
import 'package:flutter_buycycle/Screens/Dashboard.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../Constants.dart';

/*
For Personal Reference
* Elements Used here :
* DropDownMenu
* Hero
* GestureDetector
*/
// Personal TODO List:
// TODO: Fix the should make public Radio buttons in case of typing
class RegistrationScreen extends StatefulWidget {
  static String id = 'Registration_Screen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

Firestore fs = Firestore.instance;
List<DropdownMenuItem<String>> ls = <DropdownMenuItem<String>>[];

class _RegistrationScreenState extends State<RegistrationScreen> {
  final FirebaseAuth fa = FirebaseAuth.instance;
  String emailId;
  String password;
  String fName;
  // String gender; Implement the gender Radio Buttons Later
  bool showSpinner = false;
  var selectedLanguage = 'English';
  String phoneNumber;
  String answer = 'Yes';

  @override
  void initState() {
    dragdownRegister();
    super.initState();
  }

  void dragdownRegister() {
    ls = [];
    for (String languageName in languageList) {
      DropdownMenuItem dm = DropdownMenuItem<String>(
        child: Text(languageName),
        value: languageName,
      );
      ls.add(dm);
    }
  }

  void register() async {
    setState(() {
      showSpinner = true;
    });
    if (emailId.contains('@') && password.length > 6) {
      try {
        // Always remember to enable authentication from firebase console
        final user = await fa.createUserWithEmailAndPassword(
            email: emailId, password: password);
        if (user != null) {
          await fs
              .collection('Users')
              .document(user.uid)
              .collection('Details')
              .document('Details')
              .setData({
            'Name': fName,
            'Email': emailId,
            'Profile Image': '',
            'Language': languageMap[selectedLanguage],
            'Phone Number': phoneNumber,
            'isPhonePublic': answer,
          });
          await fs
              .collection('UIDS')
              .document(emailId)
              .setData({'uid': user.uid});
          setState(() {
            showSpinner = false;
          });
          await user.sendEmailVerification();
          Navigator.pushNamed(context, DashBoard.id);
        }
      } catch (e) {
        print(e);
      }
    } else {
      Alert(context: context, title: 'Incorrect Details').show();
      setState(() {
        showSpinner = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    dragdownRegister();
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
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
                    height: 200.0,
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
                  keyboardType: TextInputType.name,
                  onChanged: (value) {
                    fName = value;
                  },
                  decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter Your Full Name',
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
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    phoneNumber = value;
                  },
                  decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter Your Phone Number',
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
                  obscureText: true,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    password = value;
                  },
                  decoration: kTextFieldDecoration,
                ),
              ),
              SizedBox(height: 24),
              Container(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Default Language : ',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      getPicker()
                    ]),
                alignment: Alignment.center,
                padding: EdgeInsets.only(bottom: 30.0),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('Allow Buyers to Contact You ? '),
                  Row(
                    children: [
                      Radio(
                        value: 'Yes',
                        groupValue: answer,
                        onChanged: (value) {
                          setState(() {
                            answer = value;
                          });
                        },
                      ),
                      Text('Yes'),
                    ],
                  ),
                  Row(
                    children: [
                      Radio(
                        value: 'No',
                        groupValue: answer,
                        onChanged: (value) {
                          setState(() {
                            answer = value;
                          });
                        },
                      ),
                      Text('No'),
                    ],
                  )
                ],
              ),
              SizedBox(
                height: 24.0,
              ),
              Flexible(
                child: Paddy(
                        op: () async {
                          register();
                        },
                        textVal: 'Register',
                        bColor: Colors.blue)
                    .getPadding(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DropdownButton<String> getAndroidPicker() {
    return DropdownButton<String>(
      value: selectedLanguage,
      onChanged: (value) {
        setState(() {
          selectedLanguage = value;
        });
      },
      items: ls,
    );
  }

  CupertinoPicker getIOSPicker() {
    return CupertinoPicker(
      itemExtent: 32.0,
      onSelectedItemChanged: (value) {
        setState(() {
          selectedLanguage = languageList[value];
        });
      },
      children: ls,
    );
  }

  Widget getPicker() {
    if (Platform.isIOS)
      return getIOSPicker();
    else if (Platform.isAndroid) return getAndroidPicker();
  }
}
