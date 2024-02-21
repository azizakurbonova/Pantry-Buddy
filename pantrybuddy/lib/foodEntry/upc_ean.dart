//Function Description: given UPC/EAN barcode, pass along to Open Food Facts database to retrieve product information
//An example of a successful GET response is: https://world.openfoodfacts.org/api/v0/product/3017620422003.json
//Refer the response for product fields

import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

//Description: Scan UPC / EAN barcode
Future<String?> scanBarcode() async {
  try {
    final barcode = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666', // Color
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

Future<Map<String, dynamic>?> fetchProductInfo(String barcode) async {
  final String url = 'https://world.openfoodfacts.org/api/v0/product/$barcode.json';
  // Define custom headers including the User-Agent
  final Map<String, String> headers = {
    'User-Agent': 'PantryBuddy/1.0 (a11.pantrybuddy@gmail.com)',
  };

  try {
    // Include the headers in the HTTP GET request
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 1) { // Product found
        return data['product'];
      } else {
        debugPrint('Product not found');
        return null;
      }
    } else {
      debugPrint('Failed to load product data');
      return null;
    }
  } catch (e) {
    debugPrint('Error fetching product info: $e');
    return null;
  }
}

Future<void> scanAndFetchProduct() async {
  final barcode = await scanBarcode();
  if (barcode != null) {
    final productInfo = await fetchProductInfo(barcode);
    if (productInfo != null) {
      print('Product Name: ${productInfo['product_name']}');
      //#TO-DO: sort through product information package to use what's relevant for creating a GroceryItem and adding that to user's FoodInventory and updating the database accordingly
    }
  }
}