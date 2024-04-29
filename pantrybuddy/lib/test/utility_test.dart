import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pantrybuddy/foodEntry/widgets/auto_search.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;
import "package:pantrybuddy/foodEntry/utility/suggest_expiration.dart"; // Import your functions here

void main() {
  group('Suggest Expiration Date Guideline', () {
    test('Successfully reads and parses CSV data', () async {
      // Path to the test fixture
      var currDir= Directory.current.path;
      String filePath = path.join(currDir, 'lib', 'foodEntry','externalDB','foodKeeper.csv');

      // Use the loadCsv function to read the file
      var csvData = await loadCsv(filePath);

      // Check if the data is loaded correctly
      expect(csvData.isNotEmpty, true);
      expect(csvData[0], ['ID', 'Category_ID', 'Category_Name', 'Name', 'Name_subtitle', 'NAME_all', 'Keywords', 'Pantry_Min', 'Pantry_Max', 'Pantry_Metric', 'Pantry_tips', 'DOP_Pantry_Min', 'DOP_Pantry_Max', 'DOP_Pantry_Metric', 'DOP_Pantry_tips', 'Pantry_After_Opening_Min', 'Pantry_After_Opening_Max', 'Pantry_After_Opening_Metric', 'Refrigerate_Min', 'Refrigerate_Max', 'Refrigerate_Metric', 'Refrigerate_tips', 'DOP_Refrigerate_Min', 'DOP_Refrigerate_Max', 'DOP_Refrigerate_Metric', 'DOP_Refrigerate_tips', 'Refrigerate_After_Opening_Min', 'Refrigerate_After_Opening_Max', 'Refrigerate_After_Opening_Metric', 'Refrigerate_After_Thawing_Min', 'Refrigerate_After_Thawing_Max', 'Refrigerate_After_Thawing_Metric', 'Freeze_Min', 'Freeze_Max', 'Freeze_Metric', 'Freeze_Tips', 'DOP_Freeze_Min', 'DOP_Freeze_Max', 'DOP_Freeze_Metric', 'DOP_Freeze_Tips']);
      expect(csvData[1], [1, 7, 'Dairy Products & Eggs ', 'Butter', '', 'Butter ', 'Butter', '', '', '', 'May be left at room temperature for 1 - 2 days.', '', '', '', '', '', '', '', '', '', '', '', 1,2, 'Months', '', '', '', '', '', '', '', '', '', '', '', 6, 9, 'Months', '']);

      // Parse the CSV data
      List<Map<String, dynamic>> parsedData = parseCsv(csvData);

      // Check the parsing results
      expect(parsedData.length, 661);
      expect(parsedData[0]['ID'], 1);
      expect(parsedData[0]['NAME_all'].toString().toLowerCase().trim(), 'Butter'.toString().toLowerCase().trim());
      expect(parsedData[0]['DOP_Refrigerate_Max'], 2);
      expect(parsedData[0]['DOP_Refrigerate_Metric'], 'Months');
    });

    test('Manual Input - Expiration Guideline Suggestion', () async {
      var result = await suggestExpiration_Manual('butter');
      // Assuming the function returns a specific guideline string
      expect(result, contains('should be consumed within')); 
      debugPrint(result);
    });
    test('Autocomplete Search - Expiration Guideline Suggestion - Menu Item', () async {
      var result = await suggestExpiration_Auto('Bacon King Burger',SearchType.menuItems);
      // Assuming the function returns a specific guideline string
      expect(result, contains('should be consumed within')); 
      debugPrint(result);
    });
    test('Autocomplete Search - Expiration Guideline Suggestion - Ingredient', () async {
      var result = await suggestExpiration_Auto('pineapples',SearchType.ingredients);
      // Assuming the function returns a specific guideline string
      expect(result, contains('should be consumed within')); 
      debugPrint(result);
    });
    test('Autocomplete Search - Expiration Guideline Suggestion - Product', () async {
      var result = await suggestExpiration_Auto('SNICKERS Minis Size Chocolate Candy Bars',SearchType.products);
      // Assuming the function returns a specific guideline string
      expect(result, contains('should be consumed within'));
      debugPrint(result);
    });
  });
}
