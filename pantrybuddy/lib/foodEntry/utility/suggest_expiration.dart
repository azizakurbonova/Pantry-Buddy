import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart' as csv_lib;
import 'package:flutter/material.dart';

// Load CSV data from a file path and return as a list of lists.
Future<List<List<dynamic>>> loadCsvData(String filePath) async {
  final input = File(filePath).openRead();
  return await input.transform(utf8.decoder).transform(const csv_lib.CsvToListConverter()).toList();
}

// Parse the CSV data into a list of maps for easier data manipulation.
List<Map<String, dynamic>> parseCsvData(List<List<dynamic>> csvData) {
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
Future<String> suggestExpiration_Manual(String productID) async {
  try {
    // Load and parse the categories and expiration data from CSV files.
    final expirationData = await loadCsvData('package:pantrybuddy/foodEntry/externalDB/foodKeeper_expiration.csv');

    // Create lists of maps to hold the parsed data.
    List<Map<String, dynamic>> expirations = parseCsvData(expirationData);

    // Attempt to find a matching category and expiration guideline.
    Map<String, dynamic>? expiration = expirations.firstWhere((exp) => exp['ID'].toString() == productID);

    // Construct the expiration suggestion string if a matching guideline is found.
    if (expiration != null) {
      List<String> suggestions = [];
      String suggestion = 'For freshness and quality, this item should be consumed within ';

      if (expiration['DOP_Refrigerate_Max'] != null && expiration['DOP_Refrigerate_Metric'] != null) {
        suggestions.add('${expiration['DOP_Refrigerate_Max']} ${expiration['DOP_Refrigerate_Metric']} if refrigerated from the date of purchase');
      }
      if (expiration['Pantry_Max'] != null && expiration['Pantry_Metric'] != null) {
        suggestions.add('${expiration['Pantry_Max']} ${expiration['Pantry_Metric']} if in the pantry from the date of purchase');
      }
      if (expiration['Refrigerate_After_Opening_Max'] != null && expiration['Refrigerate_After_Opening_Metric'] != null) {
        suggestions.add('${expiration['Refrigerate_After_Opening_Max']} ${expiration['Refrigerate_After_Opening_Metric']} if refrigerated after opening');
      }

      suggestion += '${suggestions.join(', ')}.';
      return suggestion;
    }

    return 'No specific expiration information available for this food category and/or product.';
  } catch (e) {
    debugPrint('Error reading CSV data: $e');
    return 'Error processing expiration data.';
  }
}

// ignore: non_constant_identifier_names
Future<String> suggestExpiration_Auto(String productName) async {
  try {
    // Load and parse the categories and expiration data from CSV files.
    final expirationData = await loadCsvData('package:pantrybuddy/foodEntry/externalDB/foodKeeper_expiration.csv');

    // Create lists of maps to hold the parsed data.
    List<Map<String, dynamic>> expirations = parseCsvData(expirationData);

    // Attempt to find a matching category and expiration guideline.
    Map<String, dynamic>? expiration = expirations.firstWhere(
    (exp) => exp['Name'].toString().toLowerCase().contains(productName.toLowerCase()) ||
             (exp['Name_subtitle'] != null && exp['Name_subtitle'].toString().toLowerCase().contains(productName.toLowerCase())));

    // Construct the expiration suggestion string if a matching guideline is found.
    if (expiration != null) {
      List<String> suggestions = [];
      String suggestion = 'For freshness and quality, this item should be consumed within ';

      if (expiration['DOP_Refrigerate_Max'] != null && expiration['DOP_Refrigerate_Metric'] != null) {
        suggestions.add('${expiration['DOP_Refrigerate_Max']} ${expiration['DOP_Refrigerate_Metric']} if refrigerated from the date of purchase');
      }
      if (expiration['Pantry_Max'] != null && expiration['Pantry_Metric'] != null) {
        suggestions.add('${expiration['Pantry_Max']} ${expiration['Pantry_Metric']} if in the pantry from the date of purchase');
      }
      if (expiration['Refrigerate_After_Opening_Max'] != null && expiration['Refrigerate_After_Opening_Metric'] != null) {
        suggestions.add('${expiration['Refrigerate_After_Opening_Max']} ${expiration['Refrigerate_After_Opening_Metric']} if refrigerated after opening');
      }

      suggestion += '${suggestions.join(', ')}.';
      return suggestion;
    }

    return 'No specific expiration information available for this food category and/or product.';
  } catch (e) {
    debugPrint('Error reading CSV data: $e');
    return 'Error processing expiration data.';
  }
}
