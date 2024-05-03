import 'package:flutter/material.dart';
import 'package:pantrybuddy/Display/groceryCard.dart';
import 'package:pantrybuddy/models/grocery_item.dart';

class GroceryList extends StatelessWidget {
  List<GroceryItem> groceries;
  String filter;

  GroceryList({required this.groceries, required this.filter}) : super();
  @override
  Widget build(BuildContext context) {
    if (groceries.isEmpty) {
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
