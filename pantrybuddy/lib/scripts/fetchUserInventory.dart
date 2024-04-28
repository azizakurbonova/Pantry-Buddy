import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pantrybuddy/models/food_inventory.dart';

Future<FoodInventory> fetchUserInventory() async {
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  final user = FirebaseAuth.instance.currentUser!;
  String userId = user.uid;
  final snapshot =
      await FirebaseDatabase.instance.ref("users/$userId/inventoryID").get();
  final inventoryID = snapshot.value.toString();
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
  for (int x = 0; x < jsonData["groceryItems"].length; x++) {
    jsonData["groceryItems"][x] = jsonData["groceryItems"][x].toString();
  }
  FoodInventory pantry = FoodInventory.fromJson(jsonData);
  log(pantry.groceryItems.toString());
  return pantry;
}
