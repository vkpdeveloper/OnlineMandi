import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopcorona/firebaseutils/methods.dart';

class HomeShop extends StatefulWidget {
  @override
  _HomeShopState createState() => _HomeShopState();
}

class _HomeShopState extends State<HomeShop> {
  String myUid;
  String shopName;
  List allItems;
  GlobalKey _scaffoldKey = GlobalKey();
  FirebaseMethods _methods = FirebaseMethods();

  @override
  void initState() {
    super.initState();
    getUID();
  }

  getUID() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    Firestore.instance.collection('admin').document('items').get().then((data) {
      setState(() {
        allItems = data['allItems'];
      });
    });
    setState(() {
      myUid = _prefs.getString('uid');
      shopName = _prefs.getString("shop");
    });
    print(myUid);
  }

  TextEditingController _itemNameCont = TextEditingController();
  TextEditingController _itemPriceCont = TextEditingController();

  getAllItems(BuildContext context) {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          int selectedRadio = 0;
          return AlertDialog(
            actions: <Widget>[
              FlatButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                textColor: Colors.deepPurple,
                icon: Icon(Icons.close),
                label: Text("Close"),
              ),
              FlatButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  addNewItem(context, selectedRadio);
                },
                textColor: Colors.deepPurple,
                icon: Icon(Icons.add),
                label: Text("Add Item"),
              ),
            ],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List<Widget>.generate(allItems.length, (int index) {
                    return RadioListTile<int>(
                      value: index,
                      title: Text(allItems[index]),
                      groupValue: selectedRadio,
                      onChanged: (int value) {
                        setState(() => selectedRadio = value);
                      },
                    );
                  }),
                );
              },
            ),
          );
        });
  }

  updateItem(BuildContext context, String documentId) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            contentPadding: const EdgeInsets.all(20.0),
            actions: <Widget>[
              FlatButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _itemPriceCont.clear();
                  _itemNameCont.clear();
                },
                textColor: Colors.deepPurple,
                icon: Icon(Icons.close),
                label: Text("Close"),
              ),
              FlatButton.icon(
                onPressed: () {
                  if (_itemPriceCont.text != "") {
                    Firestore.instance
                        .collection('items')
                        .document(documentId)
                        .updateData({
                      "price": _itemPriceCont.text,
                    });
                    _itemNameCont.clear();
                    _itemPriceCont.clear();
                    Navigator.of(context).pop();
                    Fluttertoast.showToast(msg: "Item updated");
                  } else {
                    Fluttertoast.showToast(msg: "Enter item details !");
                  }
                },
                textColor: Colors.deepPurple,
                icon: Icon(Icons.add),
                label: Text("Update Item"),
              ),
            ],
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _itemPriceCont,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      hintText: "वस्तु का नया दाम",
                      labelText: "वस्तु का नया दाम",
                      prefixIcon: Icon(MaterialIcons.attach_money),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(35.0))),
                ),
              ],
            ),
            title: Text(
              "वस्तु अपडेट करे",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        });
  }

  addNewItem(BuildContext context, int itemIndex) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            actions: <Widget>[
              FlatButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _itemPriceCont.clear();
                  _itemNameCont.clear();
                },
                textColor: Colors.deepPurple,
                icon: Icon(Icons.close),
                label: Text("Close"),
              ),
              FlatButton.icon(
                onPressed: () {
                  if (_itemPriceCont.text != "") {
                    Firestore.instance.collection('items').add({
                      "itemName": allItems[itemIndex],
                      "price": _itemPriceCont.text,
                      "shop": shopName,
                      "uid": myUid
                    });
                    _itemNameCont.clear();
                    _itemPriceCont.clear();
                    Navigator.of(_scaffoldKey.currentContext).pop();
                    Fluttertoast.showToast(msg: "New item added");
                  } else {
                    Fluttertoast.showToast(msg: "Enter item details !");
                  }
                },
                textColor: Colors.deepPurple,
                icon: Icon(Icons.add),
                label: Text("Add Item"),
              ),
            ],
            contentPadding: const EdgeInsets.all(20.0),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _itemPriceCont,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      hintText: "वस्तु का दाम",
                      labelText: "वस्तु का दाम",
                      prefixIcon: Icon(MaterialIcons.attach_money),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(35.0))),
                ),
              ],
            ),
            title: Text(
              "नया वस्तु जोड़े",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "सभी वस्तु",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                ),
                IconButton(
                  onPressed: () => getAllItems(context),
                  icon: Icon(Icons.add),
                  iconSize: 30.0,
                  color: Colors.black,
                )
              ],
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          myUid != null
              ? StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance
                      .collection('items')
                      .where("uid", isEqualTo: myUid)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
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
                                  title: new Text(
                                    document['itemName'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                  ),
                                  subtitle: new Text(
                                    "₹ ${document['price']}/किलोग्राम",
                                  ),
                                  leading: IconButton(
                                    onPressed: () => updateItem(
                                        context, document.documentID),
                                    color: Colors.deepPurple,
                                    icon: Icon(AntDesign.edit),
                                  ),
                                  trailing: IconButton(
                                    onPressed: () {
                                      Firestore.instance
                                          .collection('items')
                                          .document(document.documentID)
                                          .delete();
                                      Fluttertoast.showToast(
                                          msg: "Item deleted");
                                    },
                                    color: Colors.deepPurple,
                                    icon: Icon(MaterialIcons.delete),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        }
                    }
                  },
                )
              : Center(child: CircularProgressIndicator())
        ],
      ),
    );
  }
}
