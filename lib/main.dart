import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopcorona/customer/homepage.dart';
import 'dart:async';

import 'package:shopcorona/firebaseutils/methods.dart';
import 'package:shopcorona/loginpage.dart';
import 'package:shopcorona/shopkeeper/homeshop.dart';
import 'package:shopcorona/shopkeeper/shopdetails.dart';

main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/homecustomer': (context) => HomePage(),
        '/homeshop': (context) => HomeShop(),
        '/login': (context) => LoginPage(),
        '/details': (context) => ShopDetails(),
      },
      debugShowCheckedModeBanner: false,
      title: "Online Mandi",
      theme: ThemeData(
          fontFamily: "Josefin",
          primaryColor: Colors.deepPurple,
          accentColor: Colors.deepPurple),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  FirebaseMethods _firebaseMethods = FirebaseMethods();
  Connectivity _connectivity = Connectivity();
  bool isInternetConnected = true;

  @override
  void initState() {
    super.initState();
    getConnectivityResult();
  }

  getConnectivityResult() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      Timer(Duration(seconds: 3), () async {
        if (await _firebaseMethods.isLogged()) {
          print(_prefs.getString('isCustomer'));
          if (_prefs.getString('isCustomer') == "true") {
            Navigator.pushReplacementNamed(context, '/homecustomer');
          } else {
            Navigator.pushReplacementNamed(context, '/homeshop');
          }
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      });
    } else {
      setState(() {
        isInternetConnected = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Online Mandi",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22.0,
                  color: Colors.white),
            ),
            SizedBox(
              height: 40.0,
            ),
            if (isInternetConnected)
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            if (!isInternetConnected)
              Text(
                "कोई इंटरनेट उपलब्ध नहीं है !",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                    color: Colors.white),
              )
          ],
        ),
      ),
    );
  }
}
