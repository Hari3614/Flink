import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flink/constants/constant_colors.dart';
import 'package:flink/services/authentication.dart';
import 'package:flink/views/homescreen/home_screen.dart';
import 'package:flink/views/landingscreen/landing_services.dart';
import 'package:flink/views/landingscreen/login_screen.dart';
import 'package:flink/views/landingscreen/signup.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class LandingHelpers with ChangeNotifier {
  ConstantColors constantColors = ConstantColors();

  // Widget to display the body image
  Widget bodyImage(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage('assets/images/login.png')),
      ),
    );
  }

  // Widget for the tagline text
  Widget taglineText(BuildContext context) {
    return Positioned(
      top: 450.0,
      left: 10.0,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 170.0),
        child: RichText(
          text: TextSpan(
            text: 'Are ',
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: constantColors.whiteColor,
              ),
            ),
            children: <TextSpan>[
              TextSpan(
                text: 'You ',
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: constantColors.whiteColor,
                  ),
                ),
              ),
              TextSpan(
                text: 'Social ',
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: constantColors.yellowColor,
                  ),
                ),
              ),
              TextSpan(
                text: '?',
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: constantColors.whiteColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget for the main authentication buttons

  Widget mainButton(BuildContext context) {
    return Positioned(
      top: 630.0,
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Email Authentication Button
            GestureDetector(
              onTap: () {
                emailAuthsheet(context);
              },
              child: Container(
                width: 80.0,
                height: 40.0,
                decoration: BoxDecoration(
                  border: Border.all(color: constantColors.yellowColor),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(
                  EvaIcons.emailOutline,
                  color: constantColors.yellowColor,
                ),
              ),
            ),

            // Google Authentication Button
            GestureDetector(
              onTap: () async {
                print('Sign in with Google');
                try {
                  // Call the signInWithGoogle method and wait for it to complete
                  bool success =
                      await Provider.of<Authentication>(context, listen: false)
                          .signInWithGoogle();

                  if (success) {
                    // After sign-in is complete, navigate to HomeScreen
                    Navigator.pushReplacement(
                      context,
                      PageTransition(
                        child: HomeScreen(),
                        type: PageTransitionType.leftToRight,
                      ),
                    );
                  } else {
                    // Handle sign-in failure, such as cancellation
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Failed to sign in. Please try again.')),
                    );
                  }
                } catch (e) {
                  print('Error signing in with Google: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please complete the sign-in .')),
                  );
                }
              },
              child: Container(
                width: 80.0,
                height: 40.0,
                decoration: BoxDecoration(
                  border: Border.all(color: constantColors.redColor),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(
                  EvaIcons.google,
                  color: constantColors.redColor,
                ),
              ),
            ),

            // Facebook Authentication Button
            GestureDetector(
              child: Container(
                width: 80.0,
                height: 40.0,
                decoration: BoxDecoration(
                  border: Border.all(color: constantColors.blueColor),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(
                  EvaIcons.facebook,
                  color: constantColors.blueColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget for the privacy text
  Widget privacyText(BuildContext context) {
    return Positioned(
      top: 720.0,
      left: 20.0,
      right: 20.0,
      child: Container(
        child: const Column(
          children: [
            Text(
              " By continuing you agree Flink's Terms of",
              style: TextStyle(
                color: Color.fromRGBO(39, 39, 39, 1),
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              " Services & Privacy Policy",
              style: TextStyle(
                color: Color.fromRGBO(39, 39, 39, 1),
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to show email authentication sheet
  emailAuthsheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: constantColors.buttomSheet,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15.0),
              topRight: Radius.circular(15.0),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 150.0),
                child: Divider(
                  thickness: 4.0,
                  color: constantColors.whiteColor,
                ),
              ),
              Provider.of<LandingServices>(context, listen: false)
                  .passwordLessSignIn(context),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MaterialButton(
                    color: constantColors.blueColor,
                    child: Text(
                      'Log in',
                      style: TextStyle(
                        color: constantColors.whiteColor,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LogInSheet()),
                      );
                    },
                  ),
                  MaterialButton(
                    color: constantColors.redColor,
                    child: Text(
                      'Sign in',
                      style: TextStyle(
                        color: constantColors.whiteColor,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
