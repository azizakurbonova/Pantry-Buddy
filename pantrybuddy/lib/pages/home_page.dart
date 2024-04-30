//import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pantrybuddy/Scripts/fetchFoodInventory.dart';
import 'package:pantrybuddy/Scripts/getGroceryItem.dart';
import 'package:pantrybuddy/models/food_inventory.dart';
import 'package:pantrybuddy/pages/inventory_page.dart';
import 'package:pantrybuddy/pages/join_pantry_page.dart';
import 'package:pantrybuddy/widgets/sidebar.dart';
<<<<<<< Updated upstream
=======
import 'package:uuid/uuid.dart';
import 'package:pantrybuddy/Scripts/getGroceryItem.dart';
>>>>>>> Stashed changes

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

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

    FoodInventory newInventory = FoodInventory(
      inventoryId: inventoryId,
      owner: user.uid,
      users: [user.uid],
      groceryItems: [user.uid],
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

  Future<List<GroceryItem>> getGroceryList() async {
    List<String> FoodIDs = (await fetchUserInventory()).groceryItems;
    return getGroceries(FoodIDs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.green[100],
        appBar: AppBar(
          backgroundColor: Colors.green[400],
          elevation: 0, // how flat do we want this
          //title: Text("Top Bar"),
        ),
<<<<<<< Updated upstream
        endDrawer: sideBar(context),
=======
        endDrawer: sidebar(context),
>>>>>>> Stashed changes
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
                height: 300,
                width: 300,
                child: Image.asset('lib/images/fridgey.png')),
            Padding(
              padding: const EdgeInsets.only(top: 25),
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

                      Navigator.of(context).push(MaterialPageRoute(
<<<<<<< Updated upstream
                          builder: (context) => const InventoryPage()));
=======
                          builder: (context) => InventoryPage(null)));
>>>>>>> Stashed changes
                    },
                    child: const Text(
                      "Create Pantry",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[800],
                    ),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => JoinPantryPage()));
                    },
                    child: const Text(
                      "Join Pantry",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[800],
                    ),
                    onPressed: () async {
                      try {
                        String userID = user.uid;
                        // String? newInventoryID = FirebaseDatabase.instance
                        //     .ref("foodInventories")
                        //     .push()
                        //     .key;
                        // Here, you create a map or use your User model to represent user data
                        Map<String, dynamic> userData = {
                          "userId": user.uid,
                          "email": user.email,
                          "inventoryID": "Null",
                        };
                        // Update the Realtime Database with the new user's information
                        await FirebaseDatabase.instance
                            .ref("users/$userID")
                            .set(userData);
                      } catch (e) {
                        print(e);
                      }
                    },
                    child: const Text(
                      "Create User (for testing)",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          ]),
        ));
  }
}
