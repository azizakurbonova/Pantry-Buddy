import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pantrybuddy/models/food_inventory.dart';
import 'package:pantrybuddy/models/grocery_item.dart';

Future<List<GroceryItem>> fetchGroceryItems(FoodInventory foodInventory) async {
  FoodInventory pantry = foodInventory;
  List<String> groceries = pantry.groceryItems;
  List<GroceryItem> groceriesList = [];
  for (String id in groceries) {
    final snapshot =
        await FirebaseDatabase.instance.ref("groceryItems/$id").get();
    Map<String, dynamic> jsonData = {};
    List<dynamic> listData = [];
    for (final value in snapshot.children) {
      listData.add(value.value);
    }
    jsonData["category"] = listData[0];
    jsonData["expirationDate"] = listData[1];
    jsonData["itemIdType"] = listData[2];
    jsonData["name"] = listData[3];
    jsonData["quantity"] = listData[4];
    GroceryItem grocery = GroceryItem.fromJson(jsonData);
    groceriesList.add(grocery);
  }
  return groceriesList;
}
