import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheenproductmaster/company_registration.dart';
import 'package:sheenproductmaster/login.dart';
import 'package:sheenproductmaster/product_insert.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLoggedIn = false;
  bool isRegistered = false;

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

  navigate() async {
    await Future.delayed(Duration(seconds: 3), () async {
      isLoggedIn = await checkLogin();
      isRegistered = await checkRegistration();
      Navigator.push(
          context,
          PageRouteBuilder(
              opaque: false, // set to false
              pageBuilder: (_, __, ___) {
                if (isRegistered) {
                  if (isLoggedIn) {
                    return ProductInsert();
                  } else {
                    return LoginPage();
                  }
                } else {
                  return Registration();
                }
              }));
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    navigate();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: InkWell(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Center(
            child: Column(
          children: [
            // SizedBox(
            //   height: size.height * 0.4,
            // ),
            Expanded(
              child: Container(
                  height: 150,
                  width: 150,
                  child: Image.asset(
                    "assets/sheen.png",
                  )),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0, bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "VEGA BUSINESS SOFTWARE",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  )
                  // Container(
                  //     height: 50,
                  //     // width: 150,
                  //     child: Image.asset(
                  //       "assets/logo_black_bg.png",
                  //     )),
                ],
              ),
            )
          ],
        )),
      ),
    );
  }
}
