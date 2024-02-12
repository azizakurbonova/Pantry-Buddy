import 'grocery_item.dart';
import 'package:flutter/foundation.dart';

class FoodInventory {
  String inventoryId;
  String owner; //user who initialized the food inventory and is the only one that can share access to the inventory with others
  List<String> users;
  List<GroceryItem> groceryItems;

FoodInventory({
    required this.inventoryId,
    required this.owner,
    List<GroceryItem>? groceryItems,
    List<String>? users,
  })  : groceryItems = groceryItems ?? [],
        users = users ?? [owner]; //owner is implicitly already part of list of users who can view and edit the inventory

  // Methods to add, remove, and view items would go here
  // Add a GroceryItem to the inventory
  void addGroceryItem(GroceryItem item) {
    // Here you might want to check for duplicates before adding
    groceryItems.add(item);
  }

  // Remove a GroceryItem from the inventory by itemId
  void removeGroceryItem(String itemId) {
    groceryItems.removeWhere((item) => item.itemId == itemId);
  }

  // Get a view of the inventory
  List<GroceryItem> viewInventory() {
    return groceryItems;
  }

  bool shareAccess(String currentUserId, String userToAdd){
    if (currentUserId == owner) {
      if (!users.contains(userToAdd)){
        users.add(userToAdd);
        return true; //indicate operation success
      }
      else{
        debugPrint("User already has access");
        return false;
      }
    }
    else {
      debugPrint('Only the owner can update the user access list.');
      return false;
    }
  }

  bool removeAccess(String currentUserId, String userToRemove){
    if (currentUserId == owner) {
      if (!users.contains(userToRemove)){
        users.remove(userToRemove);
        return true; //indicate operation success
      }
      else{
        debugPrint("User does not exist among existing list of people with access");
        return false;
      }
    }
    else {
      debugPrint('Only the owner can update the user access list.');
      return false;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'inventoryId': inventoryId,
      'owner': owner,
      'users': users,
      'groceryItems': groceryItems.map((item) => item.toJson()).toList(),
    };
  }

  static FoodInventory fromJson(Map<String, dynamic> json) {
    return FoodInventory(
      inventoryId: json['inventoryId'],
      owner: json['owner'],
      users: List<String>.from(json['users']),
      groceryItems: (json['groceryItems'] as List)
          .map((itemJson) => GroceryItem.fromJson(itemJson))
          .toList(),
    );
  }
}
