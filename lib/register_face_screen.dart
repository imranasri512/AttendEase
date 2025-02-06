import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class RegisterFaceScreen extends StatefulWidget {
  @override
  _RegisterFaceScreenState createState() => _RegisterFaceScreenState();
}

class _RegisterFaceScreenState extends State<RegisterFaceScreen> {
  CameraController? _cameraController;
  bool _isProcessing = false;
  final FaceDetector faceDetector = FaceDetector(options: FaceDetectorOptions(enableContours: true));
  String? userEmail = FirebaseAuth.instance.currentUser?.email;
  bool isFaceRegistered = false; // ✅ Track if face is registered

  @override
  void initState() {
    super.initState();
    initCamera();
    checkIfFaceRegistered(); // ✅ Check registration status on load
  }

  /// **Check Firestore if face is already registered**
  Future<void> checkIfFaceRegistered() async {
    if (userEmail == null) return;

    final doc = await FirebaseFirestore.instance.collection('faces').doc(userEmail).get();
    setState(() {
      isFaceRegistered = doc.exists; // ✅ Update state if registered
    });
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

  /// **Register Face (Only if not registered)**
  Future<void> registerFace() async {
    if (_isProcessing || isFaceRegistered) return;

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
        return;
      }

      // Simulated face embedding (Replace with real embedding extraction)
      List<double> faceEmbedding = [0.2, 0.5, 0.7, 0.3];

      // Store face data in Firestore
      await FirebaseFirestore.instance.collection('faces').doc(userEmail).set({
        'email': userEmail,
        'face_embedding': faceEmbedding,
      });

      setState(() {
        isFaceRegistered = true; // ✅ Prevent re-registration
        _isProcessing = false;
      });

      print("✅ Face Registered Successfully!");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Face Registered Successfully!")));

    } catch (error) {
      print("❌ Face Registration Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to register face.")));
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register Face")),
      body: _cameraController == null || !_cameraController!.value.isInitialized
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(child: CameraPreview(_cameraController!)),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      isFaceRegistered
                          ? Text("✅ Face already registered!", style: TextStyle(color: Colors.green, fontSize: 16))
                          : ElevatedButton(
                              onPressed: registerFace,
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                              child: _isProcessing
                                  ? CircularProgressIndicator(color: Colors.white)
                                  : Text("Capture & Register Face"),
                            ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                        child: Text("Back"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
