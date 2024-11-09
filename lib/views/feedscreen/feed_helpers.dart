import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flink/constants/constant_colors.dart';
import 'package:flink/services/authentication.dart';
import 'package:flink/services/firebase_oparations.dart';
import 'package:flink/utilities/post_options.dart';
import 'package:flink/utilities/upload_post.dart';
import 'package:flink/widgets/userpost.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class FeedHelpers with ChangeNotifier {
  ConstantColors constantColors = ConstantColors();

  PreferredSizeWidget appBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 39, 39, 39),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () {
            Provider.of<UploadPost>(context, listen: false)
                .selectPostImageType(context);
          },
          icon: Icon(
            Icons.camera_enhance_rounded,
            color: constantColors.yellowColor,
          ),
        ),
      ],
      title: RichText(
        text: TextSpan(
          text: 'FLI',
          style: GoogleFonts.oleoScript(
            textStyle: TextStyle(
              color: constantColors.whiteColor,
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
          children: <TextSpan>[
            TextSpan(
              text: 'NK',
              style: GoogleFonts.oleoScript(
                textStyle: TextStyle(
                  color: constantColors.yellowColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget FeedBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: constantColors.darkColor.withOpacity(0.9),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18.0),
            topRight: Radius.circular(18.0),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .orderBy('time', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: SizedBox(
                        height: 500.0,
                        width: 400.0,
                        // child: Lottie.asset(
                        //     'assets/animations/F-unscreen.gif'), // Loading animation using Lottie
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error fetching posts'));
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No posts available'));
                  } else {
                    return loadPost(context, snapshot);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget loadPost(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    final currentUserUid =
        Provider.of<Authentication>(context, listen: false).getUserUid;

    return ListView(
      children: [
        ...snapshot.data!.docs.map((DocumentSnapshot documentSnapshot) {
          Map<String, dynamic>? data =
              documentSnapshot.data() as Map<String, dynamic>?;
          final postId = documentSnapshot.id; // Post ID for saving

          return Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.7,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 8.0, left: 8.0, right: 8.0),
                      child: Row(
                        children: [
                          // <............................User Profile Picture............................>
                          CircleAvatar(
                            backgroundColor: constantColors.blueGreyColor,
                            radius: 20.0,
                            backgroundImage: data != null &&
                                    data['userimage'] != null
                                ? NetworkImage(data['userimage'])
                                : AssetImage('assets/default_user_image.png')
                                    as ImageProvider,
                          ),
                          SizedBox(width: 8.0),

                          //  <............................User Information (Username and Caption)............................>
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data?['username'] ?? 'Anonymous',
                                  style: TextStyle(
                                    color: constantColors.greenColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    text: documentSnapshot.get('caption'),
                                    style: TextStyle(
                                      color: constantColors.blueColor,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    children: <InlineSpan>[
                                      TextSpan(
                                        text: ', ',
                                        style: TextStyle(
                                          color: constantColors.lightColor
                                              .withOpacity(0.8),
                                        ),
                                      ),
                                      WidgetSpan(
                                        child: TimeAgoWidget(
                                          postTime:
                                              documentSnapshot.get('time'),
                                          textColor: constantColors.lightColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),

                          // Save Icon (only visible for other users' posts)

                          IconButton(
                            onPressed: () {
                              savePost(context, postId);
                            },
                            icon: Icon(
                              FontAwesomeIcons.bookmark,
                              color: constantColors.blueColor,
                              size: 24.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Post Image
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.46,
                        width: MediaQuery.of(context).size.width,
                        child: FittedBox(
                          child: Image.network(
                            documentSnapshot.get('postimage'),
                            scale: 2,
                          ),
                        ),
                      ),
                    ),
                    // Interaction Row (like, comment, award)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 21.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              print("Heart icon tapped");

                              final data = documentSnapshot.data()
                                  as Map<String, dynamic>;

                              Provider.of<PostFunctions>(context, listen: false)
                                  .addLike(
                                context,
                                data['caption'],
                                Provider.of<Authentication>(context,
                                        listen: false)
                                    .getUserUid,
                              );
                            },
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('posts')
                                  .doc(postId) // Use the postId
                                  .collection('likes')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                } else {
                                  // Get the like count
                                  int likeCount = snapshot.data!.docs.length;

                                  return _interactionIcon(
                                    icon: FontAwesomeIcons.heart,
                                    color: constantColors.redColor,
                                    count: likeCount
                                        .toString(), // Pass the like count as a string
                                  );
                                }
                              },
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Action for the comment icon
                              print("Comment icon tapped");

                              // Ensure that 'caption' field is available
                              String caption = (documentSnapshot.data()
                                      as Map<String, dynamic>?)?['caption'] ??
                                  '';

                              // Ensure the postId is valid (documentSnapshot.id should be the valid document ID)
                              String postId = documentSnapshot.id;

                              Provider.of<PostFunctions>(context, listen: false)
                                  .showCommentsSheet(
                                      context, documentSnapshot, postId);
                            },
                            child: _interactionIcon(
                              icon: FontAwesomeIcons.comment,
                              color: constantColors.greenColor,
                              count: '0',
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Action for the award icon
                              print("Award icon tapped");
                            },
                            child: _interactionIcon(
                              icon: FontAwesomeIcons.award,
                              color: constantColors.yellowColor,
                              count: '0',
                            ),
                          ),
                          Spacer(),
                          currentUserUid == documentSnapshot.get('useruid')
                              ? IconButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20.0)),
                                      ),
                                      backgroundColor: constantColors.darkColor,
                                      builder: (context) {
                                        return Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 20.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ListTile(
                                                leading: const Icon(
                                                  Icons.delete,
                                                  color: Colors.redAccent,
                                                ),
                                                title: const Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                    color: Colors.redAccent,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16.0,
                                                  ),
                                                ),
                                                onTap: () {},
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  icon: Icon(
                                    EvaIcons.moreVertical,
                                    color: constantColors.whiteColor,
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
        // "End of Feed" Message
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Text(
              'End of Feed',
              style: TextStyle(
                color: constantColors.whiteColor.withOpacity(0.2),
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _interactionIcon(
      {required IconData icon, required Color color, required String count}) {
    return Container(
      width: 80.0,
      child: Row(
        children: [
          GestureDetector(
            child: Icon(icon, color: color, size: 22.0),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              count,
              style: TextStyle(
                color: constantColors.whiteColor,
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
