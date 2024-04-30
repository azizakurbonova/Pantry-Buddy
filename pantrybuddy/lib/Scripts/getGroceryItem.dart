import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pantrybuddy/models/food_inventory.dart';
import 'package:pantrybuddy/models/grocery_item.dart';

Future<List<GroceryItem>> getGroceries(List<String> itemIDs) async {
  List<GroceryItem> groceries = [];
  bool first = true;
  for (String ID in itemIDs) {
    if (first) {
      first = false;
      continue;
    } else {
      groceries.add(await getGroceryItem(ID));
    }
  }
  return groceries;
}

Future<GroceryItem> getGroceryItem(String itemID) async {
  DataSnapshot dataSnapshot =
      await FirebaseDatabase.instance.ref("groceryItems/$itemID").get();

  Map<String, dynamic> jsonData = {};
  List<dynamic> listData = [];
  bool first = true;
  for (final value in dataSnapshot.children) {
    if (first) {
      first = false;
      continue;
    } else {
      listData.add(value.value);
    }
  }
  jsonData["category"] = listData[0];
  jsonData["expirationDate"] = listData[1];
  jsonData["itemIdType"] = listData[2];
  jsonData["name"] = listData[3];
  jsonData["quantity"] = listData[4];
  jsonData['itemId'] = listData[5];

  GroceryItem grocery = GroceryItem.fromJson(jsonData);
  return grocery;
}
