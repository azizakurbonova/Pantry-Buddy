import 'package:flutter/material.dart';

enum ItemIdType { EAN, UPC, PLU, Manual }

class GroceryItem {
  String itemId;
  String name;
  String category;
  int quantity;
  DateTime dateAdded;
  DateTime? dateConsumed; 
  DateTime? dateDiscarded;
  DateTime expirationDate;
  String? nutriScore;
  String? ecoScore;
  ItemIdType
      itemIdType; // Assuming this is a String that can be either 'EAN', 'UPC', or 'PLU', or 'Manual'
  String? nutritionalInfo;
  bool visible; //distinguishes whether this food item is not discarded or consumed / is displayed as part of the current food inventory

  //Need to enforce that itemIdType has to be either "EAN","UPC","PLU", or "Manual"
  GroceryItem({
    required this.itemId,
    required this.name,
    required this.category,
    this.quantity = 1,
    required this.expirationDate,
    required this.dateAdded, //dateTime of class object instantiation
    this.dateConsumed, //to be populated upon removal of grocery item from food inventory
    this.dateDiscarded, //to be populated upon removal of grocery item from food inventory
    this.nutriScore, //optional, only for products from the Open Food Facts DB
    this.ecoScore, //optional, only for products from the Open Food Facts DB
    required this.itemIdType,
    this.nutritionalInfo, //optional, only for products from the Open Food Facts DB
    this.visible = true
  });

  // Method to display nutritional score
  String? viewNutriScore() {
    // Assuming this method just returns the nutriScore for now
    return nutriScore;
  }

  // Method to display eco score
  String? viewEcoScore() {
    // Assuming this method just returns the ecoScore for now
    return ecoScore;
  }

  // Method to display nutritional information
  String? viewNutritionalInfo() {
    // Assuming this method just returns the nutritionalInfo for now
    return nutritionalInfo;
  }

  void setQuantity(int newQuantity) {
    if (newQuantity > 0) {
      quantity = newQuantity;
    } else {
      // Handle the case where the new quantity is less than 1.
      // This might involve setting the quantity to 0, throwing an error, etc.
      // For this example, we'll just print a message and not change the quantity.
      debugPrint('Invalid quantity. The quantity must be greater than 0.');
    }
  }

  void markAsConsumed(GroceryItem item) {
    item.dateConsumed = DateTime.now();
    // Update the item in your inventory storage/database
  }

  void markAsDiscarded(GroceryItem item) {
    item.dateDiscarded = DateTime.now();
    // Update the item in your inventory storage/database
  }

  // Convert a GroceryItem object into a JSON map
  Map<String, dynamic> toJson() {
      return {
        'itemId': itemId,
        'name': name,
        'category': category,
        'quantity': quantity,
        'dateAdded': dateAdded.toIso8601String(),
        'dateConsumed': dateConsumed?.toIso8601String(),
        'dateDiscarded': dateDiscarded?.toIso8601String(),
        'expirationDate': expirationDate.toIso8601String(),
        'nutriScore': nutriScore,
        'ecoScore': ecoScore,
        'itemIdType': itemIdType.name, // Convert enum to its name
        'nutritionalInfo': nutritionalInfo,
        'visible': visible,
      };
    }

  // Create a GroceryItem object from a JSON map
  static GroceryItem fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      itemId: json['itemId'],
      name: json['name'],
      category: json['category'],
      quantity: json['quantity'] ?? 1,
      dateAdded: DateTime.parse(json['dateAdded']),
      expirationDate: DateTime.parse(json['expirationDate']),
      dateConsumed: json['dateConsumed'] != null ? DateTime.parse(json['dateConsumed']) : null,
      dateDiscarded: json['dateDiscarded'] != null ? DateTime.parse(json['dateDiscarded']) : null,
      nutriScore: json['nutriScore'],
      ecoScore: json['ecoScore'],
      itemIdType: ItemIdType.values.firstWhere((e) => e.name == json['itemIdType']),
      nutritionalInfo: json['nutritionalInfo'],
      visible: json['visible'] ?? true,
    );
  }
}
