import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flink/constants/constant_colors.dart';
import 'package:flink/services/authentication.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  ConstantColors constantColors = ConstantColors();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
            onPressed: () {},
            icon: Icon(
              EvaIcons.settings,
              color: constantColors.greyColor,
            )),
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(
                EvaIcons.logOutOutline,
                color: constantColors.greyColor,
              ))
        ],
        backgroundColor: const Color.fromARGB(255, 39, 39, 39),
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
              )
            ])),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('user')
                  .doc(Provider.of<Authentication>(context, listen: false)
                      .getUserUid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return new Column(
                    children: [],
                  );
                }
              },
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              color: constantColors.darkColor.withOpacity(0.6),
            ),
          ),
        ),
      ),
    );
  }
}
