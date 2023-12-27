import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:test/test.dart';
import 'package:card_scanner/take_picture.dart';

Future<File> getImageFileFromAssets(String path) async {
  final byteData = await rootBundle.load('assets/$path');

  final file = File('${(await getTemporaryDirectory()).path}/$path');
  await file.create(recursive: true);
  await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

  return file;
}
void main(){
  WidgetsFlutterBinding.ensureInitialized();
  test('Inkey 077/196', () async {
    print("🟢 Siema");
    File testPicture = await getImageFileFromAssets('images/test_pokemon_card.jpg');
    final resutl = await analizePicture(testPicture);
    print('🟢 ${resutl.cardName} ${resutl.cardNumber.toString()} ${resutl.setTotal.toString()}'); 
    expect(PredictionResults("Inkay", 77, 196), resutl);
  });
}