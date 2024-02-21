import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

Future<String?> scanBarcode() async {
  try {
    final barcode = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666', // Color
      'Cancel', // Cancel button text
      true, // Show flash icon
      ScanMode.BARCODE, // Scan mode
    );

    if (barcode == '-1') {
      debugPrint('Barcode scanning cancelled');
      return null;
    }

    return barcode;
  } catch (e) {
    debugPrint('Barcode scanning error: $e');
    return null;
  }
}