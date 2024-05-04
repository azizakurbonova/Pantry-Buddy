import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';

Future<List<List<dynamic>>> loadCsv(String assetPath) async {
  WidgetsFlutterBinding.ensureInitialized();
  final csvString = await rootBundle.loadString(assetPath);
  List<List<dynamic>> csvData = const CsvToListConverter().convert(csvString);
  return csvData;
}

List<Map<String, dynamic>> parseCsv(List<List<dynamic>> csvData) {
  WidgetsFlutterBinding.ensureInitialized();
  List<String> headers = csvData[0].cast<String>();
  List<Map<String, dynamic>> data = [];
  for (final row in csvData.skip(1)) {
    Map<String, dynamic> dataRow = Map.fromIterables(headers, row);
    data.add(dataRow);
  }
  return data;
}
