// ignore_for_file: avoid_dynamic_calls, avoid_print ()

// 'raw_warsh.json' was retrieved from "https://qurancomplex.gov.sa/quran-dev/"

import 'dart:io';
import 'dart:convert';

void main() async {
  // CONFIGURATION
  const inputFileName = 'raw_warsh.json';
  const outputFileName = 'warsh.json';

  final inputFile = File(inputFileName);
  final outputFile = File(outputFileName);

  if (!inputFile.existsSync()) {
    print('❌ Error: $inputFileName not found.');
    return;
  }

  print('📖 Reading $inputFileName...');
  final content = await inputFile.readAsString();

  // Parse the raw list
  // Assuming the input is a JSON Array: [ {...}, {...} ]
  final List<dynamic> rawList = jsonDecode(content) as List;

  // The Target Structure: Map<String, Map<String, String>>
  final Map<String, Map<String, String>> outputData = {};

  int count = 0;

  for (final item in rawList) {
    // Extract fields based on your description
    final surah = item['sura_no'].toString();
    final verse = item['aya_no'].toString();
    // Inside the loop where you process 'aya_text'
    final String text = item['aya_text'].toString();

    // REMOVE SYMBOLS
    // Initialize Surah Map if not exists
    if (!outputData.containsKey(surah)) {
      outputData[surah] = {};
    }

    // Add verse
    outputData[surah]![verse] = text;

    count++;
  }

  print('⚙️ Restructuring...');

  // Encode to JSON
  final jsonString = jsonEncode(outputData);

  await outputFile.writeAsString(jsonString);

  print('✅ Success!');
  print('Processed $count verses.');
  print('Saved to $outputFileName');

  // Verify size
  final size = await outputFile.length();
  print('File Size: ${(size / 1024).toStringAsFixed(2)} KB');
}
