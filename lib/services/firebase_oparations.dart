import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flink/services/authentication.dart';
import 'package:flink/views/landingscreen/landing_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FirebaseOparations with ChangeNotifier {
  late UploadTask imageUploadTask;

  // Initialize with default values to avoid LateInitializationError
  String intiUserEmail = 'No Email';
  String initUserName = 'No Username';
  String initUserImage =
      'assets/images/def image.png'; // Provide a default image

  String get getInitUsername => initUserName;
  String get getInitUserEmail => intiUserEmail;
  String get getInitUserImage => initUserImage;

  Future uploadUserAvatar(BuildContext context) async {
    try {
      Reference imageReference = FirebaseStorage.instance.ref().child(
          'userProfileAvatar/${Provider.of<LandingUtils>(context, listen: false).getUserAvatar.path}/${TimeOfDay.now()}');

      imageUploadTask = imageReference.putFile(
          Provider.of<LandingUtils>(context, listen: false).getUserAvatar);

      await imageUploadTask.whenComplete(() {
        print('Image uploaded');
      });

      imageReference.getDownloadURL().then((url) {
        Provider.of<LandingUtils>(context, listen: false).userAvatarUrl =
            url.toString();

        print(
            'The user profile avatar url: ${Provider.of<LandingUtils>(context, listen: false).userAvatarUrl}');
        notifyListeners();
      });
    } catch (e) {
      print('Error uploading avatar: $e');
    }
  }

  Future createUserCollection(BuildContext context, dynamic data) async {
    try {
      return FirebaseFirestore.instance
          .collection('user')
          .doc(Provider.of<Authentication>(context, listen: false).getUserUid)
          .set(data);
    } catch (e) {
      print('Error creating user collection: $e');
    }
  }

  Future<void> initUserData(BuildContext context) async {
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(Provider.of<Authentication>(context, listen: false).getUserUid)
          .get();

      if (userDoc.exists) {
        var data = userDoc.data();
        if (data != null) {
          initUserName = data['username'] ?? 'No Username';
          intiUserEmail = data['useremail'] ?? 'No Email';
          initUserImage = data['userimage'] ??
              Icon(EvaIcons.infoOutline); // Ensure the image is fetched
        }
      } else {
        print("User document does not exist.");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }

    notifyListeners();
  }
}
