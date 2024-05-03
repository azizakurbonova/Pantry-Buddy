import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pantrybuddy/pages/account_page.dart';
import 'package:pantrybuddy/pages/inventory_page.dart';
import 'package:pantrybuddy/pages/dc_inventory_page.dart';
import 'package:pantrybuddy/pages/widgets/appbar.dart';
import 'package:pantrybuddy/reg/login_page.dart';
import 'package:pantrybuddy/pages/widgets/sidebar.dart';
import 'package:path/path.dart';

//import 'package:pantrybuddy/pages/join_pantry_page.dart';

class CreatePantryPage extends StatefulWidget {
  const CreatePantryPage({Key? key}) : super(key: key);

  @override
  State<CreatePantryPage> createState() => _CreatePantryPageState();
}

class _CreatePantryPageState extends State<CreatePantryPage> {
  final user = FirebaseAuth.instance.currentUser!;
  final database = FirebaseDatabase.instance.ref();

  //String userID = user.uid.toString();

  @override
  Widget build(BuildContext context) {
    //final pantry = database.child('pantry');

    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: ApplicationToolbar(),
      endDrawer: sideBar(context),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Your pantry code is: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
        ],
      )),
    );
  }
}
