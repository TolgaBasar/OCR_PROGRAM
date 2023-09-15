import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'result_screen.dart';
class CropImage extends StatefulWidget {
  final String imagePath;
  const CropImage({Key? key, required this.imagePath}) : super(key: key);
  @override
  _CropImageState createState() => _CropImageState();
}
class _CropImageState extends State<CropImage> {
  File? _croppedImage;
  late String _extractedText;
  Future<void> _cropImage() async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: widget.imagePath,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9,
      ],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.blueAccent,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Cropper',
          cancelButtonTitle: 'İptal',
          doneButtonTitle: 'Tamam',
          rectX: 1,
          rectY: 1,
          rectWidth: 1,
          rectHeight: 1,
          minimumAspectRatio: 1.0,
        ),
      ],
    );
    if (croppedFile != null) {
      setState(() {
        _croppedImage = File(croppedFile.path);
      });
    }
  }
  Future<void> _extractText() async {
    if (_croppedImage != null) {
      final inputImage = InputImage.fromFile(_croppedImage!);
      final textRecognizer = GoogleMlKit.vision.textRecognizer();
      final visionText = await textRecognizer.processImage(inputImage);
      textRecognizer.close();
      setState(() {
        _extractedText = visionText.text;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            imagePath: _croppedImage!.path,
            extractedText: _extractedText,
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text('Hata'),
            content: Text('Önce bir resim kırpın ve metin çıkarın.'),
          );
        },
      );
    }
  }


  Widget _buildImage() {
    return Expanded(
      child: Center(
        child: _croppedImage != null
            ? Image.file(_croppedImage!)
            : Image.file(File(widget.imagePath)),
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _cropImage,
          icon: const Icon(
            Icons.crop,
            color: Colors.white,
            size: 32,
          ),
          label: const Text(
            'Crop',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
        ),
        ElevatedButton(
          onPressed: _extractText,
          child: const Text(
            'Continue',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
        ),
      ],
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Image'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildImage(),
          _buildButtons(),
        ],
      ),
    );
  }
}

