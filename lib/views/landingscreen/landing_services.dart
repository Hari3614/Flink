import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flink/constants/constant_colors.dart';
import 'package:flink/services/authentication.dart';
import 'package:flink/services/firebase_oparations.dart';
import 'package:flink/views/homescreen/home_screen.dart';
import 'package:flink/views/landingscreen/landing_utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class LandingServices with ChangeNotifier {
  TextEditingController emailController = TextEditingController();
  TextEditingController userNamecontroller = TextEditingController();
  TextEditingController userPasswordController = TextEditingController();

  ConstantColors constantColors = ConstantColors();

  showUserAvatar(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.30,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: constantColors.blueGreyColor,
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 150.0),
                  child: Divider(
                    thickness: 4.0,
                    color: constantColors.whiteColor,
                  ),
                ),
                CircleAvatar(
                  radius: 80.0,
                  backgroundColor: constantColors.tarnsperant,
                  backgroundImage: FileImage(
                      Provider.of<LandingUtils>(context, listen: false)
                          .userAvatar),
                ),
                Container(
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
                            Provider.of<LandingUtils>(context, listen: false)
                                .pickUserAvatar(context, ImageSource.gallery);
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
                            Provider.of<FirebaseOparations>(context,
                                    listen: false)
                                .uploadUserAvatar(context)
                                .whenComplete(() {
                              signInSheet(context);
                            });
                          })
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  Widget passwordLessSignIn(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.40,
      width: MediaQuery.of(context).size.width,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('An error occurred. Please try again.'),
            );
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No users found.'),
            );
          } else {
            return ListView(
              children:
                  snapshot.data!.docs.map((DocumentSnapshot documentSnapshot) {
                final data = documentSnapshot.data() as Map<String, dynamic>?;

                return ListTile(
                  trailing: IconButton(
                    onPressed: () {
                      // Handle delete action here
                    },
                    icon: const Icon(FontAwesomeIcons.trashAlt),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: constantColors.tarnsperant,
                    backgroundImage: data?['userimage'] != null
                        ? NetworkImage(data!['userimage'])
                        : null,
                  ),
                  subtitle: Text(
                    data?['useremail'] ?? 'No email',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: constantColors.greenColor,
                    ),
                  ),
                  title: Text(
                    data?['username'] ?? 'No username',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: constantColors.greenColor,
                    ),
                  ),
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }

  //       <<<<<<<<  ...............Login Sheet............... >>>>>>>>

  // logInSheet(BuildContext context) {
  //   return showModalBottomSheet(
  //     isScrollControlled: true,
  //     context: context,
  //     builder: (context) {
  //       return Padding(
  //         padding:
  //             EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
  //         child: Container(
  //           height: MediaQuery.of(context).size.height * 0.30,
  //           width: MediaQuery.of(context).size.width,
  //           decoration: BoxDecoration(
  //             color: constantColors.blueGreyColor,
  //             borderRadius: const BorderRadius.only(
  //               topLeft: Radius.circular(12.0),
  //               topRight: Radius.circular(12.0),
  //             ),
  //           ),
  //           child: Column(
  //             children: [
  //               Padding(
  //                 padding: const EdgeInsets.symmetric(horizontal: 150.0),
  //                 child: Divider(
  //                   thickness: 4.0,
  //                   color: constantColors.whiteColor,
  //                 ),
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.symmetric(horizontal: 10.0),
  //                 child: TextField(
  //                   controller: userNamecontroller,
  //                   decoration: InputDecoration(
  //                       hintText: 'Enter name..',
  //                       hintStyle: TextStyle(
  //                         color: constantColors.whiteColor,
  //                         fontWeight: FontWeight.bold,
  //                         fontSize: 16.0,
  //                       )),
  //                   style: TextStyle(
  //                     color: constantColors.whiteColor,
  //                     fontWeight: FontWeight.bold,
  //                     fontSize: 18.0,
  //                   ),
  //                 ),
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.symmetric(horizontal: 10.0),
  //                 child: TextField(
  //                   controller: emailController,
  //                   decoration: InputDecoration(
  //                       hintText: 'Enter email..',
  //                       hintStyle: TextStyle(
  //                         color: constantColors.whiteColor,
  //                         fontWeight: FontWeight.bold,
  //                         fontSize: 16.0,
  //                       )),
  //                   style: TextStyle(
  //                     color: constantColors.whiteColor,
  //                     fontWeight: FontWeight.bold,
  //                     fontSize: 18.0,
  //                   ),
  //                 ),
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.symmetric(horizontal: 10.0),
  //                 child: TextField(
  //                   controller: userPasswordController,
  //                   decoration: InputDecoration(
  //                       hintText: 'Enter Password..',
  //                       hintStyle: TextStyle(
  //                         color: constantColors.whiteColor,
  //                         fontWeight: FontWeight.bold,
  //                         fontSize: 16.0,
  //                       )),
  //                   style: TextStyle(
  //                     color: constantColors.whiteColor,
  //                     fontWeight: FontWeight.bold,
  //                     fontSize: 18.0,
  //                   ),
  //                 ),
  //               ),
  //               FloatingActionButton(
  //                   child: Icon(
  //                     FontAwesomeIcons.check,
  //                     color: constantColors.blueColor,
  //                   ),
  //                   onPressed: () {
  //                     if (emailController.text.isNotEmpty) {
  //                       Provider.of<Authentication>(context, listen: false)
  //                           .logIntoAccount(emailController.text,
  //                               userPasswordController.text)
  //                           .whenComplete(() {
  //                         Navigator.pushReplacement(
  //                             context,
  //                             PageTransition(
  //                                 child: HomeScreen(),
  //                                 type: PageTransitionType.bottomToTop));
  //                       });
  //                     } else {
  //                       warningText(context, 'Fill all the data!..');
  //                     }
  //                   }),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  //   <<<<<<<< ...............  Signin Sheet ............... >>>>>>>>

  signInSheet(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: constantColors.blueGreyColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12.0),
                    topRight: Radius.circular(12.0),
                  )),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 150.0),
                    child: Divider(
                      thickness: 4.0,
                      color: constantColors.whiteColor,
                    ),
                  ),
                  CircleAvatar(
                    backgroundImage: FileImage(
                        Provider.of<LandingUtils>(context, listen: false)
                            .getUserAvatar),
                    backgroundColor: constantColors.tarnsperant,
                    radius: 60.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: TextField(
                      controller: userNamecontroller,
                      decoration: InputDecoration(
                          hintText: 'Enter name..',
                          hintStyle: TextStyle(
                            color: constantColors.whiteColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          )),
                      style: TextStyle(
                        color: constantColors.whiteColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                          hintText: 'Enter email..',
                          hintStyle: TextStyle(
                            color: constantColors.whiteColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          )),
                      style: TextStyle(
                        color: constantColors.whiteColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: TextField(
                      controller: userPasswordController,
                      decoration: InputDecoration(
                          hintText: 'Enter Password..',
                          hintStyle: TextStyle(
                            color: constantColors.whiteColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          )),
                      style: TextStyle(
                        color: constantColors.whiteColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 8.0,
                    ),
                    child: FloatingActionButton(
                        child: Icon(
                          FontAwesomeIcons.check,
                          color: constantColors.whiteColor,
                        ),
                        onPressed: () {
                          if (emailController.text.isNotEmpty) {
                            Provider.of<Authentication>(context, listen: false)
                                .createAccount(emailController.text,
                                    userPasswordController.text)
                                .whenComplete(() {
                              print('Creating colloction...');
                              Provider.of<FirebaseOparations>(context,
                                      listen: false)
                                  .createUserCollection(context, {
                                'useruid': Provider.of<Authentication>(context,
                                        listen: false)
                                    .getUserUid,
                                'useremail': emailController.text,
                                'username': userNamecontroller.text,
                                'userimage': Provider.of<LandingUtils>(context,
                                        listen: false)
                                    .getUserAvatarUrl,
                              });
                            }).whenComplete(() {
                              Navigator.pushReplacement(
                                  context,
                                  PageTransition(
                                      child: HomeScreen(),
                                      type: PageTransitionType.bottomToTop));
                            });
                          } else {
                            warningText(context, 'Fill all the data!..');
                          }
                        }),
                  )
                ],
              ),
            ),
          );
        });
  }

  //       <<<<<<<< ...............  Warning Text ............... >>>>>>>>

  // ignore: non_constant_identifier_names
  warningText(BuildContext context, String Warning) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: constantColors.darkColor,
            borderRadius: BorderRadius.circular(15.0),
          ),
          height: MediaQuery.of(context).size.height * 0.1,
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: Text(
              Warning,
              style: TextStyle(
                color: constantColors.whiteColor,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
