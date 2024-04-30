import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pantrybuddy/Scripts/fetchInventoryID.dart';
import 'package:pantrybuddy/models/grocery_item.dart';
import 'package:pantrybuddy/pages/account_page.dart';
import 'package:pantrybuddy/pages/notif_page.dart';
import 'package:pantrybuddy/pages/inventory_page.dart';
import 'package:pantrybuddy/models/food_inventory.dart';
import 'package:pantrybuddy/Scripts/fetchFoodInventory.dart';
import 'package:pantrybuddy/widgets/sidebar.dart';

Stream<DataSnapshot> getGroceryListStream(BuildContext context) async* {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final inventoryID = fetchInventoryID();
  yield* FirebaseDatabase.instance
      .ref()
      .child("foodInventories/$inventoryID/groceryItems")
      .onValue
      .map((event) => event.snapshot);
}
