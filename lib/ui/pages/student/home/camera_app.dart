import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'image_preview.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key, required this.cameras}) : super(key: key);

  final List<CameraDescription>? cameras;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;
  late Future<void> _initializeCameraFuture;
  bool _isRearCameraSelected = true;

  @override
  void initState() {
    super.initState();
    _initializeCameraFuture = initCamera(widget.cameras![0]);
    requestLocationPermission();
  }

  Future<void> initCamera(CameraDescription cameraDescription) async {
    _cameraController = CameraController(cameraDescription, ResolutionPreset.high);
    try {
      await _cameraController.initialize();
      setState(() {});
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }

  Future<void> takePicture() async {
    if (!_cameraController.value.isInitialized || _cameraController.value.isTakingPicture) {
      return;
    }
    try {
      await _cameraController.setFlashMode(FlashMode.off);
      XFile picture = await _cameraController.takePicture();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewPage(picture: picture),
        ),
      );
    } on CameraException catch (e) {
      debugPrint('Error occurred while taking picture: $e');
    }
  }

  void requestLocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF962038),
      body: SafeArea(
        child: FutureBuilder<void>(
          future: _initializeCameraFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Stack(
                children: [
                  CameraPreview(_cameraController),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.20,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        color: Colors.black,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              iconSize: 30,
                              icon: Icon(
                                _isRearCameraSelected
                                    ? Icons.flip_camera_ios
                                    : Icons.flip_camera_ios_outlined,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() => _isRearCameraSelected = !_isRearCameraSelected);
                                initCamera(widget.cameras![_isRearCameraSelected ? 0 : 1]);
                              },
                            ),
                          ),
                          Expanded(
                            child: IconButton(
                              onPressed: takePicture,
                              iconSize: 50,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(Icons.camera, color: Colors.white),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Container(
                color: Colors.black,
                child: const Center(child: CircularProgressIndicator()),
              );
            }
          },
        ),
      ),
    );
  }
}
