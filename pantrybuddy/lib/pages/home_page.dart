//import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pantrybuddy/models/food_inventory.dart';
import 'package:pantrybuddy/models/grocery_item.dart';
import 'package:pantrybuddy/models/user.dart' as my_user;
import 'package:pantrybuddy/pages/account_page.dart';
import 'package:pantrybuddy/pages/inventory_page.dart';
import 'package:pantrybuddy/pages/notif_page.dart';
import 'package:pantrybuddy/pages/create_pantry_page.dart';
import 'package:pantrybuddy/pages/join_pantry_page.dart';
import 'package:pantrybuddy/pages/tools/getPantryID.dart';
import 'package:pantrybuddy/pages/widgets/sidebar.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);
  bool hasInventory = false;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  // need to pass this field around
  String? newInventoryID =
      FirebaseDatabase.instance.ref("foodInventories").push().key;

  void createPantry() async {
    //DatabaseReference ref = FirebaseDatabase.instance.ref("foodInventories");
    String myUser = user.uid;

    // this code reads only once.
    //final readCode = FirebaseDatabase.instance.ref();
    //final snapshot = await readCode.child('users/$myUser/joinCode').get();

    String? inventoryId = newInventoryID;
    GroceryItem groceryItem = GroceryItem(
        name: "dummy",
        category: ['test'],
        dateAdded: DateTime.now(),
        expirationDate: DateTime.now(),
        itemIdType: ItemIdType.MANUAL);
    FoodInventory newInventory = FoodInventory(
      inventoryId: inventoryId,
      owner: user.uid,
      users: [user.uid],
      groceryItems: [groceryItem],
    );

    // User newUser = User(

    // );

    await FirebaseDatabase.instance
        .ref("foodInventories/$inventoryId")
        .set(newInventory.toJson());

    await FirebaseDatabase.instance.ref("users/$myUser").update({
      "inventoryID": inventoryId,
    });
  }

  Future hasInventory() async {
    String inventoryID = await fetchPantryID();
    if (inventoryID == "Null") {
      widget.hasInventory = false;
    } else {
      widget.hasInventory = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: hasInventory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (widget.hasInventory) {
              return InventoryPage();
            } else {
              return Scaffold(
                  backgroundColor: Colors.green[100],
                  appBar: AppBar(
                    backgroundColor: Colors.green[400],
                    elevation: 0, // how flat do we want this
                    //title: Text("Top Bar"),
                  ),
                  endDrawer: sideBar(context),
                  body: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              height: 300,
                              width: 300,
                              child: Image.asset('lib/images/fridgey.png')),
                          Padding(
                            padding: EdgeInsets.only(top: 25),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                //Padding(padding: EdgeInsets.only(left: 10)),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[800],
                                  ),
                                  onPressed: () async {
                                    createPantry();

                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                InventoryPage()));
                                  },
                                  child: Text(
                                    "Create Pantry",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                SizedBox(width: 10),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[800],
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                JoinPantryPage()));
                                  },
                                  child: Text(
                                    "Join Pantry",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                //ElevatedButton(
                                //  style: ElevatedButton.styleFrom(
                                //    backgroundColor: Colors.green[800],
                                //  ),
                                //  onPressed: () async {
                                //    try {
                                //      String userID = user.uid;
                                //      // String? newInventoryID = FirebaseDatabase.instance
                                //      //     .ref("foodInventories")
                                //      //     .push()
                                //      //     .key;
                                //      // Here, you create a map or use your User model to represent user data
                                //      Map<String, dynamic> userData = {
                                //        "userId": user.uid,
                                //        "email": user.email,
                                //        "inventoryID": "Null",
                                //      };
                                //      // Update the Realtime Database with the new user's information
                                //      await FirebaseDatabase.instance
                                //          .ref("users/$userID")
                                //          .set(userData);
//
                                //      print("stuff has been written!");
                                //    } catch (e) {
                                //      print('youve got error $e');
                                //    }
                                //  },
                                //  child: Text(
                                //    "Create User (for testing)",
                                //    style: TextStyle(color: Colors.white),
                                //  ),
                                //),
                              ],
                            ),
                          )
                        ]),
                  ));
            }
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}
