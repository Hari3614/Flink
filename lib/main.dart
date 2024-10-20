import 'package:firebase_core/firebase_core.dart';
import 'package:flink/constants/constant_colors.dart';
import 'package:flink/firebase_options.dart';
import 'package:flink/services/authentication.dart';
import 'package:flink/services/firebase_oparations.dart';
import 'package:flink/utilities/upload_post.dart';
import 'package:flink/views/feedscreen/feed_helpers.dart';
import 'package:flink/views/homescreen/home_helpers.dart';
import 'package:flink/views/landingscreen/landing_helpers.dart';
import 'package:flink/views/landingscreen/landing_services.dart';
import 'package:flink/views/landingscreen/login_screen.dart';
import 'package:flink/views/landingscreen/signup.dart';
import 'package:flink/views/profilescreen/profile_helpers.dart';
import 'package:flink/views/splashscreen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    ConstantColors constantColors = ConstantColors();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Authentication()),
        ChangeNotifierProvider(create: (_) => LandingHelpers()),
        ChangeNotifierProvider(create: (_) => LandingServices()),
        ChangeNotifierProvider(create: (_) => FirebaseOparations()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => SignUpProvider()),
        ChangeNotifierProvider(create: (_) => HomescreenHelpers()),
        ChangeNotifierProvider(create: (_) => ProfileHelpers()),
        ChangeNotifierProvider(create: (_) => UploadPost()),
        ChangeNotifierProvider(create: (_) => FeedHelpers()),
      ],
      child: MaterialApp(
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.light(
            primary: constantColors.blueColor,
          ),
          canvasColor: Colors.transparent,
        ),
      ),
    );
  }
}
