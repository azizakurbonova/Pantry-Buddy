//OCR Recognition of 4/5 digit PLU code, numeric only

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:csv/csv.dart';

Future<String?> readPLUCode() async {
  // user takes a photo of the PLU sticker
  final ImagePicker picker = ImagePicker();
  final XFile? imageFile = await picker.pickImage(source: ImageSource.camera);
  if (imageFile == null) return null;

  // initialize text detector
  final inputImage = InputImage.fromFilePath(imageFile.path);
  final textDetector = GoogleMlKit.vision.textRecognizer();

  // extract all text
  final RecognizedText allText = await textDetector.processImage(inputImage);
  
  // condition for extracting PLU code from all text retrieved
  final pluCodeRegExp = RegExp(r'\b\d{4,5}\b');
  String? pluCode;

  // Search for matches in the recognized text blocks
  for (TextBlock block in allText.blocks) {
    for (TextLine line in block.lines) {
      final match = pluCodeRegExp.firstMatch(line.text);
      if (match != null) {
        pluCode = match.group(0);
        break;
      }
    }
    if (pluCode != null) {
      debugPrint("PLU code not found");
      break;
      }
  }

  // Close the text detector now that it is no longer needed
  textDetector.close();

  return pluCode; // Return the found PLU code or null if no match was found
}

//To-Do: Look up PLU in IFPS database to retrieve category and name
Future<List<List<dynamic>>> parseCSV(String csvData) async {
  List<List<dynamic>> rows = const CsvToListConverter().convert(csvData);
  return rows;
}

Future<Map<String, dynamic>> findProductDetailsByPlu(String pluCode, List<List<dynamic>> csvData) async {
  // Assuming the first row contains headers
  List<dynamic> headers = csvData.first;
  
  // Find the row with the matching PLU code
  Map<String, dynamic> productDetails = {};
  for (var row in csvData.skip(1)) { // Skip the header row
    if (row[headers.indexOf("Plu")].toString() == pluCode) {
      // Extract and return the Category and Commodity
      productDetails['Category'] = row[headers.indexOf("Category")];
      productDetails['Commodity'] = row[headers.indexOf("Commodity")];
      break;
    }
  }
  return productDetails;
}

void getProductDetails(String pluCode) async {
  try {
    List<List<dynamic>> csvData = await parseCSV('externalDB/ifps_plu.csv');
    Map<String, dynamic> productDetails = await findProductDetailsByPlu(pluCode, csvData);
    
    //#TO-DO: Replace below logic with reading in PLU to record food entry
    if (productDetails.isNotEmpty) {
      debugPrint("Category: ${productDetails['Category']}, Commodity: ${productDetails['Commodity']}");
      //Use commodity value to search against Spoonacular Search By Ingredient function to get nutrient information
    } else {
      debugPrint("Product with PLU code $pluCode not found.");
    }
  } catch (e) {
    debugPrint("An error occurred: $e");
  }
}


//Example GET response: https://api.spoonacular.com/food/ingredients/search?apiKey=41a82396931e43039ec29a6356ec8dc1&includeNutrition=true&query=artichoke&number=2
Future<Map<String, dynamic>?> fetchIngredientInfo(String ingredient) async {
  const String apiKey = '41a82396931e43039ec29a6356ec8dc1'; 
  const String url = 'https://api.spoonacular.com/food/ingredients/search';
  final Uri uri = Uri.parse(url + '?query=$ingredient&apiKey=$apiKey&number=1');

  try {
    final response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'].isNotEmpty) {
        int id = data['results'][0]['id']; // Get the ID of the ingredient
        return fetchIngredientNutrition(id, apiKey); // Fetch detailed nutrition info
      }
      return null;
    } else {
      throw Exception('Failed to load ingredient info');
    }
  } catch (e) {
    print(e.toString());
    return null;
  }
}

Future<Map<String, dynamic>?> fetchIngredientNutrition(int id, String apiKey) async {
  final String url = 'https://api.spoonacular.com/food/ingredients/$id/information';
  final Uri uri = Uri.parse(url + '?apiKey=$apiKey&amount=1');

  try {
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load nutrition details');
    }
  } catch (e) {
    print(e.toString());
    return null;
  }
}
