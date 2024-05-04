import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pantrybuddy/Display/groceryNameField.dart';
import 'package:pantrybuddy/Display/groceryQuantityField.dart';
import 'package:pantrybuddy/models/food_inventory.dart';
import 'package:pantrybuddy/pages/Inventory_page.dart';
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

  int getIndex(List<GroceryItem> groceries, GroceryItem item) {
    for (int x = 0; x < groceries.length; x++) {
      if (item.dateAdded.toIso8601String() ==
          groceries[x].dateAdded.toIso8601String()) {
        return x;
      }
    }
    return -1;
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
          //actions: [
          //  IconButton(
          //    icon: const Icon(Icons.info, color: Colors.white),
          //    onPressed: () {},
          //  )
          //]
        ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          //log("PRESSED");
                          String inventoryID = await fetchPantryID();
                          DataSnapshot dbsnapshot = await dbRef
                              .child("foodInventories/$inventoryID")
                              .get();

                          Map<String, dynamic> jsonData = {};
                          for (var item in dbsnapshot.children) {
                            //log("TRYING TO TRANSLATE: ${item.key.toString()}->${item.value.toString()}");
                            jsonData[item.key.toString()] = item.value;
                          }
                          List<dynamic> groceryJsons = [];
                          for (var map in jsonData["groceryItems"]) {
                            Map<String, dynamic> groceryJson = {};
                            for (var key in map.keys) {
                              //log("translating: ${key.toString()}->${map[key].toString()}");
                              groceryJson[key.toString()] = map[key];
                            }
                            groceryJsons.add(groceryJson);
                          }
                          jsonData["groceryItems"] = groceryJsons;
                          FoodInventory pantry =
                              FoodInventory.fromJson(jsonData);
                          pantry
                              .groceryItems[
                                  getIndex(pantry.groceryItems, widget.item)]
                              .quantity = int.parse(_quantityController.text);
                          pantry
                              .groceryItems[
                                  getIndex(pantry.groceryItems, widget.item)]
                              .name = _nameController.text;
                          dbRef
                              .child("foodInventories/$inventoryID")
                              .set(pantry.toJson());

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
                          for (int x = 0; x < pantry.groceryItems.length; x++) {
                            if (pantry.groceryItems[x].itemId ==
                                widget.item.itemId) {
                              log("Want to delete: " +
                                  widget.item.name.toString());
                              log("Deleting: " + pantry.groceryItems[x].name);
                              pantry.groceryItems.removeAt(x);
                              break;
                            }
                          }
                          String inventoryID = pantry.inventoryId as String;
                          dbRef
                              .child("foodInventories/$inventoryID/")
                              .set(pantry.toJson());
                          pantry = await fetchPantry();
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) {
                            return InventoryPage();
                          }));
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      FoodInventory pantry = await fetchPantry();
                      for (int x = 0; x < pantry.groceryItems.length; x++) {
                        if (pantry.groceryItems[x].itemId ==
                            widget.item.itemId) {
                          pantry.discarded += pantry.groceryItems[x].quantity;
                          pantry.groceryItems.removeAt(x);
                          break;
                        }
                      }
                      String inventoryID = pantry.inventoryId as String;
                      dbRef
                          .child("foodInventories/$inventoryID/")
                          .set(pantry.toJson());
                      pantry = await fetchPantry();
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) {
                        return InventoryPage();
                      }));
                    },
                    child: const Text('Mark as Discarded'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      FoodInventory pantry = await fetchPantry();
                      for (int x = 0; x < pantry.groceryItems.length; x++) {
                        if (pantry.groceryItems[x].itemId ==
                            widget.item.itemId) {
                          pantry.consumed += pantry.groceryItems[x].quantity;
                          pantry.groceryItems.removeAt(x);
                          break;
                        }
                      }
                      String inventoryID = pantry.inventoryId as String;
                      dbRef
                          .child("foodInventories/$inventoryID/")
                          .set(pantry.toJson());
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) {
                        return InventoryPage();
                      }));
                    },
                    child: const Text('Mark as Consumed'),
                  )
                ],
              ),
            ]),
          ),
        ));
  }
}
