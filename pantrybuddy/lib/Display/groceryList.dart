import 'package:flutter/material.dart';
import 'package:pantrybuddy/Display/groceryCard.dart';
import 'package:pantrybuddy/models/grocery_item.dart';
import 'dart:developer';

class GroceryList extends StatelessWidget {
  List<GroceryItem> groceries;
  TextEditingController _searchController = TextEditingController();

  GroceryList({required this.groceries}) : super();
  @override
  Widget build(BuildContext context) {
    if (groceries.isEmpty) {
      //Change this to 1 when running live
      return const Text('No food items');
    }
    _searchController.text = "";
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

List<GroceryItem> filterByName(List<GroceryItem> groceries, String name) {
  log("FILTERING!!!!!");
  List<GroceryItem> filteredList = [];
  for (int x = 0; x < groceries.length; x++) {
    if (groceries[x].name.contains(name)) {
      filteredList.add(groceries[x]);
    }
  }
  return filteredList;
}
