import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_buycycle/Components/AppBarWithoutSearch.dart';
import 'package:flutter_buycycle/Screens/Dashboard.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../Constants.dart';
import 'WelcomeScreen.dart';

String brand;
String adTitle;
String addInfo;
String price;
String location;

class SellScreenFinal extends StatefulWidget {
  static String id = 'Sell_Screen_Final';

  SellScreenFinal(brandy, adTitley, addInfoy) {
    brand = brandy;
    adTitle = adTitley;
    addInfo = addInfoy;
  }

  @override
  _SellScreenFinalState createState() => _SellScreenFinalState();
}

class _SellScreenFinalState extends State<SellScreenFinal> {
  File imageClicked;
  Image img = Image.asset('assets/click.png');
  final picker = ImagePicker();
  FirebaseStorage fbs = FirebaseStorage.instance;
  FirebaseAuth fa = FirebaseAuth.instance;
  var fs = Firestore.instance;
  BuildContext ctx;
  List<Asset> images = List<Asset>();
  List<String> imageUrls = <String>[];
  bool isUploading = false;
  bool loading = false;

  // Future<File> compressFile(File file) async {
  //   final filePath = file.absolute.path;
  //   // Create output file path
  //   // eg:- "Volume/VM/abcd_out.jpeg"
  //   final lastIndex = filePath.lastIndexOf(new RegExp(r'.jp'));
  //   final splitted = filePath.substring(0, (lastIndex));
  //   final outPath = "${splitted}_out${filePath.substring(lastIndex)}";
  //   try {
  //     var result = await FlutterImageCompress.compressAndGetFile(
  //       file.absolute.path,
  //       outPath,
  //       quality: 40,
  //     );
  //     print(file.lengthSync());
  //     print(result.lengthSync());
  //     return result;
  //   } catch (e) {
  //     print(e);
  //   }
  //   return null;
  // }

  // void imageDetector(File imgFile) async {
  //   final visionImage = FirebaseVisionImage.fromFile(imgFile);
  //   final ImageLabeler labeler = FirebaseVision.instance.imageLabeler(
  //     ImageLabelerOptions(confidenceThreshold: 0.75),
  //   );
  //   final List<ImageLabel> labels = await labeler.processImage(visionImage);
  //   for (ImageLabel label in labels) {
  //     final String text = label.text;
  //     final double confidence = label.confidence;
  //     if (text.contains('Cycle') && confidence > 75) {
  //       isCycle = true;
  //     }
  //   }
  // }

  // Future getImage() async {
  //   final pickedFile = await picker.getImage(source: ImageSource.camera);
  //   setState(() async {
  //     if (pickedFile != null) {
  //       imageClicked = File(pickedFile.path);
  //       // await imageDetector(imageClicked);
  //       var compressedImage = await compressFile(imageClicked);
  //       setState(() {
  //         img = compressedImage == null
  //             ? Image.file(imageClicked)
  //             : Image.file(compressedImage);
  //       });
  //     } else {
  //       print('No image selected.');
  //     }
  //   });
  // }

  void logout() async {
    await fa.signOut();
    Navigator.pushNamed(context, WelcomeScreen.id);
  }

  void submitData() async {
    if (images.length != 0 && price != null && location != null) {
      try {
        setState(() {
          loading = true;
        });
        int index = 0;
        int length = images.length;
        List<String> urls = [];
        DateTime now = new DateTime.now();
        var currUser = await fa.currentUser();
        for (index = 0; index < length; index++) {
          String imageName = adTitle + currUser.email + '$index';
          var reference = fbs.ref().child(currUser.email).child(imageName);

          StorageUploadTask uploadTask = reference.putData(
              (await images[index].getByteData(quality: 40))
                  .buffer
                  .asUint8List());
          StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
          urls.add(await storageTaskSnapshot.ref.getDownloadURL());
        }
        var docName = adTitle +
            currUser.email +
            DateTime(now.year, now.month, now.day).toString();
        await fs.collection('Cycle').document(docName).setData({
          'Price': price,
          'Seller': currUser.email,
          'Brand': brand,
          'AdTitle': adTitle,
          'AdInfo': addInfo,
          'Location': location,
          'Date': DateTime(now.year, now.month, now.day).toString(),
        });
        int i = 0;
        for (i = 0; i < length; i++) {
          await fs
              .collection('Cycle')
              .document(docName)
              .collection('Images')
              .add({
            'url': urls[i],
            'index': i,
          });
        }
        Navigator.pushNamed(context, DashBoard.id);
      } catch (e) {
        print(e);
        Alert(context: context, title: 'Ooho This never Happens Usually')
            .show();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;
    print('Build $loading');
    return ModalProgressHUD(
      inAsyncCall: loading,
      child: Scaffold(
        appBar: AppBarWithoutSearch(ctx: context)
            .buildAppBarWithoutSearch(context, 'Final Details'),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 5,
              child: imageSlider(context),
            ),
            ElevatedButton(
              child: Container(
                width: 150,
                child: Text("Pick images"),
                alignment: Alignment.center,
              ),
              onPressed: loadAssets,
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              margin: EdgeInsets.all(10.0),
              child: Text(
                'Price',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              alignment: Alignment.centerLeft,
            ),
            Expanded(
              child: GestureDetector(
                onHorizontalDragDown: (DragDownDetails) {
                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                },
                child: Container(
                  margin: EdgeInsets.all(5),
                  child: TextField(
                    onChanged: (value) {
                      price = value;
                    },
                    decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Enter Price',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(10.0),
              child: Text(
                'Location',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              alignment: Alignment.centerLeft,
            ),
            Expanded(
              child: GestureDetector(
                onHorizontalDragDown: (DragDownDetails) {
                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                },
                child: Container(
                  margin: EdgeInsets.all(5),
                  child: TextField(
                    onChanged: (value) {
                      location = value;
                    },
                    decoration: kTextFieldDecoration.copyWith(
                        hintText: 'Enter Location'),
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          child: FlatButton(
            child: Text('Publish'),
            onPressed: () {
              submitData();
            },
          ),
        ),
      ),
    );
  }

  Widget buildGridView() {
    return GridView.count(
      crossAxisCount: 3,
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        return Container(
          margin: EdgeInsets.all(10),
          child: AssetThumb(
            asset: asset,
            width: 300,
            height: 300,
          ),
        );
      }),
    );
  }

  Swiper imageSlider(context) {
    try {
      return new Swiper(
        autoplay: true,
        loop: false,
        itemBuilder: (BuildContext context, int index) {
          return new AssetThumb(
            asset: images[index],
            width: 300,
            height: 300,
          );
        },
        itemCount: images.length,
        viewportFraction: 0.7,
        scale: 0.8,
      );
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = <Asset>[];
    String error = 'No Error Detected';

    resultList = await MultiImagePicker.pickImages(
      maxImages: 300,
      enableCamera: true,
      selectedAssets: images,
      cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
      materialOptions: MaterialOptions(
        actionBarColor: "#abcdef",
        actionBarTitle: "Product Images",
        allViewTitle: "All Photos",
        useDetailsView: false,
        selectCircleStrokeColor: "#000000",
      ),
    );

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
      _error = error;
    });
  }
}
