import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pantrybuddy/Display/groceryList.dart';
import 'package:pantrybuddy/models/food_inventory.dart';
import 'package:pantrybuddy/pages/account_page.dart';
import 'package:pantrybuddy/pages/manual_add_page.dart';
import 'package:pantrybuddy/pages/dc_inventory_page.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:pantrybuddy/pages/tools/getFoodInventory.dart';
import 'package:pantrybuddy/pages/tools/getPantryID.dart';
import 'package:pantrybuddy/pages/widgets/sidebar.dart';
import 'package:pantrybuddy/models/grocery_item.dart';
import 'dart:developer';

Future<FoodInventory> fetchPantry() async {
  DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  final uid = FirebaseAuth.instance.currentUser!.uid;
  String inventoryID = await fetchPantryID();
  DataSnapshot dbsnapshot =
      await dbRef.child("foodInventories/$inventoryID").get();

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
  return pantry;
}
