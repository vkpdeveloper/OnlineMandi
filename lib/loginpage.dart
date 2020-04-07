import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:shopcorona/firebaseutils/methods.dart';
import 'package:shopcorona/shopkeeper/shopdetails.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  int selectedLoginOption = 0;
  FirebaseMethods _firebaseMethods = FirebaseMethods();
  FirebaseUser user;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'images/welcome.png',
                  fit: BoxFit.fitWidth,
                  height: 250.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: <Widget>[
                      RadioListTile(
                        onChanged: (value) {
                          setState(() {
                            selectedLoginOption = value;
                          });
                        },
                        subtitle: Text(
                            "इस विकल्प के द्वारा आप हमारे ऐप के ग्राहक होंगे"),
                        groupValue: selectedLoginOption,
                        value: 0,
                        title: Text(
                          "मैं एक ग्राहक हूं",
                          style: TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 16.0),
                        ),
                      ),
                      RadioListTile(
                        onChanged: (value) {
                          setState(() {
                            selectedLoginOption = value;
                          });
                        },
                        groupValue: selectedLoginOption,
                        value: 1,
                        subtitle: Text(
                            "इस विकल्प के द्वारा आप हमारे ऐप के दुकानदार होंगे"),
                        title: Text(
                          "मैं एक दुकानदार हूं",
                          style: TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 16.0),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                GestureDetector(
                  onTap: () async {
                    if (selectedLoginOption == 0) {
                      user = await _firebaseMethods.signIn();
                      _firebaseMethods.saveCustomerData(user);
                      Navigator.pushReplacementNamed(context, '/homecustomer');
                    } else {
                      user = await _firebaseMethods.signIn();
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ShopDetails(
                                    user: user,
                                  )));
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 20.0,
                              color: Colors.grey.withOpacity(0.4),
                              offset: Offset(10, 10)),
                          BoxShadow(
                              blurRadius: 20.0,
                              color: Colors.grey.withOpacity(0.4),
                              offset: Offset(-10, -10))
                        ],
                        gradient: LinearGradient(
                            end: Alignment.topLeft,
                            begin: Alignment.topRight,
                            colors: [
                              Colors.indigo,
                              Colors.deepPurple,
                              Colors.purple
                            ]),
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(35.0)),
                    height: 40.0,
                    width: MediaQuery.of(context).size.width - 100,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left:8.0),
                            child: Align(
                              alignment: Alignment.center,
                              child: Icon(
                                EvilIcons.sc_google_plus,
                                size: 40.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 20.0,
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Login with Google",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                  color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
