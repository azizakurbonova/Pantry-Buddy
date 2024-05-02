//import 'dart:js_interop';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pantrybuddy/auth/auth_page.dart';
import 'package:pantrybuddy/pages/account_page.dart';
import 'package:pantrybuddy/pages/inventory_page.dart';
import 'package:pantrybuddy/pages/notif_page.dart';
import 'package:pantrybuddy/pages/widgets/sidebar.dart';
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
        elevation: 0, // how flat do we want this
        title: Text("Top Bar"),
      ),
      endDrawer: sideBar(context),
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
              //controller: _emailController,
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
                fillColor: Colors.grey[100],
                filled: true,
              ),
            ),
          ),
        ],
      )),
    );
  }
}
