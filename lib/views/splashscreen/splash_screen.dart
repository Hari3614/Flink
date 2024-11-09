import 'dart:async';
import 'package:flink/constants/constant_colors.dart';
import 'package:flink/services/authentication.dart';
import 'package:flink/views/homescreen/home_screen.dart';
import 'package:flink/views/landingscreen/landing_screen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  ConstantColors constantColors = ConstantColors();
  bool showLogo = false; // Controls logo visibility
  bool showGifEnd = false; // Controls end GIF visibility

  @override
  void initState() {
    super.initState();

    // Show the logo after 1.5 seconds and hide the GIF
    Timer(const Duration(seconds: 1, milliseconds: 500), () {
      setState(() {
        showLogo = true;
      });
    });

    // Show the GIF again after a total of 3 seconds
    Timer(const Duration(seconds: 3), () {
      setState(() {
        showLogo = false; // Hide the logo
        showGifEnd = true; // Show the GIF again
      });
    });

    // Navigate to the next screen after 4.5 seconds
    Timer(const Duration(seconds: 4, milliseconds: 500), () {
      bool isLoggedIn = context.read<Authentication>().isLoggedIn;

      if (isLoggedIn) {
        Navigator.pushReplacement(
          context,
          PageTransition(
            child: HomeScreen(),
            type: PageTransitionType.leftToRight,
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          PageTransition(
            child: LandingPage(),
            type: PageTransitionType.leftToRight,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: constantColors.darkColor,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Show the GIF at the start and at the end
            if (!showLogo || showGifEnd)
              Image.asset(
                'assets/animations/Animated-F-unscreen.gif',
                width: 150, // Adjust as needed
                height: 150, // Adjust as needed
              ),

            if (showLogo && !showGifEnd)
              AnimatedOpacity(
                opacity:
                    showLogo ? 1.0 : 0.0, // Control opacity based on showLogo
                duration:
                    const Duration(seconds: 1), // Duration of fade-in effect
                child: Image.asset(
                  'assets/images/Flinklogo1-removebg-preview.png',
                  width: 150, // Adjust as needed
                  height: 150, // Adjust as needed
                ),
              ),
          ],
        ),
      ),
    );
  }
}
