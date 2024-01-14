// A screen that allows users to take a picture using a given camera.
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'utils/database.dart';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class PredictionResults {
  String cardName;
  int cardNumber, setTotal;
  PredictionResults(this.cardName, this.cardNumber, this.setTotal);
  @override
  bool operator ==(other) =>
      other is PredictionResults &&
      cardName == other.cardName &&
      cardNumber == other.cardNumber &&
      setTotal == other.setTotal;
  @override
  int get hashCode =>
      cardName.hashCode ^ cardNumber.hashCode ^ setTotal.hashCode;
}

class PictureAnalysisException implements Exception {
  String cause;
  PictureAnalysisException(this.cause);
}

Future<PredictionResults> analizePicture(File file) async {
  final inputImage = InputImage.fromFile(file);
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  RegExp pattern = RegExp(r"\d+\/\d+");

  final RecognizedText recognizedText =
      await textRecognizer.processImage(inputImage);
  String text = recognizedText.text;
  final textArray = text.split('\n');
  if (textArray.length == 1) {
    throw PictureAnalysisException("No text found");
  }
  String cardName = textArray[1];

  for (final text in textArray) {
    RegExpMatch? match = pattern.firstMatch(text);
    if (match != null) {
      final cardNumber = text.substring(match.start, match.end).split('/');
      return PredictionResults(
          cardName, int.parse(cardNumber[0]), int.parse(cardNumber[1]));
    }
  }
  textRecognizer.close();
  throw PictureAnalysisException("Card number not found");
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan a card')),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _controller.takePicture();

            if (!mounted) return;
            final resutl = await analizePicture(File(image.path));
            Fluttertoast.showToast(
                msg:
                    "${resutl.cardName} ${resutl.cardNumber} ${resutl.setTotal}");

            print(
                '------------------------------------------------------------------------------------------');
            print(
                '------------------------------------------------------------------------------------------');
            print(
                '------------------------------------------------------------------------------------------');
            print(
                '------------------------------------------------------------------------------------------');

            final dbHelper = DatabaseHelper();

            await dbHelper.addCard(resutl.cardName,
                resutl.cardNumber.toString(), resutl.setTotal.toString());
            List<Map<String, dynamic>> savedCards =
                await dbHelper.get_my_cards();
            print(savedCards);

            int i = 0;

            for (final card in savedCards) {
              i++;
              print(i.toString() +
                  ' ID: ${card['id']}, Name: ${card['name']}, Supertype: ${card['supertype']}, HP: ${card['hp']}, Types: ${card['types']}, Number: ${card['number']}, Printed Total: ${card['set_printedTotal']}, Images Large: ${card['images_large']}');
            }
            print(
                '------------------------------------------------------------------------------------------');
            print(
                '------------------------------------------------------------------------------------------');
            print(
                '------------------------------------------------------------------------------------------');
            print(
                '------------------------------------------------------------------------------------------');

            // If the picture was taken, display it on a new screen.
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  // Pass the automatically generated path to
                  // the DisplayPictureScreen widget.
                  imagePath: image.path,
                ),
              ),
            );
          } on PictureAnalysisException {
            Fluttertoast.showToast(msg: "🔴 Error when analyzing picture");
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
    );
  }
}
