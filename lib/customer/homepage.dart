import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shopcorona/firebaseutils/methods.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseMethods _methods = FirebaseMethods();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
          icon: Icon(Icons.call),
          onPressed: () => launch("tel: +918700304115"),
          label: Text(
            "बेचने के लिए संपर्क करे",
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              _methods.signOutApp();
              Navigator.pushReplacementNamed(context, '/login');
              Fluttertoast.showToast(msg: "Logout successful");
            },
            tooltip: "Logout",
            icon: Icon(Icons.exit_to_app),
            color: Colors.white,
          )
        ],
        title: Text("Welcome, Dashboard"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('items').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) return new Text('कुछ त्रुटि हुई !');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return new Center(
                child: CircularProgressIndicator(),
              );
            default:
              if (snapshot.data.documents.length == 0) {
                return Text("कोई वस्तु उपलब्ध नहीं है");
              } else {
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: new ListView(
                    primary: true,
                    shrinkWrap: true,
                    children: snapshot.data.documents
                        .map((DocumentSnapshot document) {
                      return new ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Text(
                              document['itemName'],
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16.0),
                            ),
                            new Text(
                              "₹ ${document['price']}/किलोग्राम",
                            ),
                          ],
                        ),
                        subtitle: new Text(
                          "${document['shop']}",
                        ),
                      );
                    }).toList(),
                  ),
                );
              }
          }
        },
      ),
    );
  }
}
