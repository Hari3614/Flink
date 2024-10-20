import 'dart:async';
import 'package:flink/constants/constant_colors.dart';
import 'package:flink/services/authentication.dart';
import 'package:flink/views/homescreen/home_screen.dart';
import 'package:flink/views/landingscreen/landing_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart'; // Import Provider

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  ConstantColors constantColors = ConstantColors();

  @override
  void initState() {
    super.initState();

    // Check login status after splash delay
    Timer(const Duration(seconds: 1), () {
      bool isLoggedIn = context.read<Authentication>().isLoggedIn;

      if (isLoggedIn) {
        // Navigate to HomePage if logged in
        Navigator.pushReplacement(
          context,
          PageTransition(
            child: HomeScreen(),
            type: PageTransitionType.leftToRight,
          ),
        );
      } else {
        // Navigate to LandingPage if not logged in
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
        child: RichText(
          text: TextSpan(
            text: 'Fli',
            style: GoogleFonts.oleoScript(
              textStyle: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: constantColors.whiteColor,
              ),
            ),
            children: <TextSpan>[
              TextSpan(
                text: 'nk',
                style: GoogleFonts.oleoScript(
                  textStyle: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: constantColors.yellowColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
