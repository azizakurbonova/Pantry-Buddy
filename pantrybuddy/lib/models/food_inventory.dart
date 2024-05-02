import 'grocery_item.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';

/*
Example Use of class methods to update firebase

void main() {
  var inventory = FoodInventory(
    inventoryId: '123456',
    owner: 'user123',
  );

  // Example of sharing access
  bool successShare = inventory.shareAccess('user123', 'user456');
  print('Access shared: $successShare');

  // Example of removing access
  bool successRemove = inventory.removeAccess('user123', 'user456');
  print('Access removed: $successRemove');
}

*/


//Includes methods to update the database directly
class FoodInventory {
  String? inventoryId;
  //String? joinCode;
  String
      owner; //user who initialized the food inventory and is the only one that can share access to the inventory with others
  List<String> users = [];
  List<String> groceryItems = [];

  FoodInventory({
    this.inventoryId,
    required this.owner,
    List<dynamic>? groceryItems,
    List<dynamic>? users,
  })  : groceryItems = [owner],
        users = [
          owner
        ]; //owner is implicitly already part of list of users who can view and edit the inventory

  // Methods to add, remove, and view items would go here
  // Add a GroceryItem to the inventory
  void addGroceryItem(String itemId) {
    // Here you might want to check for duplicates before adding
    groceryItems.add(itemId);
  }

  // Remove a GroceryItem from the inventory by itemId
  void removeGroceryItem(String itemId) {
    groceryItems.removeWhere((item) => item == itemId);
  }

  //Retrieve joinCode
  // String? getCode() {
  //   return joinCode;
  // }

  bool shareAccess(String currentUserId, String userToAdd) {
    if (currentUserId == owner) {
      if (!users.contains(userToAdd)) {
        users.add(userToAdd);
        dbRef.child('foodInventories/${this.inventoryId}/users').set(users);
        return true; // Indicate operation success
      } else {
        debugPrint("User already has access.");
        return false;
      }
    } else {
      debugPrint('Only the owner can update the user access list.');
      return false;
    }
  }

  bool removeAccess(String currentUserId, String userToRemove) {
    if (currentUserId == owner) {
      if (users.contains(userToRemove)) {
        users.remove(userToRemove);
        dbRef.child('foodInventories/${this.inventoryId}/users').set(users);
        return true; // Indicate operation success
      } else {
        debugPrint("User does not exist among existing list of people with access.");
        return false;
      }
    } else {
      debugPrint('Only the owner can update the user access list.');
      return false;
    }
  }

  Future<FoodInventory?> viewInventory() async {
    DataSnapshot snapshot = await dbRef.child('foodInventories/${this.inventoryId}').get();
    if (snapshot.exists) {
      return FoodInventory.fromJson(Map<String, dynamic>.from(snapshot.value as Map));
    }
    return null;
  }
/*
  // Static method to create a FoodInventory object from a JSON map
  static FoodInventory fromJson(Map<String, dynamic> json) {
    return FoodInventory(
      inventoryId: json['inventoryId'],
      owner: json['owner'],
      groceryItems: (json['groceryItems'] as List).map((item) => GroceryItem.fromJson(item)).toList(),
      users: List<String>.from(json['users']),
    );
  }
*/

  Map<String, dynamic> toJson() {
    return {
      'inventoryId': inventoryId,
      'owner': owner,
      'users': users,
      'groceryItems': groceryItems,
    };
  }

  static FoodInventory fromJson(Map<String, dynamic> json) {
    return FoodInventory(
      inventoryId: json['inventoryId'],
      owner: json['owner'],
      users: json['users'],
      groceryItems: json['groceryItems'],
    );
  }
}
