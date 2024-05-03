import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pantrybuddy/Display/groceryCard.dart';
import 'package:pantrybuddy/models/food_inventory.dart';
import 'package:pantrybuddy/pages/account_page.dart';
import 'package:pantrybuddy/pages/manual_add_page.dart';
import 'package:pantrybuddy/pages/notif_page.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:pantrybuddy/pages/tools/getFoodInventory.dart';
import 'package:pantrybuddy/pages/tools/getPantryID.dart';
import 'package:pantrybuddy/pages/widgets/sidebar.dart';
import 'package:pantrybuddy/models/grocery_item.dart';
import 'dart:developer';

class GroceryList extends StatelessWidget {
  List<GroceryItem> groceries;

  GroceryList({required this.groceries}) : super();
  @override
  Widget build(BuildContext context) {
    if (groceries.length <= 0) {
      //Change this to 1 when running live
      return const Text('No food items');
    }
    return ListView.builder(
      shrinkWrap: true,
      itemCount: groceries.length,
      itemBuilder: (BuildContext context, int index) =>
          GroceryCard(item: groceries[index], index: index),
    );
  }
}
