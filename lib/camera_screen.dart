import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  bool _isProcessing = false;
  final FaceDetector faceDetector = FaceDetector(options: FaceDetectorOptions(
    enableContours: true,
    enableClassification: true,
  ));

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  /// **Initialize Front Camera**
  Future<void> initCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(frontCamera, ResolutionPreset.medium);
    await _cameraController!.initialize();
    setState(() {});
  }

  /// **Capture Face & Verify Attendance**
  Future<void> captureAndProcessImage() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final image = await _cameraController!.takePicture();
      File imageFile = File(image.path);
      print("✅ Image Captured: ${imageFile.path}");

      // Detect face
      final inputImage = InputImage.fromFile(imageFile);
      final List<Face> faces = await faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        setState(() => _isProcessing = false);
        print("❌ No face detected!");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No face detected! Try again.")));
        Navigator.pop(context, false);
        return;
      }

      print("✅ Face Verified!");
      Navigator.pop(context, true);

    } catch (error) {
      print("❌ Face Detection Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to detect face.")));
      Navigator.pop(context, false);
    }

    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ Use backgroundColor instead of primary
      appBar: AppBar(
        title: Text("Face Recognition", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple, // ✅ Darker color for contrast
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _cameraController == null || !_cameraController!.value.isInitialized
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                CameraPreview(_cameraController!),
                Positioned(
                  bottom: 40,
                  left: 50,
                  right: 50,
                  child: Column(
                    children: [
                      _isProcessing
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple, // ✅ Changed from primary
                                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: captureAndProcessImage,
                              child: Text("Capture & Authenticate",
                                  style: TextStyle(fontSize: 18, color: Colors.white)),
                            ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text("Back", style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
