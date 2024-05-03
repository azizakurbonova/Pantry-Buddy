import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
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

enum QuantityType { individuals, bags, boxes, bundles, bottles }

class GroceryItemDescription extends StatelessWidget {
  final GroceryItem item;
  const GroceryItemDescription({required this.item}) : super();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: TextStyle(
                        fontSize: 13.0,
                        color: Color(0xFF2D3447),
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text('Quantity: ${(item.quantity)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13.0, color: Color(0xFF2D3447))),
                Text(
                    '${'Best before:'} ${item.expirationDate.toIso8601String().substring(0, 10)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13.0, color: Color(0xFF2D3447))),
                Text('${'Use in:'} ${daysUntilExpiration(item)} ${'days'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13.0, color: Color(0xFF2D3447))),
              ],
            ))
      ],
    );
  }
}

int daysUntilExpiration(GroceryItem item) {
  return (item.expirationDate.difference(DateTime.now()).inDays + 1);
}
