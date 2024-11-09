import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flink/constants/constant_colors.dart';
import 'package:flink/services/authentication.dart';
import 'package:flink/services/firebase_oparations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class PostFunctions with ChangeNotifier {
  ConstantColors constantColors = ConstantColors();
  TextEditingController commentController = TextEditingController();

  DocumentSnapshot? userData;
  String userImage = 'https://via.placeholder.com/150';

  PostFunctions() {
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    userData = await _getUserData();
    if (userData != null) {
      Map<String, dynamic> userMap = userData!.data() as Map<String, dynamic>;
      userImage =
          userMap['profileImageUrl'] ?? 'https://via.placeholder.com/150';
      notifyListeners(); // Notify listeners if user data changes
    }
  }

  Future<DocumentSnapshot?> _getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
    }
    return null;
  }

  Future<void> addLike(
      BuildContext context, String postId, String subDocId) async {
    final username =
        Provider.of<FirebaseOparations>(context, listen: false).getInitUsername;
    final userUid =
        Provider.of<Authentication>(context, listen: false).getUserUid;

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(subDocId)
        .set({
      'likes': FieldValue.increment(1),
      'username': username,
      'useruid': userUid,
      'userimage': userImage,
      'time': Timestamp.now()
    });
  }

  Future addComment(BuildContext context, postId, String comment) async {
    final username =
        Provider.of<FirebaseOparations>(context, listen: false).getInitUsername;
    final userUid =
        Provider.of<Authentication>(context, listen: false).getUserUid;
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(comment)
        .set({
      'comments': comment,
      'username': username,
      'useruid': userUid,
      'userimage': userImage,
      'time': Timestamp.now()
    });
  }

  showCommentsSheet(
      BuildContext context, DocumentSnapshot snapshot, String docId) {
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.75,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 38, 38, 38),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12.0),
                      topRight: Radius.circular(12.0))),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 150.0),
                    child: Divider(
                      thickness: 4.0,
                      color: constantColors.whiteColor,
                    ),
                  ),
                  Container(
                    width: 100,
                    decoration: BoxDecoration(
                        border: Border.all(color: constantColors.whiteColor),
                        borderRadius: BorderRadius.circular(5.0)),
                    child: Center(
                      child: Text(
                        'Comments',
                        style: TextStyle(
                            color: constantColors.blueColor,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.63,
                    width: MediaQuery.of(context).size.width,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('posts')
                          .doc(docId)
                          .collection('comments')
                          .orderBy('time')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else {
                          return new ListView(
                            children: snapshot.data!.docs
                                .map((DocumentSnapshot documentSnapshot) {
                              final data = documentSnapshot.data()
                                  as Map<String, dynamic>?;
                              return Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.11,
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        GestureDetector(
                                          child: CircleAvatar(
                                            backgroundColor:
                                                constantColors.darkColor,
                                            radius: 15.0,
                                            backgroundImage: NetworkImage(
                                              data?['profileImageUrl'] ??
                                                  'https://via.placeholder.com/150',
                                            ),
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            Container(
                                              child: Row(
                                                children: [
                                                  Text(
                                                    (documentSnapshot.data()
                                                                as Map<String,
                                                                    dynamic>?)?[
                                                            'username'] ??
                                                        'Anonymous',
                                                    style: TextStyle(
                                                      color: constantColors
                                                          .whiteColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12.0,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          child: Row(
                                            children: [
                                              IconButton(
                                                onPressed: () {},
                                                icon: Icon(
                                                  FontAwesomeIcons.arrowUp,
                                                  color: constantColors
                                                      .yellowColor,
                                                ),
                                              ),
                                              Text(
                                                '0',
                                                style: TextStyle(
                                                  color:
                                                      constantColors.whiteColor,
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () {},
                                                icon: Icon(
                                                  FontAwesomeIcons.reply,
                                                  color:
                                                      constantColors.greenColor,
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () {},
                                                icon: Icon(
                                                  FontAwesomeIcons.trash,
                                                  color:
                                                      constantColors.redColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    Container(
                                      child: Row(
                                        children: [
                                          IconButton(
                                              onPressed: () {},
                                              icon: Icon(
                                                Icons
                                                    .arrow_forward_ios_outlined,
                                                color: constantColors.blueColor,
                                                size: 12.0,
                                              )),
                                          Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Text(
                                                (documentSnapshot.data() as Map<
                                                            String, dynamic>?)?[
                                                        'comment'] ??
                                                    '',
                                                style: TextStyle(
                                                  color:
                                                      constantColors.whiteColor,
                                                  fontSize: 16.0,
                                                ),
                                              )),
                                        ],
                                      ),
                                    ),
                                    Divider(
                                      color: constantColors.whiteColor,
                                    )
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        }
                      },
                    ),
                  ),
                  Container(
                    width: 400,
                    height: 50.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: 300.0,
                          height: 20.0,
                          child: TextField(
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              hintText: 'Add Comment...',
                              hintStyle: TextStyle(
                                  color: constantColors.whiteColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            controller: commentController,
                            style: TextStyle(
                                color: constantColors.whiteColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        FloatingActionButton(
                            backgroundColor: constantColors.greenColor,
                            child: Icon(
                              FontAwesomeIcons.comment,
                              color: constantColors.whiteColor,
                            ),
                            onPressed: () {
                              print('Adding comment..');
                              final data =
                                  snapshot.data() as Map<String, dynamic>;
                              addComment(
                                context,
                                data['caption'],
                                commentController.text,
                              );
                            })
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
