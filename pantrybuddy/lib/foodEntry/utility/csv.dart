import 'dart:io';
import 'package:csv/csv.dart' as csv_lib;
import 'dart:convert';

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