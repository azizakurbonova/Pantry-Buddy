import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pantrybuddy/models/spoonacular.dart';

//Since the intention for autocomplete is to show results as the user is typing, I will only need to capture the product name/title from the JSON response. In addition, I will need to save the product id so that I can query for more information on what the user selects

//example: https://api.spoonacular.com/food/products/suggest?query=chick&number=5&apiKey=41a82396931e43039ec29a6356ec8dc1
Future<List<Spoonacular>> autocompleteSearch_products(String query) async {
  final String apiUrl = 'https://api.spoonacular.com/food/products/suggest?query=$query&number=5&addProductInformation=True&apiKey=41a82396931e43039ec29a6356ec8dc1';
  return autocompleteSearch_helper(apiUrl);
}

//example: https://api.spoonacular.com/food/ingredients/autocomplete?query=appl&number=5&apiKey=41a82396931e43039ec29a6356ec8dc1
Future<List<Spoonacular>> autocompleteSearch_ingredients(String query) async {
  final String apiUrl = 'https://api.spoonacular.com/food/ingredients/autocomplete?query=$query&number=5&metaInformation=True&apiKey=41a82396931e43039ec29a6356ec8dc1';
  return autocompleteSearch_helper(apiUrl);
}

//example: https://api.spoonacular.com/food/menuItems/suggest?query=chicke&number=2&apiKey=41a82396931e43039ec29a6356ec8dc1
Future<List<Spoonacular>> autocompleteSearch_menuItems(String query) async {
  final String apiUrl = 'https://api.spoonacular.com/food/menuItems/suggest?query=$query&number=5&metaInformation=True&apiKey=41a82396931e43039ec29a6356ec8dc1';
  return autocompleteSearch_helper(apiUrl);
}

// Helper function to perform the autocomplete search
Future<List<Spoonacular>> autocompleteSearch_helper(String apiUrl) async {
  final response = await http.get(Uri.parse(apiUrl));
  List<Spoonacular> items = [];
  if (response.statusCode == 200) {
    var suggestions = json.decode(response.body)['results'];
    for (var jsonItem in suggestions) {
      try {
        items.add(Spoonacular.fromJson(jsonItem));
      } catch (e) {
        debugPrint('Failed to parse ProductSimple: $e');
      }
    }
  } else {
    debugPrint('Failed to fetch suggestions: ${response.statusCode}');
  }
  return items;
}
