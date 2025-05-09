import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pantrybuddy/models/grocery_item.dart';

//Description: Scan UPC / EAN barcode
Future<String?> scanBarcode() async {
  try {
    final barcode = await FlutterBarcodeScanner.scanBarcode(
      '#66ff8f', // Color
      'Cancel', // Cancel button text
      true, // Show flash icon
      ScanMode.BARCODE, // Scan mode
    );

    if (barcode == '-1') {
      debugPrint('Barcode scanning cancelled');
      return null;
    }

    return barcode;
  } catch (e) {
    debugPrint('Barcode scanning error: $e');
    return null;
  }
}

//Example GET response: https://api.spoonacular.com/food/products/upc/041631000564?apiKey=41a82396931e43039ec29a6356ec8dc1
Future<Map<String, dynamic>?> fetchProductByUPC(String upcCode) async {
  const String apiKey = '41a82396931e43039ec29a6356ec8dc1';
  final String url = 'https://api.spoonacular.com/food/products/upc/$upcCode';
  final Uri uri = Uri.parse('$url?apiKey=$apiKey');

  try {
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return json.decode(response.body);
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
GroceryItem createGroceryItemFromSpoonacular(Map<String, dynamic>? product,
    String inventoryID, DateTime expiration, int quantity) {
  var nutrition = product?['nutrition']['nutrients'];

  // Dynamically build the nutritional information string
  var nutritionalDetails = nutrition.map((nutrient) {
    String name = nutrient['title'] ?? 'Unknown';
    String amount = nutrient['amount'].toString();
    String unit = nutrient['unit'] ?? '';
    String percentDaily = nutrient['percentOfDailyNeeds'].toString();
    return "$name, $amount $unit, $percentDaily";
  }).join('; ');

  return GroceryItem(
      inventoryID: inventoryID,
      itemId: product?['id'].toString(),
      name: product?['title'] ?? 'No title available',
      category: product?['breadcrumbs'] ?? 'Unknown category',
      quantity: quantity, // Default quantity
      dateAdded: DateTime.now(),
      expirationDate: expiration, // Example expiration date
      itemIdType: ItemIdType.UPC,
      nutritionalInfo: nutritionalDetails, // All nutritional info as a string
      visible: true,
      image: product?['image']);
}

Future<GroceryItem?> scanAndFetchProduct(
    String inventoryID, DateTime expiration, int quantity) async {
  final barcode = await scanBarcode();
  if (barcode != null) {
    final product = await fetchProductByUPC(barcode);
    if (product != null) {
      debugPrint('Product Name: ${product['title']}');

      return createGroceryItemFromSpoonacular(
          product, inventoryID, expiration, quantity);
    }
    return null;
  }
  return null;
}
