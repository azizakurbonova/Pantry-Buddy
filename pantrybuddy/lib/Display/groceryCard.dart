import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pantrybuddy/Display/groceryDetails.dart';
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
import 'package:pantrybuddy/Display/groceryDescription.dart';

class GroceryCard extends StatelessWidget {
  final GroceryItem item;
  final int index;
  GroceryCard({required this.item, required this.index}) : super();
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        child: Card(
          color: daysUntilExpiration(item) < 0 ? Colors.red[200] : Colors.white,
          child: InkWell(
            child: Container(
                height: 90,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          //child: Container(
                          //  child: Image(
                          //      image:
                          //          AssetImage('assets/images/groceries.png'),
                          //      height: 50.0),
                          //),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(left: 30.0),
                          child: GroceryItemDescription(item: item))
                    ],
                  ),
                )),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ItemDetails(item: item, index: index)));
            },
          ),
        ));
  }
}
