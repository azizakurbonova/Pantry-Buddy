import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pantrybuddy/models/food_inventory.dart';
import 'package:pantrybuddy/pages/tools/getPantryID.dart';
import 'dart:developer';

Future<FoodInventory> fetchPantry() async {
  DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  String inventoryID = await fetchPantryID();
  DataSnapshot dbsnapshot =
      await dbRef.child("foodInventories/$inventoryID").get();

  if (!dbsnapshot.exists || inventoryID == "Null") {
    // Return null if the pantry does not exist in the database
    return FoodInventory(owner: "Null");
  }

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
  FoodInventory pantry = FoodInventory.fromJson(jsonData);
  return pantry;
}
