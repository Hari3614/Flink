import 'dart:async';

import 'package:flink/constants/constant_colors.dart';
import 'package:flink/views/landingscreen/landing_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  ConstantColors constantColors = ConstantColors();

  @override
  void initState() {
    super.initState(); // Call super.initState() at the beginning

    Timer(
      const Duration(seconds: 1),
      () {
        Navigator.pushReplacement(
          context,
          PageTransition(
            child: LandingPage(),
            type: PageTransitionType.leftToRight,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: constantColors.darkColor,
      body: Center(
        child: RichText(
          text: TextSpan(
            text: 'Fli',
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: constantColors.whiteColor,
              ),
            ),
            children: <TextSpan>[
              TextSpan(
                text: 'nk',
                style: GoogleFonts.poppins(
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
