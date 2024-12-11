import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flink/constants/constant_colors.dart';
import 'package:flink/views/altprofile/alt_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class AltProfile extends StatelessWidget {
  AltProfile({super.key, required this.userUid});

  final String userUid;
  final constantColors = ConstantColors();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 45, 45, 45),
      appBar: Provider.of<AltProfileHelpers>(context, listen: false)
          .appBar(context),
      body: SingleChildScrollView(
          child:

              // <<<<<<<<<<<<<<<<<.........main container.........>>>>>>>>>>>>>>>>>>>>>
              Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.0), topRight: Radius.circular(12.0)),
        ),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userUid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Provider.of<AltProfileHelpers>(context, listen: false)
                      .headerProfile(context, snapshot, userUid),
                  Provider.of<AltProfileHelpers>(context, listen: false)
                      .divider(),
                  Provider.of<AltProfileHelpers>(context, listen: false)
                      .middleProfile(
                    context,
                    snapshot,
                  ),
                  Provider.of<AltProfileHelpers>(context, listen: false)
                      .footerProfile(
                    context,
                  ),
                ],
              );
            }
          },
        ),
      )),
    );
  }
}
