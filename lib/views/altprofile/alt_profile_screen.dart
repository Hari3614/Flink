import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flink/constants/constant_colors.dart';
import 'package:flink/services/authentication.dart';
import 'package:flink/services/firebase_oparations.dart';

import 'package:flink/views/chatscreen/personal_chat.dart';
import 'package:flink/views/homescreen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class AltProfileHelpers with ChangeNotifier {
  ConstantColors constantColors = ConstantColors();

  PreferredSizeWidget appBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      // Return an AppBar, which is a PreferredSizeWidget
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: constantColors.whiteColor,
        ),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            PageTransition(
                child: HomeScreen(), type: PageTransitionType.bottomToTop),
          );
        },
      ),
      backgroundColor: constantColors.darkColor,
      actions: [
        IconButton(
          icon: Icon(
            EvaIcons.moreVertical,
            color: constantColors.whiteColor,
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              PageTransition(
                  child: HomeScreen(), type: PageTransitionType.bottomToTop),
            );
          },
        ),
      ],
      title: RichText(
        text: TextSpan(
          text: 'FLI',
          style: TextStyle(
            color: constantColors.whiteColor,
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
          children: <TextSpan>[
            TextSpan(
              text: 'NK',
              style: TextStyle(
                color: constantColors.yellowColor,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget headerProfile(BuildContext context,
      AsyncSnapshot<DocumentSnapshot> snapshot, String userUid) {
    var userData = snapshot.data!;

    return SingleChildScrollView(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // User Profile Picture and Username
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Action on profile tap
                      },
                      child: CircleAvatar(
                        radius: 50.0, // Reduced radius
                        backgroundImage: NetworkImage(
                          userData['profileImageUrl'] ??
                              'https://via.placeholder.com/150',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        userData['username'] ?? 'No Username',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0, // Reduced font size
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                // User Stats
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Followers count
                        FutureBuilder<QuerySnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(userUid)
                              .collection('followers')
                              .get(),
                          builder: (context, followerSnapshot) {
                            if (followerSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return _buildStatCard('...', 'Followers');
                            }
                            final followerCount =
                                followerSnapshot.data?.docs.length ?? 0;
                            return _buildStatCard(
                                followerCount.toString(), 'Followers');
                          },
                        ),
                        // Following count
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: FutureBuilder<QuerySnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(userUid)
                                .collection('following')
                                .get(),
                            builder: (context, followingSnapshot) {
                              if (followingSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return _buildStatCard('...', 'Following');
                              }
                              final followingCount =
                                  followingSnapshot.data?.docs.length ?? 0;
                              return _buildStatCard(
                                  followingCount.toString(), 'Following');
                            },
                          ),
                        ),
                      ],
                    ),
                    _buildStatCard('0', 'Posts'),
                  ],
                ),
              ],
            ),
            // Follow and Message Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MaterialButton(
                  color: Colors.grey,
                  child: const Text(
                    'Follow',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  onPressed: () async {
                    try {
                      // Retrieve the logged-in user ID
                      final loggedInUserUid =
                          Provider.of<Authentication>(context, listen: false)
                              .getUserUid;
                      final FirebaseOparations firebaseOperations =
                          Provider.of<FirebaseOparations>(context,
                              listen: false);

                      // Fetch logged-in user data
                      final DocumentSnapshot loggedInUserSnapshot =
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(loggedInUserUid)
                              .get();
                      final Map<String, dynamic> loggedInUserData =
                          loggedInUserSnapshot.data() as Map<String, dynamic>;

                      // Retrieve userUid (profile being viewed) from the snapshot data
                      final viewedUserUid =
                          snapshot.data!.id; // Get the document ID
                      final viewedUserData =
                          snapshot.data!.data() as Map<String, dynamic>;

                      // Follow action
                      await firebaseOperations.followUser(
                        viewedUserUid,
                        loggedInUserUid,
                        {
                          'username': firebaseOperations.getInitUsername,
                          'userimage': loggedInUserData['profileImageUrl'] ??
                              'https://via.placeholder.com/150',
                          'useruid': loggedInUserUid,
                          'time': Timestamp.now(),
                        },
                        loggedInUserUid,
                        viewedUserUid,
                        {
                          'username': viewedUserData['username'] ?? '',
                          'userimage': viewedUserData['profileImageUrl'] ?? '',
                          'useruid': viewedUserUid,
                          'time': Timestamp.now(),
                        },
                      );

                      followedNoti(
                          context, viewedUserData['username'] ?? 'User');
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Follow action failed: $e')),
                      );
                    }
                  },
                ),
                MaterialButton(
                  color: Colors.grey,
                  child: const Text(
                    'Message',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  onPressed: () {
                    final String receiverUid =
                        snapshot.data!.id; // The ID of the user being viewed
                    final String receiverName =
                        snapshot.data!['username'] ?? 'User';
                    final String receiverProfileImage =
                        snapshot.data!['profileImageUrl'] ??
                            'https://via.placeholder.com/150';

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PersonalChatScreen(
                          receiverUid: receiverUid,
                          receiverName: receiverName,
                          receiverProfileImage: receiverProfileImage,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

// Utility for stat display
  Widget _buildStatCard(String statValue, String label) {
    return Column(
      children: [
        Text(
          statValue,
          style: TextStyle(
              color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey, fontSize: 16.0),
        ),
      ],
    );
  }

  Widget divider() {
    return Center(
      child: SizedBox(
        height: 25.0,
        width: 350.0,
        child: Divider(
          color: constantColors.greyColor,
        ),
      ),
    );
  }

  Widget middleProfile(BuildContext context, dynamic snapshot) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 150.0,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(2.0)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(FontAwesomeIcons.userAstronaut,
                    color: constantColors.yellowColor, size: 16),
                Text(
                  'Recently Added',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: constantColors.whiteColor,
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.1,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: constantColors.darkColor.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(15.0)),
            ),
          ),
        ],
      ),
    );
  }

  Widget footerProfile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.53,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: constantColors.darkColor.withOpacity(0.4),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Container(
          child: Image.asset('assets/images/nopost.png'),
        ),
      ),
    );
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

  followedNoti(BuildContext context, String name) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.1,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: constantColors.darkColor,
                borderRadius: BorderRadius.circular(12.0)),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 150.0),
                    child: Divider(
                      thickness: 4.0,
                      color: constantColors.whiteColor,
                    ),
                  ),
                  Text(
                    'Followed $name',
                    style: TextStyle(
                      color: constantColors.whiteColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
