import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'take_picture.dart';
import 'utils/database.dart';
import 'showGallery.dart';

Future<CameraDescription> prepareCamera() async {
  List<CameraDescription> cameras = await availableCameras();
  return cameras.first;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firstCamera = await prepareCamera();

  final dbHelper = DatabaseHelper();
  await dbHelper.initDatabase();
  print(await dbHelper.getDatabase());

  // await dbHelper.initDatabaseMy();

  for (int j = 1; j < 2; j++) {
    try {
      List<Map<String, dynamic>> cards = await fetchData(j);
      await dbHelper.insertCards(cards);

      // await dbHelper.addCard('Reversal Energy', '266', '182');

      // Sprawdź, czy karty zostały zapisane
      List<Map<String, dynamic>> savedCards = await dbHelper.getMyCards();
      List<Map<String, dynamic>> savedCards2 = await dbHelper.getCards();

      print(savedCards2);
      print(savedCards2);

      // print('Page $j: ${savedCards.length} cards saved.');

      int i = 0;
      for (final card in savedCards) {
        i++;
        print(i.toString() +
            ' ID: ${card['id']}, Name: ${card['name']}, Supertype: ${card['supertype']}, HP: ${card['hp']}, Types: ${card['types']}, Number: ${card['number']}, Printed Total: ${card['set_printedTotal']}, Images Large: ${card['images_large']}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  runApp(
    MaterialApp(
      title: 'Card scanner',
      theme: ThemeData.dark(),
      home: MyHomePage(camera: firstCamera),
      // home: TakePictureScreen(
      //   // Pass the appropriate camera to the TakePictureScreen widget.
      //   camera: firstCamera,
      // ),
    ),
  );
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.camera});
  final CameraDescription camera;

  @override
  Widget build(BuildContext context) {
    double buttonWidth = MediaQuery.of(context).size.width * 0.5;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            TakePictureScreen(camera: camera)));
                return;
              },
              style: ButtonStyle(
                fixedSize: MaterialStateProperty.all(
                  Size(buttonWidth, 45.0),
                ),
              ),
              child: Text('Scan a Card'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ShowGallery()));
                return;
              },
              style: ButtonStyle(
                fixedSize: MaterialStateProperty.all(
                  Size(buttonWidth, 45.0),
                ),
              ),
              child: Text('Gallery'),
            ),
          ],
        ),
      ),
    );
  }
}
