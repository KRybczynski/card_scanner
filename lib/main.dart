import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'register_screen.dart';
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

  // Sprawdź, czy użytkownik jest już zalogowany
  final prefs = await SharedPreferences.getInstance();
  String? savedUsername = prefs.getString('username');

  runApp(
    MaterialApp(
      title: 'Card scanner',
      theme: ThemeData.dark(),
      home: savedUsername == null ? RegisterScreen() : LoginScreen(),
    ),
  );
}

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key, required this.camera});
  final CameraDescription camera;
  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    double buttonWidth = MediaQuery.of(context).size.width * 0.5;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () async {
              await dbHelper.syncCardsWithApi();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Database synchronized with Pokemon TCG API'),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
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
                child: const Text('Scan a Card'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ShowGallery(),
                    ),
                  );
                },
                style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all(
                    Size(buttonWidth, 45.0),
                  ),
                ),
                child: const Text('Gallery'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DeckManager(),
                    ),
                  );
                },
                style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all(
                    Size(buttonWidth, 45.0),
                  ),
                ),
                child: const Text('Decks'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
