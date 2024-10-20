import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flink/constants/constant_colors.dart';
import 'package:flink/services/authentication.dart';
import 'package:flink/views/profilescreen/profile_helpers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final ConstantColors constantColors = ConstantColors();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 182, 182, 182),
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () {},
          icon: Icon(
            EvaIcons.settings,
            color: constantColors.greyColor,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Show the logout confirmation dialog
              logOutDialog(context);
            },
            icon: Icon(
              EvaIcons.logOutOutline,
              color: constantColors.greyColor,
            ),
          ),
        ],
        backgroundColor: const Color.fromARGB(255, 39, 39, 39),
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              color: const Color.fromARGB(255, 40, 40, 40),
            ),
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(Provider.of<Authentication>(context, listen: false)
                      .getUserUid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingIndicator();
                } else if (snapshot.hasError) {
                  return _buildErrorMessage('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || !snapshot.data!.exists) {
                  return _buildErrorMessage('User not found.');
                } else {
                  return Column(
                    children: [
                      ProfileHelpers().headerProfile(context, snapshot.data!),
                      ProfileHelpers().divider(),
                      ProfileHelpers().middleProfile(context, snapshot),
                      ProfileHelpers().footerProfile(
                        context,
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Center _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Center _buildErrorMessage(String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(color: constantColors.redColor),
      ),
    );
  }
}
