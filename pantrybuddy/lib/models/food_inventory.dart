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
  String
      owner; //user who initialized the food inventory and is the only one that can share access to the inventory with others
  List<String> users;
  List<GroceryItem> groceryItems;

  FoodInventory({
    this.inventoryId,
    required this.owner,
    List<GroceryItem>? groceryItems,
    List<String>? users,
  })  : groceryItems = groceryItems ?? [],
        users = users ?? [owner];

  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();

  // Adds a grocery item to the Firebase database
  void addGroceryItem(GroceryItem item) {
    if (!groceryItems
        .any((existingItem) => existingItem.itemId == item.itemId)) {
      groceryItems.add(item);
      dbRef
          .child('foodInventories/${this.inventoryId}/groceryItems')
          .push()
          .set(item.toJson());
      //each push() generates a unique identifier and ensures that the new data is added as a new child under the list.
    }
  }

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
        debugPrint(
            "User does not exist among existing list of people with access.");
        return false;
      }
    } else {
      debugPrint('Only the owner can update the user access list.');
      return false;
    }
  }

  Future<FoodInventory?> viewInventory() async {
    DataSnapshot snapshot =
        await dbRef.child('foodInventories/${this.inventoryId}').get();
    if (snapshot.exists) {
      return FoodInventory.fromJson(
          Map<String, dynamic>.from(snapshot.value as Map));
    }
    return null;
  }

  // Static method to create a FoodInventory object from a JSON map
  static FoodInventory fromJson(Map<String, dynamic> json) {
    return FoodInventory(
      inventoryId: json['inventoryId'],
      owner: json['owner'],
      groceryItems: (json['groceryItems'] as List)
          .map((item) => GroceryItem.fromJson(item))
          .toList(),
      users: List<String>.from(json['users']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inventoryId': inventoryId,
      'owner': owner,
      'users': users,
      'groceryItems': groceryItems.map((item) => item.toJson()).toList(),
    };
  }
}
