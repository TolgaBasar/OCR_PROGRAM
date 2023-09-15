import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'crop_image.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MaterialApp(
    home: MainScreen(),
  ));
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool isPermissionGranted = false;
  late final Future<void> _future;
  CameraController? _cameraController;


  @override
  void initState() {
    super.initState();
    _future = _requestCameraPermission();
    _initCamera();
  }
  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      isPermissionGranted = status == PermissionStatus.granted;
    });
  }

  Future<void> _initCamera() async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
    }

    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      final camera = cameras.first;
      _cameraController = CameraController(
        camera,
        ResolutionPreset.max,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      setState(() {});
    }
  }

  Widget _buildCameraPreview() {
    return Positioned.fill(
      child: AspectRatio(
        aspectRatio: _cameraController!.value.aspectRatio,
        child: CameraPreview(_cameraController!),
      ),
    );
  }

  Widget _buildCaptureButton() {
    return Positioned(
      bottom: 20,
      child: GestureDetector(
        onTap: () {
          _scanImage();
        },
        child: const Icon(
          Icons.photo_camera_outlined,
          size: 60,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('STAJ OCR PROGRAM'),

          ],
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: _cameraController != null && _cameraController!.value.isInitialized
          ? Stack(
        alignment: Alignment.center,
        children: [
          _buildCameraPreview(),
          _buildCaptureButton(),
        ],
      )
          : const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }



  Future<void> _scanImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    try {
      final pictureFile = await _cameraController!.takePicture();
      final file = File(pictureFile.path);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CropImage(
            imagePath: file.path,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred when scanning text'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}

