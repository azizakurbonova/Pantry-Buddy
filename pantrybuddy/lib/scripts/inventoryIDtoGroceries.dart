import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pantrybuddy/models/food_inventory.dart';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pantrybuddy/models/grocery_item.dart';
import 'package:pantrybuddy/models/food_inventory.dart';
import 'package:pantrybuddy/widgets/sidebar.dart';

Future<List<GroceryItem>> inventoryIDtoGroceries(
    List<String> groceryIDs) async {
  DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  List<DataSnapshot> grocerySnapshots = [];
  for (int x = 0; x < groceryIDs.length; x++) {
    String id = groceryIDs[x];
    grocerySnapshots.add(await dbRef.child("groceries/$id").get());
  }

  List<GroceryItem> groceries = [];
  for (int x = 0; x < groceryIDs.length; x++) {
    final data = grocerySnapshots[x].value as Map<String, dynamic>;
    GroceryItem grocery = GroceryItem.fromJson(data);
    groceries.add(grocery);
  }
  return groceries;
}
