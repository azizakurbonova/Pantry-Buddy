import 'package:flutter/material.dart';
import 'package:pantrybuddy/Display/groceryCard.dart';
import 'package:pantrybuddy/models/grocery_item.dart';
import 'dart:developer';

class GroceryList extends StatelessWidget {
  List<GroceryItem> groceries;

  GroceryList({required this.groceries}) : super();
  @override
  Widget build(BuildContext context) {
    if (groceries.isEmpty) {
      //Change this to 1 when running live
      return const Text('No food items');
    }
    //log("sub-groceries length ${groceries.length.toString()}");
    return SafeArea(
      child: Column(
        children: [
          Expanded(
              child: ListView.builder(
            shrinkWrap: true,
            itemCount: groceries.length,
            itemBuilder: (BuildContext context, int index) =>
                GroceryCard(item: groceries[index], index: index),
          )),
        ],
      ),
    );
  }
}
