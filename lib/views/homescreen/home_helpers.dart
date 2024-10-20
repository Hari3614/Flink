import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flink/constants/constant_colors.dart';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomescreenHelpers with ChangeNotifier {
  ConstantColors constantColors = ConstantColors();

  Widget bottomNavBar(
      BuildContext context, int index, PageController pageController) {
    return CustomNavigationBar(
      currentIndex: index,
      bubbleCurve: Curves.bounceIn,
      scaleCurve: Curves.decelerate,
      selectedColor: constantColors.yellowColor,
      unSelectedColor: constantColors.greyColor,
      strokeColor: constantColors.darkColor,
      scaleFactor: 0.5,
      iconSize: 28.0,
      onTap: (val) {
        index = val;
        pageController.jumpToPage(val);
        notifyListeners();
      },
      backgroundColor: const Color.fromARGB(255, 17, 17, 17),
      items: [
        CustomNavigationBarItem(icon: Icon(EvaIcons.homeOutline)),
        CustomNavigationBarItem(icon: Icon(EvaIcons.searchOutline)),
        CustomNavigationBarItem(icon: Icon(EvaIcons.messageCircle)),
        CustomNavigationBarItem(
          icon: FutureBuilder<DocumentSnapshot>(
            future: _getUserData(), // Fetch user data
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircleAvatar(
                  radius: 20.0,
                  backgroundColor: constantColors.blueGreyColor,
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  !snapshot.data!.exists) {
                return CircleAvatar(
                  radius: 20.0,
                  backgroundColor: constantColors.blueGreyColor,
                  child:
                      Icon(Icons.person, color: Colors.white), // Fallback icon
                );
              }

              // Extract user data
              Map<String, dynamic> userData =
                  snapshot.data!.data() as Map<String, dynamic>;
              String? profileImageUrl = userData['profileImageUrl'];

              return CircleAvatar(
                radius: 20.0,
                backgroundColor: constantColors.blueGreyColor,
                backgroundImage: profileImageUrl != null
                    ? NetworkImage(profileImageUrl)
                    : null,
                child: profileImageUrl == null
                    ? Icon(Icons.person, color: Colors.white) // Fallback icon
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }

  // Method to fetch user data from Firestore
  Future<DocumentSnapshot> _getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    }
    throw Exception('No user signed in');
  }
}
