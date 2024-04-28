import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pantrybuddy/models/grocery_item.dart';

//example: https://api.spoonacular.com/food/products/suggest?query=chick&number=5&apiKey=41a82396931e43039ec29a6356ec8dc1
Future<List<String>> autocompleteSearch_products(String query) async {
  final String apiUrl = 'https://api.spoonacular.com/food/products/suggest?query=$query&number=5&addProductInformation=True&apiKey=41a82396931e43039ec29a6356ec8dc1';
  return autocompleteSearch_helper(apiUrl);
}

//example: https://api.spoonacular.com/food/ingredients/autocomplete?query=appl&number=5&apiKey=41a82396931e43039ec29a6356ec8dc1
Future<List<String>> autocompleteSearch_ingredients(String query) async {
  final String apiUrl = 'https://api.spoonacular.com/food/ingredients/autocomplete?query=$query&number=5&metaInformation=True&apiKey=41a82396931e43039ec29a6356ec8dc1';
  return autocompleteSearch_helper(apiUrl);
}

//example: https://api.spoonacular.com/food/menuItems/suggest?query=chicke&number=2&apiKey=41a82396931e43039ec29a6356ec8dc1
Future<List<String>> autocompleteSearch_menuItems(String query) async {
  final String apiUrl = 'https://api.spoonacular.com/food/menuItems/suggest?query=$query&number=5&metaInformation=True&apiKey=41a82396931e43039ec29a6356ec8dc1';
  return autocompleteSearch_helper(apiUrl);
}


// Helper function to perform the autocomplete search and return a list of names
Future<List<String>> autocompleteSearch_helper(String apiUrl) async {
  final response = await http.get(Uri.parse(apiUrl));
  List<String> names = [];
  if (response.statusCode == 200) {
    var suggestions = json.decode(response.body)['results'];
    for (var item in suggestions) {
      try {
        names.add(item['title'] ?? item['name']); // Some endpoints might use 'title', others 'name'
      } catch (e) {
        debugPrint('Failed to parse product name: $e');
      }
    }
  } else {
    debugPrint('Failed to fetch suggestions: ${response.statusCode}');
  }
  return names;
}

