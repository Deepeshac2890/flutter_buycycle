/*
Created By: Deepesh Acharya
Maintained By: Deepesh Acharya
*/
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_buycycle/Components/AppBarWithoutSearch.dart';
import 'package:flutter_buycycle/Components/BottomBar.dart';
import 'package:flutter_buycycle/Screens/WelcomeScreen.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:widget_circular_animator/widget_circular_animator.dart';

/*
For Personal Reference
* Elements Used here :
This is still in progress so more will come!!
 */
class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with TickerProviderStateMixin {
  FirebaseAuth fa = FirebaseAuth.instance;
  Firestore fs = Firestore.instance;
  String imgName;
  String name = '';
  AnimationController _resizableController;
  String email = '';
  var loggedUser;
  File imageClicked;
  Image img = Image.asset('assets/click.png');
  final picker = ImagePicker();

  void logout() async {
    await fa.signOut();
    Navigator.popUntil(context, ModalRoute.withName(WelcomeScreen.id));
  }

  AnimatedBuilder getContainer() {
    return new AnimatedBuilder(
        animation: _resizableController,
        builder: (context, child) {
          return Center(
            child: Container(
              padding: EdgeInsets.all(24),
              child: CircleAvatar(
                radius: 100,
              ),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(12)),
                border: Border.all(
                    color: Colors.blue,
                    width: _resizableController.value * 10 + 1),
              ),
            ),
          );
        });
  }

  void currentUser() async {
    loggedUser = await fa.currentUser();
    print(loggedUser.uid);
    getData();
  }

  void getData() async {
    var data = await fs
        .collection('Users')
        .document(loggedUser.uid)
        .collection('Details')
        .document('Details')
        .get();
    String namea = await data.data['Name'];
    String emaila = await data.data['Email'];
    String imgNamea = await data.data['Profile Image'];
    print(namea);

    setState(() {
      name = namea;
      print(name);
      email = emaila;
      imgName = imgNamea;
    });
  }

  @override
  void initState() {
    currentUser();
    // TODO: implement initState
    _resizableController = new AnimationController(
      vsync: this,
      duration: new Duration(
        milliseconds: 1000,
      ),
    );
    _resizableController.addStatusListener((animationStatus) {
      switch (animationStatus) {
        case AnimationStatus.completed:
          _resizableController.reverse();
          break;
        case AnimationStatus.dismissed:
          _resizableController.forward();
          break;
        case AnimationStatus.forward:
          break;
        case AnimationStatus.reverse:
          break;
      }
    });
    _resizableController.forward();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWithoutSearch(ctx: context)
          .buildAppBarWithoutSearch(context, ' '),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: WidgetCircularAnimator(
                innerIconsSize: 3,
                outerIconsSize: 3,
                innerAnimation: Curves.bounceIn,
                outerAnimation: Curves.bounceIn,
                innerColor: Colors.orangeAccent,
                reverse: false,
                outerColor: Colors.orangeAccent,
                innerAnimationSeconds: 10,
                outerAnimationSeconds: 10,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      getImage();
                    },
                    child: ClipRRect(
                      borderRadius: new BorderRadius.circular(8.0),
                      // need to update this with proper crop system !!
                      child: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: img.image, // picked file
                                fit: BoxFit.fill)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(children: [
              Container(
                child: Text(
                  name,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                child: Text(
                  email,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: BottomBar(
        ctx: context,
      ),
    );
  }

  // This is coming from flutter_image_compress package.
  Future<File> compressFile(File file) async {
    final filePath = file.absolute.path;
    // Create output file path
    // eg:- "Volume/VM/abcd_out.jpeg"
    final lastIndex = filePath.lastIndexOf(new RegExp(r'.jp'));
    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";
    try {
      var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        outPath,
        quality: 40,
      );
      print(file.lengthSync());
      print(result.lengthSync());
      return result;
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(
        source: ImageSource.camera, preferredCameraDevice: CameraDevice.front);

    setState(() async {
      if (pickedFile != null) {
        imageClicked = File(pickedFile.path);
        // await imageDetector(imageClicked);
        var compressedImage = await compressFile(imageClicked);
        setState(() {
          img = compressedImage == null
              ? Image.file(imageClicked)
              : Image.file(compressedImage);
        });
      } else {
        print('No image selected.');
      }
    });
  }
}
