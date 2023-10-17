import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheenproductmaster/login.dart';
import 'package:sheenproductmaster/product_insert.dart';
import 'package:sheenproductmaster/splash_screen.dart';
import 'package:sheenproductmaster/test.dart';

import 'company_registration.dart';
import 'controller/controller.dart';
import 'controller/registration_controller.dart';
import 'home_page.dart';

bool isLoggedIn = false;
bool isRegistered = false;
Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  isLoggedIn = await checkLogin();
  isRegistered = await checkRegistration();
  requestPermission();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => Controller()),
      ChangeNotifierProvider(create: (_) => RegistrationController()),
    ],
    child: const MyApp(),
  ));
  // FlutterNativeSplash.remove();
}

checkRegistration() async {
  bool isAuthenticated = false;
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  // prefs.setString("st_uname", "anu");
  // prefs.setString("st_pwd", "anu");
  final cid = prefs.getString("cid");
  if (cid != null) {
    isAuthenticated = true;
  } else {
    isAuthenticated = false;
  }
  return isAuthenticated;
}

checkLogin() async {
  bool isAuthenticated = false;
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final stUname = prefs.getString("st_uname");
  final stPwd = prefs.getString("st_pwd");

  if (stUname != null && stPwd != null) {
    isAuthenticated = true;
  } else {
    isAuthenticated = false;
  }
  return isAuthenticated;
}

void requestPermission() async {
  var sta = await Permission.storage.request();
  var status = Platform.isIOS
      ? await Permission.photos.request()
      : await Permission.manageExternalStorage.request();
  if (status.isGranted) {
    await Permission.manageExternalStorage.request();
  } else if (status.isDenied) {
    await Permission.manageExternalStorage.request();
  } else if (status.isRestricted) {
    await Permission.manageExternalStorage.request();
  } else if (status.isPermanentlyDenied) {
    await Permission.manageExternalStorage.request();
  }
  // if (!status1.isGranted) {
  //   var status = await Permission.manageExternalStorage.request();
  //   if (status.isGranted) {
  //   } else if (!status1.isRestricted) {
  //     await Permission.manageExternalStorage.request();
  //   } else if (!status1.isPermanentlyDenied) {
  //     await Permission.manageExternalStorage.request();
  //   } else if (!status1.isDenied) {
  //     await Permission.manageExternalStorage.request();
  //   }
  // }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        // title: 'Flutter Demo',
        theme: ThemeData(
            primaryColor: Color.fromARGB(255, 54, 51, 51),
            secondaryHeaderColor: Colors.black,
            scaffoldBackgroundColor: Colors.white,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            textTheme: GoogleFonts.aBeeZeeTextTheme()),
        // home: ProductInsert()
        home: const SplashScreen());
        // home: isRegistered
        //     ? isLoggedIn
        //         ? const ProductInsert()
        //         : const LoginPage()
        //     : const Registration());
    // home: LoginPage());
  }
}
