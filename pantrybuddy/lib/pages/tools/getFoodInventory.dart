import 'dart:developer';
import 'package:firebase_database/firebase_database.dart';
import 'package:pantrybuddy/models/food_inventory.dart';
import 'package:pantrybuddy/pages/tools/getPantryID.dart';

// This PROBABLY NEEDS FIXING! Please let me (CHRIS) know if there's an error
Future<FoodInventory> fetchPantry() async {
  String inventoryID = await fetchPantryID();
  DataSnapshot dataSnapshot =
      await FirebaseDatabase.instance.ref("foodInventories/$inventoryID").get();
  Map<String, dynamic> jsonData = {};
  List<dynamic> listData = [];
  for (final value in dataSnapshot.children) {
    listData.add(value.value);
    log(value.value.toString());
  }
  jsonData["inventoryId"] = listData[1];
  jsonData["owner"] = listData[2];
  jsonData["users"] = listData[3];
  for (int x = 0; x < jsonData["users"].length; x++) {
    jsonData["users"][x] = jsonData["users"][x].toString();
  }
  jsonData["groceryItems"] = listData[0];
  FoodInventory pantry = FoodInventory.fromJson(jsonData);
  return pantry;
}

Future<FoodInventory> fetchPantry2() async {
  String inventoryID = await fetchPantryID();
  DataSnapshot dataSnapshot =
      await FirebaseDatabase.instance.ref("foodInventories/$inventoryID").get();

  Map<String, dynamic> jsonData = {};
  for (final value in dataSnapshot.children) {
    log(value.toString());
  }
  return FoodInventory(owner: "1312312313");
}
