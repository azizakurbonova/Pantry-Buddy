import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
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

  String code = 'n/a';

  // this function should check if a code the user inputted(?) exists in the database
  void getPantryCode(String input) {
    String place = '0';
    final getCode = FirebaseDatabase.instance
        .ref()
        .child('foodInventories')
        .orderByChild('joinCode')
        .equalTo(input)
        .ref
        .child("joinCode");
    //print("getCode" + getCode);
    //print("getCode: " + getCode.toString());
    getCode.onValue.listen((event) {
      setState(() {
        place = event.snapshot.value.toString();
        print("place: " + place);
      });
    });
    // if (place == input) {
    //   print("CODE WAS A MATCH!!!: place: $place");
    // } else {
    //   print("NO MATCH!! place: $place");
    // }
  }

  // this function should add the user to a pantry
  void addUserToPantry() {}

  @override
  Widget build(BuildContext context) {
    DatabaseReference getCode =
        FirebaseDatabase.instance.ref().child('users/$myUserID/joinCode');
    getCode.onValue.listen((event) {
      setState(() {
        code = event.snapshot.value.toString();
      });
    });

    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        backgroundColor: Colors.green[400],
        elevation: 0, // how flat do we want this
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

            // test field
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
                  getPantryCode(_textController.text);
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
