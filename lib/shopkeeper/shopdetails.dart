import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shopcorona/firebaseutils/methods.dart';
import 'package:shopcorona/models/shopdetailsmodel.dart';

class ShopDetails extends StatefulWidget {
  final FirebaseUser user;

  const ShopDetails({Key key, this.user}) : super(key: key);
  @override
  _ShopDetailsState createState() => _ShopDetailsState();
}

class _ShopDetailsState extends State<ShopDetails> {
  FirebaseMethods _firebaseMethods = FirebaseMethods();
  FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController _shopnameController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _otpController = TextEditingController();
  String verificationId;
  AuthCredential _authCredential;

  @override
  void initState() {
    super.initState();
  }

  bool isCodeSent = false;

  void _signInWithPhoneNumber() async {
    _authCredential = await PhoneAuthProvider.getCredential(
        verificationId: verificationId, smsCode: _otpController.text);
    _auth.signInWithCredential(_authCredential).catchError((error) {
      Fluttertoast.showToast(msg: "Verification failed !");
    }).then((data) async {
      ShopDetailsModel _details = ShopDetailsModel(
          mobile: _mobileController.text, shopName: _shopnameController.text);
      _firebaseMethods.saveShopkeeperData(_details, widget.user);
      Fluttertoast.showToast(msg: "Verification success");
      Navigator.pushReplacementNamed(context, '/homeshop');
      setState(() {
        isCodeSent = false;
      });
    });
  }

  verifyPhone() {
    PhoneVerificationCompleted _verificationDone = (AuthCredential credential) {
      _auth.signInWithCredential(credential).then((result) {
        ShopDetailsModel _details = ShopDetailsModel(
            mobile: _mobileController.text, shopName: _shopnameController.text);
        _firebaseMethods.saveShopkeeperData(_details, widget.user);
        Fluttertoast.showToast(msg: "Verification success !");
        Navigator.pushReplacementNamed(context, '/homeshop');
      }).catchError((error) {
        Fluttertoast.showToast(msg: "Verification failed !");
        setState(() {
          isCodeSent = false;
        });
      });
    };

    PhoneCodeAutoRetrievalTimeout _codeTimeOut = (String verId) {
      setState(() {
        verificationId = verId;
        isCodeSent = true;
      });
    };

    PhoneVerificationFailed _verificationFailed = (AuthException exception) {
      print(exception.message);
      Fluttertoast.showToast(msg: "Verification failed !");
    };

    PhoneCodeSent _codeSent = (String verId, [int forceToken]) {
      Fluttertoast.showToast(msg: "OTP sent successfully");
      setState(() {
        isCodeSent = true;
        verificationId = verId;
      });
    };

    _auth.verifyPhoneNumber(
        phoneNumber: "+91${_mobileController.text}",
        timeout: Duration(seconds: 2),
        verificationCompleted: _verificationDone,
        verificationFailed: _verificationFailed,
        codeSent: _codeSent,
        codeAutoRetrievalTimeout: _codeTimeOut);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 20.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      "नमस्कार, ",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          color: Colors.black),
                    ),
                    Text(
                      "दुकानदार",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                          color: Colors.deepPurple),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(35.0),
                      topRight: Radius.circular(35.0)),
                ),
                elevation: 30.0,
                color: Colors.white,
                child: Container(
                    padding: const EdgeInsets.all(15.0),
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width - 20,
                    child: Column(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "दुकान का विवरण भरें",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18.0),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Column(
                            children: <Widget>[
                              TextField(
                                controller: _shopnameController,
                                decoration: InputDecoration(
                                    hintText: "दुकान का नाम",
                                    labelText: "दुकान का नाम",
                                    prefixIcon: Icon(MaterialIcons.business),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(35.0))),
                              ),
                              SizedBox(
                                height: 15.0,
                              ),
                              TextField(
                                controller: _mobileController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    hintText: "दुकानदार का मोबाइल नंबर",
                                    labelText: "मोबाइल नंबर",
                                    prefixIcon:
                                        Icon(MaterialIcons.phone_android),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(35.0))),
                              ),
                              SizedBox(
                                height: 30.0,
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (_shopnameController.text != "" &&
                                      _mobileController.text.length == 10) {
                                    verifyPhone();
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "Fill all the details");
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
                                      borderRadius:
                                          BorderRadius.circular(35.0)),
                                  height: 50.0,
                                  width: MediaQuery.of(context).size.width - 60,
                                  child: Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: Align(
                                          alignment: Alignment.center,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                "Next",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16.0,
                                                    color: Colors.white),
                                              ),
                                              SizedBox(
                                                width: 10.0,
                                              ),
                                              Icon(
                                                Icons.chevron_right,
                                                color: Colors.white,
                                                size: 30.0,
                                              )
                                            ],
                                          ))),
                                ),
                              ),
                              SizedBox(
                                height: 40.0,
                              ),
                              if (isCodeSent) ...[
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    "OTP सत्यापित करें",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                  ),
                                ),
                                SizedBox(
                                  height: 15.0,
                                ),
                                TextField(
                                  controller: _otpController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      hintText: "Enter One Time Password",
                                      labelText: "One Time Password",
                                      prefixIcon: Icon(MaterialIcons.lock),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(35.0))),
                                ),
                                SizedBox(
                                  height: 30.0,
                                ),
                                GestureDetector(
                                  onTap: _signInWithPhoneNumber,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              blurRadius: 20.0,
                                              color:
                                                  Colors.grey.withOpacity(0.4),
                                              offset: Offset(10, 10)),
                                          BoxShadow(
                                              blurRadius: 20.0,
                                              color:
                                                  Colors.grey.withOpacity(0.4),
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
                                        borderRadius:
                                            BorderRadius.circular(35.0)),
                                    height: 50.0,
                                    width:
                                        MediaQuery.of(context).size.width - 60,
                                    child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10.0),
                                        child: Align(
                                            alignment: Alignment.center,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  "Verify",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16.0,
                                                      color: Colors.white),
                                                ),
                                              ],
                                            ))),
                                  ),
                                ),
                              ]
                            ],
                          ),
                        )
                      ],
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
