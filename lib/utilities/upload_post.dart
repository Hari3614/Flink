import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flink/constants/constant_colors.dart';
import 'package:flink/services/authentication.dart';
import 'package:flink/services/firebase_oparations.dart';
import 'package:flink/views/homescreen/home_screen.dart';
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

  Future uploadPostImageToFirebase(BuildContext context) async {
    _showLoadingDialog(context);

    Reference imageReference = FirebaseStorage.instance
        .ref()
        .child('posts/${uploadPostImage.path}/${TimeOfDay.now()}');

    imagePostUploadTask = imageReference.putFile(uploadPostImage);

    await imagePostUploadTask.whenComplete(() {
      print('Post image uploaded to storage');
    });

    return await imageReference.getDownloadURL().then((imageUrl) {
      uploadPostImageurl = imageUrl;
      print('Image URL: $uploadPostImageurl');

      _hideLoadingDialog(context);
    });
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
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: constantColors.greyColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          padding: const EdgeInsets.symmetric(
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
                          // ignore: prefer_const_constructors
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
                            uploadPostImageToFirebase(context).whenComplete(() {
                              editPostSheet(context);
                              print('Image uploaded');
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
                color: const Color.fromARGB(255, 56, 56, 56),
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
                                focusNode: captionFocusNode,
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
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  FloatingActionButton.extended(
                    backgroundColor: constantColors.blueColor,
                    label: Text(
                      'Post',
                      style: TextStyle(
                        color: constantColors.whiteColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    icon: Icon(
                      Icons.send_sharp,
                      color: constantColors.whiteColor,
                    ),
                    onPressed: () async {
                      _showLoadingDialog(
                          context); // Show loading when posting starts
                      await uploadPostImageToFirebase(context);

                      try {
                        DocumentSnapshot userData = await _getUserData();

                        if (userData.exists && userData.data() != null) {
                          // Cast the user data to Map<String, dynamic>
                          Map<String, dynamic> userMap =
                              userData.data() as Map<String, dynamic>;

                          // Now access the userImage field safely
                          String userImage = userMap['profileImageUrl'] ??
                              'https://via.placeholder.com/150'; // Use a default image if the field is missing

                          // Proceed with uploading post data
                          await Provider.of<FirebaseOparations>(context,
                                  listen: false)
                              .uploadPostData(
                            captionController.text,
                            {
                              'postimage': getUploadPostImageUrl,
                              'caption': captionController.text,
                              'username': Provider.of<FirebaseOparations>(
                                      context,
                                      listen: false)
                                  .getInitUsername,
                              'userimage':
                                  userImage, // Use the retrieved user image here
                              'useruid': Provider.of<Authentication>(context,
                                      listen: false)
                                  .getUserUid,
                              'time': Timestamp.now(),
                            },
                          ).whenComplete(() {
                            _hideLoadingDialog(context);
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomeScreen()),
                              (Route<dynamic> route) => false,
                            );
                          });
                        } else {
                          // Handle the case where the user document does not exist
                          print('User document does not exist.');
                          _hideLoadingDialog(context);
                        }
                      } catch (e) {
                        print('Error retrieving user data: $e');
                        _hideLoadingDialog(context);
                      }
                    },
                  )
                ],
              ),
            ),
          );
        });
  }

  Future<DocumentSnapshot> _getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    }
    throw Exception('No user signed in');
  }

  _showLoadingDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Center(
          child: SizedBox(
            width: 100,
            height: 100,
            child: Image.asset('assets/animations/F-unscreen.gif'),
          ),
        );
      },
    );
  }

  _hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
