import 'dart:ui';

import 'package:flutter/services.dart';

import 'provider_services.dart';
import 'package:betterhouse/screens/splash_screen.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp();
  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    bool inDebug = false;
    assert(() {
      inDebug = true;
      return true;
    }());
    if (inDebug) {
      return ErrorWidget(errorDetails.exception);
    }
    return Container(
      alignment: Alignment.center,
      color: Colors.green,
      child: Text(
        'Error ${errorDetails.exception.toString()}',
        style: const TextStyle(color: Colors.red),
      ),
    );
  };
  //await FirebaseAuth.instance.signOut();
  runApp(ChangeNotifierProvider<AppDataProvider>(
      create: (context) => AppDataProvider(), child: MyApp()));
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppDataProvider dataProvider = Provider.of<AppDataProvider>(context);
    return ConnectivityAppWrapper(
      app: MaterialApp(
        theme: ThemeData(
            primarySwatch: MaterialColor(int.parse("0xff04389E"), {
          50: HexColor("#04389E"),
          100: HexColor("#04389E"),
          200: HexColor("#04389E"),
          300: HexColor("#04389E"),
          400: HexColor("#04389E"),
          500: HexColor("#04389E"),
          600: HexColor("#04389E"),
          700: HexColor("#04389E"),
          800: HexColor("#04389E"),
          900: HexColor("#04389E")
        })),
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}
