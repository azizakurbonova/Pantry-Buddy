import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart' as csv_lib;
import 'package:flutter/material.dart';
import 'package:pantrybuddy/foodEntry/widgets/auto_search.dart';
import 'package:path/path.dart' as path;
import  'package:string_similarity/string_similarity.dart';
import "package:pantrybuddy/foodEntry/utility/csv.dart";


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
    // Extract all product names into a list for the bestMatch function
    List<String> productNames = expirations.map((exp) => exp['NAME_all'].toString().toLowerCase()).toList();

    // Find the best match for the given product name
    BestMatch result = productName.toLowerCase().bestMatch(productNames);
    Map<String, dynamic> expiration;
    String starting;

    // Construct the expiration suggestion string if a matching guideline is found.
    if (result.bestMatch.rating! > 0.8) {
      expiration = expirations[result.bestMatchIndex];
      starting= 'Based on similar expiration guidelines for ${result.bestMatch.target.toString().toLowerCase().trim()}, this item should be consumed within: \n';
    }
    else{
      expiration = expirations.firstWhere((exp) => exp['NAME_all'].toString().trim() == productName);

      // ignore: unnecessary_null_comparison
      if (expiration == null){
        return 'No specific expiration information available for this food category and/or product.';
      }
      else{
      starting= 'Based on similar expiration guidelines for ${expiration['Name_ALL']}, this item should be consumed within: \n';}
    }
    
    List<String> suggestions = [starting];
    if (expiration['DOP_Refrigerate_Max'] != '' && expiration['DOP_Refrigerate_Metric'].toString().toLowerCase().trim() != '') {
      suggestions.add('\t${expiration['DOP_Refrigerate_Max']} ${expiration['DOP_Refrigerate_Metric']} if refrigerated from the date of purchase\n');
    }
    if (expiration['Refrigerate_After_Opening_Max'] != '' && expiration['Refrigerate_After_Opening_Metric'].toString().toLowerCase().trim() != '') {
      suggestions.add('\t${expiration['Refrigerate_After_Opening_Max']} ${expiration['Refrigerate_After_Opening_Metric']} if refrigerated after opening\n');
    }
    if (expiration['Refrigerate_Max'] != '' && expiration['Refrigerate_Metric'].toString().toLowerCase().trim() != '') {
      suggestions.add('\t${expiration['Refrigerate_Max']} ${expiration['Refrigerate_Metric']} if refrigerated from the date of purchase\n');
    }
    if (expiration['DOP_Pantry_Max'] != '' && expiration['DOP_Pantry_Metric'].toString().toLowerCase().trim() != '') {
      suggestions.add('\t${expiration['DOP_Pantry_Max']} ${expiration['DOP_Pantry_Metric']} if in the pantry from the date of purchase\n');
    }
    if (expiration['Pantry_Max'] != '' && expiration['Pantry_Metric'].toString().toLowerCase().trim() != '') {
      suggestions.add('\t${expiration['Pantry_Max']} ${expiration['Pantry_Metric']} if in the pantry from the date of purchase\n');
    }

    String guideline = '${suggestions.join(' ')}.';
    return guideline;
  } catch (e) {
    debugPrint('Error reading CSV data: $e');
    return 'Error processing expiration data.';
  }
}

// ignore: non_constant_identifier_names
Future<String> suggestExpiration_Auto(String productName,SearchType productType) async {
  if (productType == SearchType.menuItems) {
      String starting= 'Based on the expiration guidelines for meals, this item should be consumed within:: \n';
      List<String> suggestions = [starting];
      suggestions.add('\t3-4 days if refrigerated from the date of purchase \n');
      suggestions.add('\t2-3 months if frozen from the date of purchase \n');
      
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
        Map<String, dynamic> expiration;
        String starting;

        // Construct the expiration suggestion string if a matching guideline is found.
        if (result.bestMatch.rating! > 0.4) {
          expiration = expirations[result.bestMatchIndex];
          starting= 'Based on similar expiration guidelines for ${result.bestMatch.target.toString().toLowerCase().trim()}, this item should be consumed within: \n';
        }
        else{ //matching based on tokenization
          // Tokenize the search term
          List<String> searchTokens = productName.toLowerCase().split(' ');

          // Filter and rank the expirations based on token overlap
          List<Map<String, dynamic>> filteredExpirations = [];
          for (var exp in expirations) {
            var productTokens = exp['NAME_all'].toString().toLowerCase().split(' ');
            // Count how many tokens from the search are found in the product name
            var matchCount = searchTokens.where((token) => productTokens.contains(token)).length;
            if (matchCount > 0) {  // you might adjust this threshold based on needs
              exp['matchCount'] = matchCount;
              filteredExpirations.add(exp);
            }
          }

          // Sort by match count
          filteredExpirations.sort((a, b) => b['matchCount'].compareTo(a['matchCount']));

          if (filteredExpirations.isNotEmpty) {
            expiration = filteredExpirations.first;
            starting= 'Based on similar expiration guidelines for ${expiration['Name'].toString().toLowerCase().trim()}, this item should be consumed within: \n';
          }
          else{
            return 'No specific expiration information available for this food category and/or product.';
          }
        }
        
        List<String> suggestions = [starting];
        if (expiration['DOP_Refrigerate_Max'] != '' && expiration['DOP_Refrigerate_Metric'].toString().toLowerCase().trim() != '') {
          suggestions.add('\t${expiration['DOP_Refrigerate_Max']} ${expiration['DOP_Refrigerate_Metric']} if refrigerated from the date of purchase\n');
        }
        if (expiration['Refrigerate_After_Opening_Max'] != '' && expiration['Refrigerate_After_Opening_Metric'].toString().toLowerCase().trim() != '') {
          suggestions.add('\t${expiration['Refrigerate_After_Opening_Max']} ${expiration['Refrigerate_After_Opening_Metric']} if refrigerated after opening\n');
        }
        if (expiration['Refrigerate_Max'] != '' && expiration['Refrigerate_Metric'].toString().toLowerCase().trim() != '') {
          suggestions.add('\t${expiration['Refrigerate_Max']} ${expiration['Refrigerate_Metric']} if refrigerated from the date of purchase\n');
        }
        if (expiration['DOP_Pantry_Max'] != '' && expiration['DOP_Pantry_Metric'].toString().toLowerCase().trim() != '') {
          suggestions.add('\t${expiration['DOP_Pantry_Max']} ${expiration['DOP_Pantry_Metric']} if in the pantry from the date of purchase\n');
        }
        if (expiration['Pantry_Max'] != '' && expiration['Pantry_Metric'].toString().toLowerCase().trim() != '') {
          suggestions.add('\t${expiration['Pantry_Max']} ${expiration['Pantry_Metric']} if in the pantry from the date of purchase\n');
        }

        String guideline = '${suggestions.join(' ')}.';
        return guideline;
      } catch (e) {
        debugPrint('Error reading CSV data: $e');
        return 'Error processing expiration data.';
      }
  }
}
