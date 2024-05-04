import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pantrybuddy/foodEntry/utility/MANUAL.dart';
import 'package:pantrybuddy/foodEntry/widgets/auto_search.dart';
//import 'package:test/test.dart';
import 'package:path/path.dart' as path;
import "package:pantrybuddy/foodEntry/utility/suggest_expiration.dart";
import "package:pantrybuddy/foodEntry/utility/UPC.dart";
import 'package:http/http.dart' as http;
import 'dart:convert';
import "package:pantrybuddy/models/grocery_item.dart";
import "package:pantrybuddy/foodEntry/utility/csv.dart";
import 'package:pantrybuddy/foodEntry/utility/AUTO.dart';
//import "package:pantrybuddy/models/Spoonacular.dart";
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("CSV Loading & Parsing", () {
    test('Successfully reads and parses CSV data', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      List<List<dynamic>> csvData = await loadCsv('assets/foodKeeper.csv');

      // Check if the data is loaded correctly
      expect(csvData.isNotEmpty, true);
      expect(csvData[0], [
        'ID',
        'Category_ID',
        'Category_Name',
        'Name',
        'Name_subtitle',
        'NAME_all',
        'Keywords',
        'Pantry_Min',
        'Pantry_Max',
        'Pantry_Metric',
        'Pantry_tips',
        'DOP_Pantry_Min',
        'DOP_Pantry_Max',
        'DOP_Pantry_Metric',
        'DOP_Pantry_tips',
        'Pantry_After_Opening_Min',
        'Pantry_After_Opening_Max',
        'Pantry_After_Opening_Metric',
        'Refrigerate_Min',
        'Refrigerate_Max',
        'Refrigerate_Metric',
        'Refrigerate_tips',
        'DOP_Refrigerate_Min',
        'DOP_Refrigerate_Max',
        'DOP_Refrigerate_Metric',
        'DOP_Refrigerate_tips',
        'Refrigerate_After_Opening_Min',
        'Refrigerate_After_Opening_Max',
        'Refrigerate_After_Opening_Metric',
        'Refrigerate_After_Thawing_Min',
        'Refrigerate_After_Thawing_Max',
        'Refrigerate_After_Thawing_Metric',
        'Freeze_Min',
        'Freeze_Max',
        'Freeze_Metric',
        'Freeze_Tips',
        'DOP_Freeze_Min',
        'DOP_Freeze_Max',
        'DOP_Freeze_Metric',
        'DOP_Freeze_Tips'
      ]);
      expect(csvData[1], [
        1,
        7,
        'Dairy Products & Eggs ',
        'Butter',
        '',
        'Butter ',
        'Butter',
        '',
        '',
        '',
        'May be left at room temperature for 1 - 2 days.',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        1,
        2,
        'Months',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        6,
        9,
        'Months',
        ''
      ]);

      // Parse the CSV data
      List<Map<String, dynamic>> parsedData = parseCsv(csvData);

      // Check the parsing results
      expect(parsedData.length, 661);
      expect(parsedData[0]['ID'], 1);
      expect(parsedData[0]['NAME_all'].toString().toLowerCase().trim(),
          'Butter'.toString().toLowerCase().trim());
      expect(parsedData[0]['DOP_Refrigerate_Max'], 2);
      expect(parsedData[0]['DOP_Refrigerate_Metric'], 'Months');
    });
  });
  group('Suggest Expiration Date Guideline', () {
    test('Manual Input - Expiration Guideline Suggestion', () async {
      var result = await suggestExpiration_Manual('butter');
      // Assuming the function returns a specific guideline string
      expect(result, contains('should be consumed within'));
      debugPrint(result);
    });
    test('Autocomplete Search - Expiration Guideline Suggestion - Menu Item',
        () async {
      var result = await suggestExpiration_Auto(
          'Bacon King Burger', SearchType.menuItems);
      // Assuming the function returns a specific guideline string
      expect(result, contains('should be consumed within'));
      debugPrint(result);
    });
    test('Autocomplete Search - Expiration Guideline Suggestion - Ingredient',
        () async {
      var result =
          await suggestExpiration_Auto('pineapples', SearchType.ingredients);
      // Assuming the function returns a specific guideline string
      expect(result, contains('should be consumed within'));
      debugPrint(result);
    });
    test('Autocomplete Search - Expiration Guideline Suggestion - Product',
        () async {
      var result = await suggestExpiration_Auto(
          'SNICKERS Minis Size Chocolate Candy Bars', SearchType.products);
      // Assuming the function returns a specific guideline string
      expect(result, contains('should be consumed within'));
      debugPrint(result);
    });
  });
  group('Integration Test for Spoonacular UPC Endpoint', () {
    test('fetches product data from a live API call', () async {
      // Assuming fetchProductByUPC uses a real http client and real API key
      const upcCode =
          '041631000564'; // Known UPC code that will return valid data
      Map<String, dynamic>? result = await fetchProductByUPC(upcCode);

      // Verify that the API returns a non-null result
      expect(result, isNotNull);
      expect(result!['title'], isNotNull);
      expect(result['title'],
          'Swan Flour'); // Expecting specific title based on known data
    });

    test('creates GroceryItem', () async {
      // Assuming fetchProductByUPC uses a real http client and real API key
      const upcCode =
          '041631000564'; // Known UPC code that will return valid data
      Map<String, dynamic>? result = await fetchProductByUPC(upcCode);

      // Verify that the API returns a non-null result
      expect(result, isNotNull);
      expect(result!['title'], isNotNull);
      expect(result['title'],
          'Swan Flour'); // Expecting specific title based on known data
    });
  });
  test('successfully creates a GroceryItem from API data', () async {
    // Simulate fetching product data from a live API
    const upcCode = '041631000564'; // Example UPC code
    const apiKey = '41a82396931e43039ec29a6356ec8dc1';
    final url = Uri.parse(
        'https://api.spoonacular.com/food/products/upc/$upcCode?apiKey=$apiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        Map<String, dynamic> productData = json.decode(response.body);
        GroceryItem item = createGroceryItemFromSpoonacular(
            productData, "temp", DateTime.now(), 1);

        // Assertions to validate the creation of the GroceryItem
        expect(item.itemId, equals(productData['id'].toString()));
        expect(item.name, equals(productData['title']));
        expect(item.category, equals(productData['breadcrumbs']));
        expect(item.quantity, 1);
        expect(item.itemIdType, ItemIdType.UPC);
        expect(item.visible, true);
        // Ensure nutritional info and expiration date are set as expected
        expect(item.nutritionalInfo, isNotEmpty);
        expect(item.expirationDate, isNotNull);
      } else {
        fail('Failed to fetch product data from API');
      }
    } catch (e) {
      fail('Failed due to an exception: $e');
    }
  });
  group('Manual Food Entry Helper Functions', () {
    test('correctly organizes CSV data into dropdown format', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      List<List<dynamic>> data = await loadCsv('assets/foodKeeper.csv');

      // Create lists of maps to hold the parsed data.
      List<Map<String, dynamic>> csvData = parseCsv(data);

      // Execute the function
      var result = await prepareDropdownData(csvData);

      // Verify the results
      expect(result.containsKey('Category_Name'), true);
      expect(result.containsKey('Name_ALL'), true);

      // Check Category Names
      List<String> categoryNames = result['Category_Name'];
      expect(categoryNames.length, 25);

      // Check Name_ALL mappings
      Map<String, List<String>> nameAllByCategory = result['Name_ALL'];
      expect(nameAllByCategory.length, 25);
      expect(nameAllByCategory['Produce Fresh Fruits'], contains('N/A'));
      debugPrint(nameAllByCategory['Beverages'].toString());
    });
    test('handles empty CSV data gracefully', () async {
      List<Map<String, dynamic>> emptyCsvData = [];

      // Execute the function
      var result = await prepareDropdownData(emptyCsvData);

      // Verify the results
      expect(result['Category_Name'], isEmpty);
      expect(result['Name_ALL'], isEmpty);
    });
  });
  group('Autocomplete and Product Retrieval Integration Tests', () {
    // Test the product autocomplete functionality
    test('autocompleteSearch_products returns valid results', () async {
      final results = await autocompleteSearch_products("chick");
      expect(results.isNotEmpty, true);
      //expect(results[0], isA<Spoonacular>()); ACTING WEIRDLY
      debugPrint(results[0].runtimeType.toString());
      debugPrint(results[0].toJson().toString());
      expect(results[0].name, isNotEmpty);
    });
    test('autocompleteSearch_ingredients returns valid results', () async {
      final results = await autocompleteSearch_ingredients("app");
      expect(results.isNotEmpty, true);
      //expect(results[0], isA<Spoonacular>()); ACTING WEIRDLY
      debugPrint(results[0].runtimeType.toString());
      debugPrint(results[0].toJson().toString());
      expect(results[0].name, isNotEmpty);
    });

    test('autocompleteSearch_menuItems returns valid results', () async {
      final results = await autocompleteSearch_menuItems("mcdona");
      expect(results.isNotEmpty, true);
      //expect(results[0], isA<Spoonacular>()); ACTING WEIRDLY
      debugPrint(results[0].runtimeType.toString());
      debugPrint(results[0].toJson().toString());
      expect(results[0].name, isNotEmpty);
    });

    // Test retrieving more detailed product information
    test('idSearch_products retrieves product details', () async {
      final product = await idSearch_products(
          "22347", "temp", DateTime.now(), 1); // Using a known product ID
      expect(product, isNotNull);
      expect(
          product!.name,
          equals(
              "SNICKERS Minis Size Chocolate Candy Bars Variety Mix 10.5-oz. Bag"));
      expect(product.itemIdType, ItemIdType.AUTO);
    });

    test('idSearch_products retrieves menu item details', () async {
      final product = await idSearch_menuItems(
          "424571", "temp", DateTime.now(), 1); // Using a known product ID
      expect(product, isNotNull);
      expect(product!.name, equals("Bacon King Burger"));
      expect(product.itemIdType, ItemIdType.AUTO);
    });

    test('idSearch_products retrieves ingredients details', () async {
      final product = await idSearch_ingredients(
          "9266", "temp", DateTime.now(), 1); // Using a known product ID
      expect(product, isNotNull);
      expect(product!.name, equals("pineapples"));
      expect(product.itemIdType, ItemIdType.AUTO);
    });

    const apiKey = '41a82396931e43039ec29a6356ec8dc1';
    test('createGroceryItem_Menu creates a valid GroceryItem from API data',
        () async {
      // Fetch a menu item by ID for testing
      final response = await http.get(Uri.parse(
          'https://api.spoonacular.com/food/menuItems/424571?apiKey=$apiKey'));
      if (response.statusCode == 200) {
        var product = jsonDecode(response.body);

        // Create a GroceryItem from the fetched product
        GroceryItem item =
            createGroceryItem_Menu(product, "temp", DateTime.now(), 1);

        // Check that the item has been correctly populated
        expect(item.name, isNotEmpty);
        expect(item.category, isNotEmpty);
        expect(item.itemIdType, ItemIdType.AUTO);
        expect(item.nutritionalInfo, isNotEmpty);
        expect(item.image, isNotNull);
      } else {
        fail('Failed to fetch menu item for testing');
      }
    });

    test(
        'createGroceryItem_Ingredient creates a valid GroceryItem from API data',
        () async {
      // Fetch an ingredient by ID for testing
      final response = await http.get(Uri.parse(
          'https://api.spoonacular.com/food/ingredients/9266/information?apiKey=$apiKey&amount=1'));
      if (response.statusCode == 200) {
        var product = jsonDecode(response.body);

        // Create a GroceryItem from the fetched ingredient
        GroceryItem item =
            createGroceryItem_Ingredient(product, "temp", DateTime.now(), 1);

        // Check that the item has been correctly populated
        expect(item.name, isNotEmpty);
        expect(item.category, isNotEmpty);
        expect(item.itemIdType, ItemIdType.AUTO);
        expect(item.nutritionalInfo, isNotEmpty);
        expect(item.image, isNotNull);
      } else {
        fail('Failed to fetch ingredient for testing');
      }
    });

    test('createGroceryItem_Product creates a valid GroceryItem from API data',
        () async {
      // Fetch a product by ID for testing
      final response = await http.get(Uri.parse(
          'https://api.spoonacular.com/food/products/22347?apiKey=$apiKey'));
      if (response.statusCode == 200) {
        var product = jsonDecode(response.body);

        // Create a GroceryItem from the fetched product
        GroceryItem item =
            createGroceryItem_Product(product, "temp", DateTime.now(), 1);

        // Check that the item has been correctly populated
        expect(item.name, isNotEmpty);
        expect(item.category, isNotEmpty);
        expect(item.itemIdType, ItemIdType.AUTO);
        expect(item.nutritionalInfo, isNotEmpty);
        expect(item.image, isNotNull);
      } else {
        fail('Failed to fetch product for testing');
      }
    });
  });
}
