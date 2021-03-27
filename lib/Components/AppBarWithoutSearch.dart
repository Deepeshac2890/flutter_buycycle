/*
Created By: Deepesh Acharya
Maintained By: Deepesh Acharya
*/

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_buycycle/Screens/WelcomeScreen.dart';

class AppBarWithoutSearch {
  final ctx;
  AppBarWithoutSearch({this.ctx});
  AppBar buildAppBarWithoutSearch(BuildContext context, String title) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: <Widget>[
        IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              logout();
            }),
      ],
      title: Center(
        child: Text(title),
      ),
      backgroundColor: Colors.black,
    );
  }

  FirebaseAuth fa = FirebaseAuth.instance;

  void logout() async {
    await fa.signOut();
    Navigator.popUntil(ctx, ModalRoute.withName(WelcomeScreen.id));
  }
}
