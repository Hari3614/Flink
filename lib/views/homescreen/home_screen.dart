import 'package:flink/constants/constant_colors.dart';
import 'package:flink/services/firebase_oparations.dart';
import 'package:flink/views/chatscreen/chat_screen.dart';
import 'package:flink/views/feedscreen/feed_screen.dart';
import 'package:flink/views/homescreen/home_helpers.dart';
import 'package:flink/views/profilescreen/profile_screen.dart';
import 'package:flink/views/searchscreen/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ConstantColors constantColors = ConstantColors();

  final PageController homepageController = PageController();
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();

    // Delay Firebase initialization to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FirebaseOparations>(context, listen: false)
          .initUserData(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: constantColors.darkColor,
      body: PageView(
        controller: homepageController,
        children: [
          FeedScreen(),
          SearchScreen(),
          ChatScreen(),
          ProfileScreen(),
        ],
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (page) {
          setState(() {
            pageIndex = page;
          });
        },
      ),
      bottomNavigationBar:
          Provider.of<HomescreenHelpers>(context, listen: false)
              .bottomNavBar(context, pageIndex, homepageController),
    );
  }
}
