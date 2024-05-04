// ignore_for_file: unnecessary_this

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart'; // For debugPrint

enum ItemIdType { EAN, UPC, PLU, MANUAL, AUTO }

/*
Example Use of class methods to update firebase

GroceryItem item = GroceryItem(
    itemId: '123',
    name: 'Apple',
    category: ['Fruit'],
    quantity: 10,
    dateAdded: DateTime.now(),
    expirationDate: DateTime.now().add(Duration(days: 90)),
    itemIdType: ItemIdType.UPC
);

item.updateQuantity(15);
item.markConsumed();

*/

class GroceryItem {
  String? itemId;
  String name;
  List<dynamic> category;
  int quantity;
  DateTime dateAdded;
  DateTime? dateConsumed;
  DateTime? dateDiscarded;
  DateTime expirationDate;
  ItemIdType itemIdType;
  String? nutritionalInfo;
  bool visible;
  String? image;
  String inventoryID;

  GroceryItem({
    this.itemId,
    required this.name,
    required this.category,
    this.quantity = 1,
    required this.dateAdded,
    required this.expirationDate,
    this.dateConsumed,
    this.dateDiscarded,
    required this.itemIdType,
    this.nutritionalInfo,
    this.visible = true,
    this.image,
    required this.inventoryID,
  });

  DatabaseReference get dbRef =>
      FirebaseDatabase.instance.ref('groceryItems/${this.itemId}');

  void updateQuantity(int newQuantity) {
    if (newQuantity > 0) {
      this.quantity = newQuantity;
      dbRef.update({'quantity': this.quantity});
    }
  }

  void markConsumed() {
    if (this.dateConsumed == null) {
      // Ensure it's only marked once
      this.dateConsumed = DateTime.now();
      this.visible = false; // Optionally make it invisible in the app
      dbRef.update({
        'dateConsumed': this.dateConsumed?.toIso8601String(),
        'visible': this.visible
      });
    }
  }

  void markDiscarded() {
    if (this.dateDiscarded == null) {
      // Ensure it's only marked once
      this.dateDiscarded = DateTime.now();
      this.visible = false; // Optionally make it invisible in the app
      dbRef.update({
        'dateDiscarded': this.dateDiscarded?.toIso8601String(),
        'visible': this.visible
      });
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'inventoryID': inventoryID,
      'name': name,
      'category': category.join(', '), // Assuming category is a list of strings
      'quantity': quantity,
      'dateAdded': dateAdded.toIso8601String(),
      'dateConsumed': dateConsumed?.toIso8601String(),
      'dateDiscarded': dateDiscarded?.toIso8601String(),
      'expirationDate': expirationDate.toIso8601String(),
      'itemIdType': itemIdType.name,
      'nutritionalInfo': nutritionalInfo,
      'visible': visible,
      'image': image,
    };
  }

  static GroceryItem fromJson(Map<String, dynamic> json) {
    return GroceryItem(
        itemId: json['itemId'],
        inventoryID: json['inventoryID'],
        name: json['name'],
        category: (json['category'] as String)
            .split(', '), // Convert string back to list
        quantity: json['quantity'] ?? 1,
        dateAdded: DateTime.parse(json['dateAdded']),
        expirationDate: DateTime.parse(json['expirationDate']),
        dateConsumed: json['dateConsumed'] != null
            ? DateTime.parse(json['dateConsumed'])
            : null,
        dateDiscarded: json['dateDiscarded'] != null
            ? DateTime.parse(json['dateDiscarded'])
            : null,
        itemIdType:
            ItemIdType.values.firstWhere((e) => e.name == json['itemIdType']),
        nutritionalInfo:
            json['nutrition'] != null ? json['nutrition'].toString() : null,
        visible: json['visible'] ?? true,
        image: json['image']);
  }
}
