import 'package:tflite_flutter/tflite_flutter.dart';

class FaceRecognitionService {
  late Interpreter _interpreter;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/facenet.tflite');
      print("✅ Face recognition model loaded successfully!");
    } catch (e) {
      print("❌ Error loading model: $e");
    }
  }
}
