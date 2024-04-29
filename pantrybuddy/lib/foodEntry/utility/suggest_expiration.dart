import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart' as csv_lib;
import 'package:flutter/material.dart';
import 'package:pantrybuddy/foodEntry/widgets/auto_search.dart';
import 'package:path/path.dart' as path;
import  'package:string_similarity/string_similarity.dart';

// Load CSV data from a file path and return as a list of lists.
Future<List<List<dynamic>>> loadCsv(String filePath) async {
  final input = File(filePath).openRead();
  return await input.transform(utf8.decoder).transform(const csv_lib.CsvToListConverter()).toList();
}

// Parse the CSV data into a list of maps for easier data manipulation.
List<Map<String, dynamic>> parseCsv(List<List<dynamic>> csvData) {
  List<String> headers = csvData[0].cast<String>();
  List<Map<String, dynamic>> data = [];
  for (final row in csvData.skip(1)) {
    Map<String, dynamic> dataRow = Map.fromIterables(headers, row);
    data.add(dataRow);
  }
  return data;
}


// Define a function that suggests expiration dates based on category and subcategory IDs.
// ignore: non_constant_identifier_names
Future<String> suggestExpiration_Manual(String productName) async {
  try {
    // Load and parse the categories and expiration data from CSV files.
    var currDir= Directory.current.path;
    String filePath = path.join(currDir, 'lib', 'foodEntry','externalDB','foodKeeper.csv');

    final expirationData = await loadCsv(filePath);

    // Create lists of maps to hold the parsed data.
    List<Map<String, dynamic>> expirations = parseCsv(expirationData);

    // Attempt to find a matching category and expiration guideline.
    Map<String, dynamic>? expiration = expirations.firstWhere((exp) => exp['NAME_all'].toString().toLowerCase().trim() == productName.toString().toLowerCase().trim());

    // Construct the expiration suggestion string if a matching guideline is found.
    if (expiration != null) {
      String starting= 'For freshness and quality, this item should be consumed within \n';
      List<String> suggestions = [starting];

      if (expiration['DOP_Refrigerate_Max'] != null && expiration['DOP_Refrigerate_Metric'] != null) {
        suggestions.add('${expiration['DOP_Refrigerate_Max']} ${expiration['DOP_Refrigerate_Metric']} if refrigerated from the date of purchase\n');
      }
      if (expiration['Pantry_Max'] != null && expiration['Pantry_Metric'] != null) {
        suggestions.add('${expiration['Pantry_Max']} ${expiration['Pantry_Metric']} if in the pantry from the date of purchase\n');
      }
      if (expiration['Refrigerate_After_Opening_Max'] != null && expiration['Refrigerate_After_Opening_Metric'] != null) {
        suggestions.add('${expiration['Refrigerate_After_Opening_Max']} ${expiration['Refrigerate_After_Opening_Metric']} if refrigerated after opening\n');
      }
      if (expiration['DOP_Pantry_Max'] != null && expiration['DOP_Pantry_Metric'] != null) {
        suggestions.add('${expiration['DOP_Pantry_Max']} ${expiration['DOP_Pantry_Metric']} if in the pantry from the date of purchase\n');
      }
      if (expiration['Refrigerate_Max'] != null && expiration['Refrigerate_Metric'] != null) {
        suggestions.add('${expiration['Refrigerate_Max']} ${expiration['Refrigerate_Metric']} if refrigerated from the date of purchase\n');
      }

      String guideline = '${suggestions.join(' ')}.';
      return guideline;
    }

    return 'No specific expiration information available for this food category and/or product.';
  } catch (e) {
    debugPrint('Error reading CSV data: $e');
    return 'Error processing expiration data.';
  }
}

// ignore: non_constant_identifier_names
Future<String> suggestExpiration_Auto(String productName,SearchType productType) async {
  if (productType == SearchType.menuItems) {
      String starting= 'For freshness and quality, this item should be consumed within \n';
      List<String> suggestions = [starting];
      suggestions.add('3-4 days if refrigerated from the date of purchase \n');
      suggestions.add('2-3 months if frozen from the date of purchase \n');
      
      String guideline = '${suggestions.join(' ')}.';
      return guideline;
  }
  else{
      try {
        // Load and parse the categories and expiration data from CSV files.
        var currDir= Directory.current.path;
        String filePath = path.join(currDir, 'lib', 'foodEntry','externalDB','foodKeeper.csv');

        final expirationData = await loadCsv(filePath);

        // Create lists of maps to hold the parsed data.
        List<Map<String, dynamic>> expirations = parseCsv(expirationData);

        // Attempt to find a matching category and expiration guideline.
        // Extract all product names into a list for the bestMatch function
        List<String> productNames = expirations.map((exp) => exp['NAME_all'].toString().toLowerCase()).toList();

        // Find the best match for the given product name
        BestMatch result = productName.toLowerCase().bestMatch(productNames);

        // Construct the expiration suggestion string if a matching guideline is found.
        if (result.bestMatch.rating! > 0.4) {
          Map<String, dynamic> expiration = expirations[result.bestMatchIndex];
          String starting= 'For freshness and quality, this item should be consumed within \n';
          List<String> suggestions = [starting];

          if (expiration['DOP_Refrigerate_Max'] != null && expiration['DOP_Refrigerate_Metric'] != null) {
            suggestions.add('${expiration['DOP_Refrigerate_Max']} ${expiration['DOP_Refrigerate_Metric']} if refrigerated from the date of purchase\n');
          }
          if (expiration['Pantry_Max'] != null && expiration['Pantry_Metric'] != null) {
            suggestions.add('${expiration['Pantry_Max']} ${expiration['Pantry_Metric']} if in the pantry from the date of purchase\n');
          }
          if (expiration['Refrigerate_After_Opening_Max'] != null && expiration['Refrigerate_After_Opening_Metric'] != null) {
            suggestions.add('${expiration['Refrigerate_After_Opening_Max']} ${expiration['Refrigerate_After_Opening_Metric']} if refrigerated after opening\n');
          }
          if (expiration['DOP_Pantry_Max'] != null && expiration['DOP_Pantry_Metric'] != null) {
            suggestions.add('${expiration['DOP_Pantry_Max']} ${expiration['DOP_Pantry_Metric']} if in the pantry from the date of purchase\n');
          }
          if (expiration['Refrigerate_Max'] != null && expiration['Refrigerate_Metric'] != null) {
            suggestions.add('${expiration['Refrigerate_Max']} ${expiration['Refrigerate_Metric']} if refrigerated from the date of purchase\n');
          }

          String guideline = '${suggestions.join(' ')}.';
          return guideline;
        }
        else{
          return 'No specific expiration information available for this food category and/or product.';
        }
      } catch (e) {
        debugPrint('Error reading CSV data: $e');
        return 'Error processing expiration data.';
      }
  }
}
