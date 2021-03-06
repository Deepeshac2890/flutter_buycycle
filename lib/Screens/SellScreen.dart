/*
Created By: Deepesh Acharya
Maintained By: Deepesh Acharya
*/

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_buycycle/Components/AppBarWithoutSearch.dart';
import 'package:flutter_buycycle/Constants.dart';
import 'package:flutter_buycycle/Screens/SellScreenFinal.dart';

/*
For Personal Reference
* Elements Used here :
* Gesture Detector
*/
class SellScreen extends StatefulWidget {
  static String id = 'Sell_Screen';
  @override
  _SellScreenState createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  String brand;
  String titleAd;
  String addInfo;
  FirebaseAuth fa = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      appBar: AppBarWithoutSearch(ctx: context)
          .buildAppBarWithoutSearch(context, 'Include Some Details', true),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            InputWithTitle(
              inputTitle: 'Brand',
              hintText: 'Brand',
              maxi: 20,
              maxLines: 1,
              onChange: (value) {
                brand = value;
              },
            ),
            InputWithTitle(
              inputTitle: 'Ad Title',
              hintText: 'Key Features of your Item',
              maxi: 70,
              maxLines: 2,
              onChange: (value) {
                titleAd = value;
              },
            ),
            InputWithTitle(
              inputTitle: 'Additional Information',
              hintText:
                  'Include condition,features and other relevant information',
              maxi: 200,
              maxLines: 4,
              onChange: (value) {
                addInfo = value;
              },
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 5.0,
        // ignore: deprecated_member_use
        child: FlatButton(
          onPressed: () {
            print(addInfo);
            print(titleAd);
            if (addInfo != null && titleAd != null && brand != null) {
              if (addInfo.length > 10 &&
                  titleAd.length > 5 &&
                  brand.length > 0) {
                print('pushing');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SellScreenFinal(
                      brand,
                      titleAd,
                      addInfo,
                    ),
                  ),
                );
              }
            }
          },
          child: Text(
            'Next',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class InputWithTitle extends StatelessWidget {
  String inputTitle;
  String hintText;
  int maxi;
  int maxLines;
  Function onChange;

  InputWithTitle(
      {this.hintText,
      this.inputTitle,
      this.maxi,
      this.maxLines,
      this.onChange});
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return GestureDetector(
      onHorizontalDragDown: (dragDownDetails) {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      },
      child: Column(
        children: [
          Container(
            child: Text(
              inputTitle,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.all(10.0),
          ),
          Container(
            margin: EdgeInsets.all(5),
            child: TextField(
              onChanged: onChange,
              maxLength: maxi,
              maxLines: maxLines,
              decoration: kTextFieldDecoration.copyWith(
                hintText: hintText,
              ),
            ),
          )
        ],
      ),
    );
  }
}
