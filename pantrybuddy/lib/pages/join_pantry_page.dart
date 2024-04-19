//import 'dart:js_interop';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pantrybuddy/pages/account_page.dart';
import 'package:pantrybuddy/pages/inventory_page.dart';
import 'package:pantrybuddy/pages/notif_page.dart';
import 'package:pantrybuddy/reg/login_page.dart';
//import 'package:pantrybuddy/pages/join_pantry_page.dart';

class JoinPantryPage extends StatefulWidget {
  const JoinPantryPage({Key? key}) : super(key: key);

  @override
  State<JoinPantryPage> createState() => _JoinPantryPageState();
}

class _JoinPantryPageState extends State<JoinPantryPage> {
  final user = FirebaseAuth.instance.currentUser!;
  final _textController = TextEditingController();

  String? myUserID = FirebaseAuth.instance.currentUser!.uid;

  //String code = 'n/a';

  String place = '0';

  // this function doesnt do shit lmfao
  // void getPantryCode(String pantryID) async {

  // }

  // this function should add the user to a pantry
  void addUserToPantry() {}

  void invalidCodeDialog() {
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("ERROR CODE NOT VALID"),
      content: Text("Please input valid code"),
      actions: [
        okButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // can only read information from here. writing functions above doesnt work
    String inputCode = _textController.text;
    //print("holder in this moment is" + holder);

    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        backgroundColor: Colors.green[400],
        elevation: 0,
        title: Text("Top Bar"),
      ),
      endDrawer: Drawer(
        child: Container(
          color: Colors.green[400],
          child: ListView(
            children: [
              ListTile(
                // each page is a ListTitle
                leading: Icon(Icons.account_box),
                title: Text(
                  "Account",
                  style: TextStyle(fontSize: 20),
                ),
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => AccountPage()));
                },
              ),
              ListTile(
                // each page is a ListTitle
                leading: Icon(Icons.notifications),
                title: Text(
                  "Notifications",
                  style: TextStyle(fontSize: 20),
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => NotificationPage()));
                },
              ),
              ListTile(
                // each page is a ListTitle
                leading: Icon(Icons.food_bank),
                title: Text(
                  "Inventory ** ",
                  style: TextStyle(fontSize: 20),
                ),
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => InventoryPage()));
                },
              ),
              ListTile(
                  leading: Icon(Icons.logout),
                  title: Text(
                    "Sign Out",
                    style: TextStyle(fontSize: 20),
                  ),
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => LoginPage(
                              showRegisterPage: () {},
                            )));
                  }),
            ],
          ),
        ),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Enter a PantryBuddy Code to join!',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.green),
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'Code',
                suffixIcon: IconButton(
                    onPressed: () {
                      _textController.clear();
                    },
                    icon: const Icon(Icons.clear)),
                fillColor: Colors.grey[100],
                filled: true,
              ),
            ),
          ),

          // Button
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Column(children: [
              MaterialButton(
                onPressed: () {
                  inputCode = _textController.text;

                  //check if code is in database
                  DatabaseReference getCode = FirebaseDatabase.instance
                      .ref()
                      .child('foodInventories/$inputCode/inventoryId');
                  getCode.onValue.listen((event) {
                    // setState(() {
                    //if code isnt in database
                    place = event.snapshot.value.toString();
                    print("place is " + place);
                    if (place == "null" || place == "0") {
                      print("ERROR CODE NOT VALID!");
                      invalidCodeDialog();
                    }
                    // });
                    //does the user already exist as an user of the foodPantry?
                    String isUser = '0';
                    print("myUserID is " +  myUserID!);
                    // DatabaseReference isUserID = FirebaseDatabase.instance
                    //     .ref()
                    //     .child(
                    //         'foodInventories/$place/users').equalTo("$myUserID").ref;

                    DatabaseReference isUserID = FirebaseDatabase.instance
                    .ref('foodInventories/$place/users')
                    .orderByValue(
                        ).equalTo("$myUserID").ref;
                    isUserID.onValue.listen((event) {
                      // setState(() {
                        isUser = event.snapshot.value.toString();
                      // });
                      print("isUser is " + isUser);
                    });
                  });
                },
                child: Text("Enter"),
                color: Colors.green[400],
              ),
            ]),
          ),
        ],
      )),
    );
  }
}
