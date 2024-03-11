//OCR Recognition of 4/5 digit PLU code, numeric only

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

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

