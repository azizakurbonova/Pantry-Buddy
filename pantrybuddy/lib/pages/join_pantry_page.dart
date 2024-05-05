import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pantrybuddy/models/food_inventory.dart';
import 'package:pantrybuddy/pages/inventory_page.dart';
import 'package:pantrybuddy/pages/tools/getFoodInventory.dart';
import 'package:pantrybuddy/pages/widgets/sidebar.dart';
//import 'package:pantrybuddy/pages/join_pantry_page.dart';

class JoinPantryPage extends StatefulWidget {
  const JoinPantryPage({Key? key}) : super(key: key);

  @override
  State<JoinPantryPage> createState() => _JoinPantryPageState();
}

class _JoinPantryPageState extends State<JoinPantryPage> {
  final _textController = TextEditingController();

  // this function should add the user to a pantry
  void addUserToPantry(String pantryCode) async {
    final database = FirebaseDatabase.instance.ref();
    final currentUser = FirebaseAuth.instance.currentUser!;
    final userId = currentUser.uid;

    //add inventoryID to User
    final userRef = FirebaseDatabase.instance.ref().child('users').child(userId);
    userRef.update({'inventoryID': pantryCode});

    //add user to list of users in FoodInventory
    FoodInventory pantry = await fetchPantry();
    //pantry.appendUser(userId);
    List<String> users = pantry.users;
    int newIndex = users.length;
    database.child('foodInventories/$pantryCode/users').child(newIndex.toString()).set(userId);

    //await database.child('foodInventories/$pantryCode/users').push().set(userId);
    /*
    var snapshot = await database.child('pantries').child(pantryCode).once();
    if (snapshot.value != null) {
      database.child('pantries').child(pantryCode).child('users').push().set(pantryCode);
    }
    */
    
  }

/*
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
*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        backgroundColor: Colors.green[400],
        elevation: 0, // how flat do we want this
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
          const SizedBox(height: 25),

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
                fillColor: Colors.grey[100],
                filled: true,
              ),
            ),
          ),
          const SizedBox(height: 25),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: GestureDetector(
            onTap: () {
              print("Button tapped!");
              String inputCode = _textController.text;
              addUserToPantry(inputCode);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return InventoryPage();
                  },
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                color: Colors.purple[400],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('Join Pantry',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  )),
              ),
            ),
          )),
          const SizedBox(height: 25),
        ],
      )),
    );
  }
}
