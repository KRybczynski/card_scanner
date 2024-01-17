import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'take_picture.dart';
import 'utils/database.dart';
import 'showGallery.dart';
import 'deckManager.dart';

Future<CameraDescription> prepareCamera() async {
  List<CameraDescription> cameras = await availableCameras();
  return cameras.first;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firstCamera = await prepareCamera();

  final dbHelper = DatabaseHelper();
  await dbHelper.initDatabase();
  // await dbHelper.initDatabaseDecks();
  print(await dbHelper.getDatabase());

  // await dbHelper.initDatabaseMy();

  for (int j = 1; j < 2; j++) {
    try {
      // List<Map<String, dynamic>> cards = await fetchData(j);
      // await dbHelper.insertCards(cards);

      // await dbHelper.addCard('Reversal Energy', '266', '182');

      // Sprawdź, czy karty zostały zapisane
      // List<Map<String, dynamic>> savedCards = await dbHelper.getMyCards();
      List<Map<String, dynamic>> savedCards2 = await dbHelper.getCards();

      print('Page $j: ${savedCards2.length} cards saved.');
      print(savedCards2.length);

      // int i = 0;
      // for (final card in savedCards) {
      //   i++;
      //   print(i.toString() +
      //       ' ID: ${card['id']}, Name: ${card['name']}, Supertype: ${card['supertype']}, HP: ${card['hp']}, Types: ${card['types']}, Number: ${card['number']}, Printed Total: ${card['set_printedTotal']}, Images Large: ${card['images_large']}');
      // }
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
  MyHomePage({Key? key, required this.camera}) : super(key: key);
  final CameraDescription camera;
  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    double buttonWidth = MediaQuery.of(context).size.width * 0.5;

    return Scaffold(
      appBar: AppBar(
        title: Text('Card Scanner'),
        actions: [
          IconButton(
            icon: Icon(Icons.sync),
            onPressed: () async {
              await dbHelper.syncCardsWithApi();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Database synchronized with Pokemon TCG API'),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/reverse.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TakePictureScreen(camera: camera),
                    ),
                  );
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShowGallery(),
                    ),
                  );
                },
                style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all(
                    Size(buttonWidth, 45.0),
                  ),
                ),
                child: Text('Gallery'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DeckManager(),
                    ),
                  );
                },
                style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all(
                    Size(buttonWidth, 45.0),
                  ),
                ),
                child: Text('Decks'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
