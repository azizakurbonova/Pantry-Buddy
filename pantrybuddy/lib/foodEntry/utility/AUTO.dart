// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pantrybuddy/models/spoonacular.dart';
import 'package:pantrybuddy/models/grocery_item.dart';

//Since the intention for autocomplete is to show results as the user is typing, I will only need to capture the product name/title from the JSON response. In addition, I will need to save the product id so that I can query for more information on what the user selects

//example: https://api.spoonacular.com/food/products/suggest?query=chick&number=5&apiKey=41a82396931e43039ec29a6356ec8dc1
Future<List<Spoonacular>> autocompleteSearch_products(String query) async {
  final String apiUrl =
      'https://api.spoonacular.com/food/products/suggest?query=$query&number=5&addProductInformation=True&apiKey=41a82396931e43039ec29a6356ec8dc1';
  return autocompleteSearch_helper(apiUrl);
}

//example: https://api.spoonacular.com/food/ingredients/autocomplete?query=appl&number=5&apiKey=41a82396931e43039ec29a6356ec8dc1
Future<List<Spoonacular>> autocompleteSearch_ingredients(String query) async {
  final String apiUrl =
      'https://api.spoonacular.com/food/ingredients/autocomplete?query=$query&number=5&metaInformation=True&apiKey=41a82396931e43039ec29a6356ec8dc1';
  return autocompleteSearch_helper(apiUrl);
}

//example: https://api.spoonacular.com/food/menuItems/suggest?query=chicke&number=2&apiKey=41a82396931e43039ec29a6356ec8dc1
Future<List<Spoonacular>> autocompleteSearch_menuItems(String query) async {
  final String apiUrl =
      'https://api.spoonacular.com/food/menuItems/suggest?query=$query&number=5&metaInformation=True&apiKey=41a82396931e43039ec29a6356ec8dc1';
  return autocompleteSearch_helper(apiUrl);
}

// Helper function to perform the autocomplete search
Future<List<Spoonacular>> autocompleteSearch_helper(String apiUrl) async {
  final response = await http.get(Uri.parse(apiUrl));
  List<Spoonacular> items = [];
  if (response.statusCode == 200) {
    var data = json.decode(response.body);

    // Handle both a JSON object and a JSON array response
    List<dynamic> resultsList = data is List ? data : data['results'] ?? [];

    for (var jsonItem in resultsList) {
      try {
        items.add(Spoonacular.fromJson(jsonItem));
      } catch (e) {
        debugPrint('Failed to parse Spoonacular object: $e');
      }
    }
  } else {
    debugPrint('Failed to fetch suggestions: ${response.statusCode}');
  }
  return items;
}

//once item is selected in the autosearch, have to retrieve more information
//example: https://api.spoonacular.com/food/products/22347?apiKey=41a82396931e43039ec29a6356ec8dc1
Future<GroceryItem?> idSearch_products(
    String id, String inventoryID, DateTime expiration, int setQuantity) async {
  final String apiUrl =
      'https://api.spoonacular.com/food/products/$id?apiKey=41a82396931e43039ec29a6356ec8dc1';
  try {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final product = json.decode(response.body);
      if (product != null) {
        debugPrint('Product Name: ${product['title']}');

        return createGroceryItem_Product(
            product, inventoryID, expiration, setQuantity);
      }
      return null;
    } else {
      debugPrint(
          'Failed to fetch product. Status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      return null;
    }
  } catch (e) {
    debugPrint('Exception when calling Spoonacular API: $e');
    return null;
  }
}

//example: https://api.spoonacular.com/food/ingredients/9266/information?apiKey=41a82396931e43039ec29a6356ec8dc1&amount=1
Future<GroceryItem?> idSearch_ingredients(
    String id, String inventoryID, DateTime expiration, int setQuantity) async {
  final String apiUrl =
      'https://api.spoonacular.com/food/ingredients/$id/information?apiKey=41a82396931e43039ec29a6356ec8dc1&amount=1';
  try {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final product = json.decode(response.body);
      if (product != null) {
        debugPrint('Product Name: ${product['name']}');

        return createGroceryItem_Ingredient(
            product, inventoryID, expiration, setQuantity);
      }
      return null;
    } else {
      debugPrint(
          'Failed to fetch product. Status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      return null;
    }
  } catch (e) {
    debugPrint('Exception when calling Spoonacular API: $e');
    return null;
  }
}

//example: https://api.spoonacular.com/food/menuItems/424571?apiKey=41a82396931e43039ec29a6356ec8dc1
Future<GroceryItem?> idSearch_menuItems(
    String id, String inventoryID, DateTime expiration, int setQuantity) async {
  final String apiUrl =
      'https://api.spoonacular.com/food/menuItems/$id?apiKey=41a82396931e43039ec29a6356ec8dc1';
  try {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final product = json.decode(response.body);
      if (product != null) {
        debugPrint('Product Name: ${product['title']}');

        return createGroceryItem_Menu(
            product, inventoryID, expiration, setQuantity);
      }
      return null;
    } else {
      debugPrint(
          'Failed to fetch product. Status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      return null;
    }
  } catch (e) {
    debugPrint('Exception when calling Spoonacular API: $e');
    return null;
  }
}

// Function to parse JSON and create a GroceryItem
GroceryItem createGroceryItem_Menu(Map<String, dynamic>? product,
    String inventoryID, DateTime expiration, int setQuantity) {
  var nutrition = json.decode(product?['nutrition']);

  // Dynamically build the nutritional information string
  var nutritionalDetails = nutrition.entries.map((entry) {
    return "${entry.key}: ${entry.value}";
  }).join('; ');

  return GroceryItem(
      inventoryID: inventoryID,
      itemId: product?['id'].toString(),
      name: product?['title'] ?? 'No title available',
      category: product?['breadcrumbs'] ?? 'Unknown category',
      quantity: setQuantity, // Default quantity
      dateAdded: DateTime.now(),
      expirationDate: expiration,
      itemIdType: ItemIdType.AUTO,
      nutritionalInfo: nutrition, // All nutritional info as a string
      visible: true,
      image: product?['images'][0]);
}

// Function to parse JSON and create a GroceryItem
GroceryItem createGroceryItem_Ingredient(Map<String, dynamic>? product,
    String inventoryID, DateTime expiration, int setQuantity) {
  var nutrition = json.decode(product?['nutrition']);

  // Dynamically build the nutritional information string
  var nutritionalDetails = nutrition.entries.map((entry) {
    return "${entry.key}: ${entry.value}";
  }).join('; ');

  return GroceryItem(
      inventoryID: inventoryID,
      itemId: product?['id'].toString(),
      name: product?['name'] ?? 'No name available',
      category: product?['categoryPath'] ?? 'Unknown category',
      quantity: setQuantity,
      dateAdded: DateTime.now(),
      expirationDate: expiration,
      itemIdType: ItemIdType.AUTO,
      nutritionalInfo: nutrition, // All nutritional info as a string
      visible: true,
      image: product?['image']);
}

// Function to parse JSON and create a GroceryItem
GroceryItem createGroceryItem_Product(Map<String, dynamic>? product,
    String inventoryID, DateTime expiration, int setQuantity) {
  var nutrition = json.decode(product?['nutrition']);

  // Dynamically build the nutritional information string
  var nutritionalDetails = nutrition.entries.map((entry) {
    return "${entry.key}: ${entry.value}";
  }).join('; ');

  return GroceryItem(
      inventoryID: inventoryID,
      itemId: product?['id'].toString(),
      name: product?['title'] ?? 'No title available',
      category: product?['breadcrumbs'] ?? 'Unknown category',
      quantity: setQuantity, // Default quantity
      dateAdded: DateTime.now(),
      expirationDate: expiration, // Example expiration date
      itemIdType: ItemIdType.AUTO,
      nutritionalInfo: nutrition, // All nutritional info as a string
      visible: true,
      image: product?['image']);
}
