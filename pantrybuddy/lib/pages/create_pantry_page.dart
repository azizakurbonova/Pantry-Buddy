import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pantrybuddy/models/food_inventory.dart';
import 'package:pantrybuddy/pages/widgets/appbar.dart';
import 'package:pantrybuddy/pages/widgets/sidebar.dart';
import 'package:pantrybuddy/models/grocery_item.dart';

class CreatePantryPage extends StatefulWidget {
  const CreatePantryPage({Key? key}) : super(key: key);

  @override
  State<CreatePantryPage> createState() => _CreatePantryPageState();
}

class _CreatePantryPageState extends State<CreatePantryPage> {
  final user = FirebaseAuth.instance.currentUser!;
  final database = FirebaseDatabase.instance.ref();

  void createPantry() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userId = currentUser.uid;
      String? inventoryID =
          FirebaseDatabase.instance.ref("foodInventories").push().key;
      GroceryItem groceryItem = GroceryItem(
          name: "dummy",
          inventoryID: inventoryID as String,
          category: ['test'],
          dateAdded: DateTime.now(),
          expirationDate: DateTime.now(),
          itemIdType: ItemIdType.MANUAL);

      final pantry = FoodInventory(
        inventoryID: inventoryID,
        owner: userId,
        users: [userId], // Current user is added as owner and user
        groceryItems: [groceryItem],
        consumed: 0,
        discarded: 0,
      );
      final reference =
          FirebaseDatabase.instance.ref().child('foodInventories/$inventoryID');
      reference.set(pantry.toJson());
      final userRef =
          FirebaseDatabase.instance.ref().child('users').child(userId);
      userRef.update({'inventoryID': inventoryID});

      if (currentUser != null) {
        GroceryItem groceryItem = GroceryItem(
            name: "dummy",
            inventoryID: inventoryID as String,
            category: ['test'],
            dateAdded: DateTime.now(),
            expirationDate: DateTime.now(),
            itemIdType: ItemIdType.MANUAL);
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.green[100],
        appBar: ApplicationToolbar(),
        endDrawer: sideBar(context),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: GestureDetector(
                  onTap: () {
                    createPantry();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.purple[400],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('Sign In',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          )),
                    ),
                  ),
                )),
          ],
        )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
