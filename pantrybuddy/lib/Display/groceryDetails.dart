import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pantrybuddy/Display/groceryNameField.dart';
import 'package:pantrybuddy/Display/groceryQuantityField.dart';
import 'package:pantrybuddy/models/food_inventory.dart';
import 'package:pantrybuddy/pages/Inventory_page.dart';
<<<<<<< HEAD
=======
import 'package:pantrybuddy/pages/account_page.dart';
import 'package:pantrybuddy/pages/manual_add_page.dart';
import 'package:pantrybuddy/pages/dc_inventory_page.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
>>>>>>> 65a911b4d274c56dc357ccfd7b94507dd0d347aa
import 'package:pantrybuddy/pages/tools/getFoodInventory.dart';
import 'package:pantrybuddy/pages/tools/getPantryID.dart';

import 'package:pantrybuddy/models/grocery_item.dart';
import 'dart:developer';

class ItemDetails extends StatefulWidget {
  final GroceryItem item;
  final int index;
  ItemDetails({required this.item, required this.index}) : super();

  @override
  _FoodDetailsState createState() => _FoodDetailsState();
}

class _FoodDetailsState extends State<ItemDetails> {
  final dbRef = FirebaseDatabase.instance.ref();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.item.name;
    _quantityController.text = widget.item.quantity.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF2D3447),
        appBar: AppBar(
            title: const Text('Item Details',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.0,
                    fontWeight: FontWeight.w100)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.info, color: Colors.white),
                onPressed: () {},
              )
            ]),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text("Name:",
                  style: TextStyle(fontSize: 25.0, color: Colors.white)),
              GroceryNameField(
                nameController: _nameController,
              ),
              const Divider(),
              const Text(
                'Quantity:',
                style: TextStyle(fontSize: 25.0, color: Colors.white),
              ),
              GroceryQuantityField(quantityController: _quantityController),
              Divider(),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      log("PRESSED");
                      final uid = FirebaseAuth.instance.currentUser!.uid;
                      String inventoryID = await fetchPantryID();
                      DataSnapshot dbsnapshot = await dbRef
                          .child("foodInventories/$inventoryID")
                          .get();

                      Map<String, dynamic> jsonData = {};
                      for (var item in dbsnapshot.children) {
                        log("TRYING TO TRANSLATE: ${item.key.toString()}->${item.value.toString()}");
                        jsonData[item.key.toString()] = item.value;
                      }
                      List<dynamic> groceryJsons = [];
                      for (var map in jsonData["groceryItems"]) {
                        Map<String, dynamic> groceryJson = {};
                        for (var key in map.keys) {
                          log("translating: ${key.toString()}->${map[key].toString()}");
                          groceryJson[key.toString()] = map[key];
                        }
                        groceryJsons.add(groceryJson);
                      }
                      jsonData["groceryItems"] = groceryJsons;
                      FoodInventory pantry = FoodInventory.fromJson(jsonData);

                      pantry.groceryItems[widget.index].quantity =
                          int.parse(_quantityController.text);
                      pantry.groceryItems[widget.index].name =
                          _nameController.text;
                      dbRef
                          .child("foodInventories/$inventoryID")
                          .update(pantry.toJson());

                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) {
                        return InventoryPage();
                      }));
                    },
                    child: const Text('Save'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      FoodInventory pantry = await fetchPantry();
                      log("zzz" + pantry.groceryItems.length.toString());
                      for (int x = 0; x < pantry.groceryItems.length; x++) {
                        if (pantry.groceryItems[x].itemId ==
                            widget.item.itemId) {
                          pantry.groceryItems.removeAt(x);
                          break;
                        }
                      }
                      log("zzz" + pantry.groceryItems.length.toString());
                      String inventoryID = pantry.inventoryId as String;
                      dbRef
                          .child("foodInventories/$inventoryID/")
                          .update(pantry.toJson());
                      pantry = await fetchPantry();
                      log("zzz" + pantry.groceryItems.length.toString());
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) {
                        return InventoryPage();
                      }));
                    },
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ]),
          ),
        ));
  }
}
