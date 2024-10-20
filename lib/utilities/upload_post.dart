import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flink/constants/constant_colors.dart';
import 'package:flink/services/authentication.dart';
import 'package:flink/services/firebase_oparations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class UploadPost with ChangeNotifier {
  TextEditingController captionController = TextEditingController();

  FocusNode captionFocusNode = FocusNode();

  ConstantColors constantColors = ConstantColors();

  late File uploadPostImage;
  File get getUploadPostImage => uploadPostImage;

  late String uploadPostImageurl;
  String get getUploadPostImageUrl => uploadPostImageurl;

  final picker = ImagePicker();
  late UploadTask imagePostUploadTask;

  Future pickUploadPostImage(BuildContext context, ImageSource source) async {
    final uploadPostImageVal = await picker.pickImage(source: source);

    uploadPostImageVal == null
        ? print('Select image')
        : uploadPostImage = File(uploadPostImageVal.path);

    print(uploadPostImageVal?.path);

    // ignore: unnecessary_null_comparison
    uploadPostImage != null
        ? showPostImage(context)
        : print('Image upload Error');

    notifyListeners();
  }

  Future uploadPostImageToFirebase() async {
    Reference imageReference = FirebaseStorage.instance
        .ref()
        .child('posts/${uploadPostImage.path}/${TimeOfDay.now()}');

    imagePostUploadTask = imageReference.putFile(uploadPostImage);

    await imagePostUploadTask.whenComplete(() {
      print('Post image uploaded to storage');
    });

    imageReference.getDownloadURL().then((imageUrl) {
      uploadPostImageurl = imageUrl;

      print(uploadPostImageurl);
    });

    notifyListeners();
  }

  selectPostImageType(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
              height: MediaQuery.of(context).size.height * 0.2,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 47, 47, 47),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 150.0),
                    child: Divider(
                      thickness: 4.0,
                      color: constantColors.greyColor,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 7.0),
                    child: Text(
                      'Select From',
                      style: TextStyle(
                        color: constantColors.greyColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ),

                  const SizedBox(
                      height: 20.0), // Add spacing to avoid bottom overflow
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: constantColors.greyColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 20.0),
                        ),
                        onPressed: () {
                          pickUploadPostImage(context, ImageSource.gallery);
                        },
                        child: Text(
                          'Gallery',
                          style: TextStyle(
                            color: constantColors.darkColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: constantColors.greyColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 20.0),
                        ),
                        onPressed: () {
                          pickUploadPostImage(context, ImageSource.camera);
                        },
                        child: Text(
                          'Camera',
                          style: TextStyle(
                            color: constantColors.darkColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ));
        });
  }

  showPostImage(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.38,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 47, 47, 47),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 150.0),
                child: Divider(
                  thickness: 4.0,
                  color: constantColors.greyColor,
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.only(top: 7.0),
              //   child: Text(
              //     'Select From',
              //     style: TextStyle(
              //       color: constantColors.greyColor,
              //       fontWeight: FontWeight.bold,
              //       fontSize: 16.0,
              //     ),
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                child: Container(
                  height: 200.0,
                  width: 400.0,
                  child: Image.file(
                    uploadPostImage,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MaterialButton(
                          child: Text(
                            'Reselect',
                            style: TextStyle(
                              color: constantColors.whiteColor,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationColor: constantColors.whiteColor,
                            ),
                          ),
                          onPressed: () {
                            selectPostImageType(context);
                          }),
                      MaterialButton(
                          color: constantColors.blueColor,
                          child: Text(
                            'Confirm Image',
                            style: TextStyle(
                              color: constantColors.whiteColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            uploadPostImageToFirebase().whenComplete(() {
                              editPostSheet(context);
                              print('Image uploded');
                            });
                          })
                    ]),
              ),
            ],
          ),
        );
      },
    );
  }

  editPostSheet(BuildContext context) {
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return GestureDetector(
            onTap: () {
              // Dismiss the keyboard when tapped outside the TextField
              FocusScope.of(context).unfocus();
            },
            child: Container(
              height: MediaQuery.of(context).size.height * 0.75,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: constantColors.blueGreyColor,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 150.0),
                    child: Divider(
                      thickness: 4.0,
                      color: constantColors.greyColor,
                    ),
                  ),
                  Container(
                    child: Row(
                      children: [
                        Container(
                          child: Column(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.image_aspect_ratio_outlined,
                                  color: constantColors.greenColor,
                                ),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.fit_screen_outlined,
                                  color: constantColors.yellowColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 200.0,
                          width: 300.0,
                          child: Image.file(
                            uploadPostImage,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Focus on the TextField when tapping this area
                      FocusScope.of(context).requestFocus(captionFocusNode);
                    },
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            height: 30.0,
                            width: 30.0,
                            child: Image.asset('assets/images/dis.png'),
                          ),
                          Container(
                            height: 110.0,
                            width: 5.0,
                            color: constantColors.greyColor,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Container(
                              height: 120.0,
                              width: 330.0,
                              child: TextField(
                                maxLines: 5,
                                textCapitalization: TextCapitalization.words,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(100),
                                ],
                                maxLengthEnforcement:
                                    MaxLengthEnforcement.enforced,
                                maxLength: 100,
                                controller: captionController,
                                focusNode:
                                    captionFocusNode, // Attach focus node
                                style: TextStyle(
                                  color: constantColors.whiteColor,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Add A Caption...',
                                  hintStyle: TextStyle(
                                    color: constantColors.whiteColor,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  MaterialButton(
                    onPressed: () async {
                      Provider.of<FirebaseOparations>(context, listen: false)
                          .uploadPostData(captionController.text, {
                        'caption': captionController.text,
                        'username': Provider.of<FirebaseOparations>(context,
                                listen: false)
                            .getInitUsername,
                        'userImage': Provider.of<FirebaseOparations>(context,
                                listen: false)
                            .getInitUserImage,
                        'useruid':
                            Provider.of<Authentication>(context, listen: false)
                                .getUserUid,
                        'time': Timestamp.now(),
                        'useremail': Provider.of<FirebaseOparations>(context,
                                listen: false)
                            .getInitUserEmail,
                      }).whenComplete(() {
                        Navigator.pop(context);
                      });
                    },
                    color: constantColors.blueColor,
                    child: Text(
                      'Post',
                      style: TextStyle(
                          color: constantColors.whiteColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}


//<<< 20:09;
