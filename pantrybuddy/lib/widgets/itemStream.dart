import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pantrybuddy/models/grocery_item.dart';
import 'package:pantrybuddy/models/food_inventory.dart';
import 'package:pantrybuddy/scripts/fetchUserInventory.dart';
import 'package:pantrybuddy/widgets/sidebar.dart';
import 'package:pantrybuddy/scripts/fetchGroceryItems.dart';

const PANTRY_LOCATION_ID = 'Pantry';
const REFRIGERATOR_LOCATION_ID = 'Refrigerator';
const FREEZER_LOCATION_ID = 'Freezer';

Stream<List<String>> getUserLocationFoodsStream(
    BuildContext context, location) async* {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  FoodInventory pantry = await fetchUserInventory();
}
