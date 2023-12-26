import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'take_picture.dart';

Future<CameraDescription> prepareCamera() async{
  List<CameraDescription> cameras = await availableCameras();
  return cameras.first;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firstCamera = await prepareCamera();
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
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: ()  {
                Navigator.push(context, MaterialPageRoute(builder: (context) => TakePictureScreen(camera: camera)));
                return;
              },
              child: Text('Scan a Card'),
            ),
          ],
        ),
      ),
    );
  }
}

