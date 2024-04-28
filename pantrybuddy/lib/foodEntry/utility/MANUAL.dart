import 'package:flutter/services.dart';
import 'package:csv/csv.dart';

//return a list of maps, each representing a row from the CSV file.
Future<List<Map<String, dynamic>>> loadCsvData(String filePath) async {
  final String csvData = await rootBundle.loadString(filePath);
  List<List<dynamic>> listData = const CsvToListConverter().convert(csvData, eol: '\n');
  List<String> headers = listData[0].map((item) => item.toString()).toList();

  List<Map<String, dynamic>> mappedData = listData.sublist(1).map((List<dynamic> row) {
    return Map.fromIterables(headers, row);
  }).toList();

  return mappedData;
}

Future<Map<String, dynamic>> prepareDropdownData(List<Map<String, dynamic>> csvData) async {
  Set<String> categoryNames = {};
  Map<String, List<String>> nameAllByCategory = {};

  for (var row in csvData) {
    String categoryName = row['Category_Name'].toString().trim(); // Ensuring to trim any whitespace
    String nameAll = row['Name_ALL'].toString().trim(); // Ensuring to trim any whitespace

    categoryNames.add(categoryName);
    if (!nameAllByCategory.containsKey(categoryName)) {
      nameAllByCategory[categoryName] = ["N/A"];
    }
    nameAllByCategory[categoryName]?.add(nameAll);
  }

  return {
    'Category_Name': categoryNames.toList(),
    'Name_ALL': nameAllByCategory
  };
}



