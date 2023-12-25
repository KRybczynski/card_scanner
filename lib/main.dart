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
      theme: ThemeData.dark(),
      home: TakePictureScreen(
        // Pass the appropriate camera to the TakePictureScreen widget.
        camera: firstCamera,
      ),
    ),
  );
}
