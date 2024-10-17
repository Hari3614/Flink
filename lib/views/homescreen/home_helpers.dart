import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';

import 'package:flink/constants/constant_colors.dart';
import 'package:flink/services/firebase_oparations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomescreenHelpers with ChangeNotifier {
  ConstantColors constantColors = ConstantColors();

  Widget bottomNavBar(
      BuildContext context, int index, PageController pageController) {
    // Fetch user image once at the start of the method to prevent multiple calls
    String? userImage =
        Provider.of<FirebaseOparations>(context, listen: false).initUserImage;

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
          icon: CircleAvatar(
              radius: 20.0, // Adjusted radius for the CircleAvatar size
              backgroundColor: constantColors.blueGreyColor,
              backgroundImage: NetworkImage(userImage) as ImageProvider),
        ),
      ],
    );
  }
}
