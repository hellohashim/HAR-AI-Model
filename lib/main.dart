import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Needed for AssetBundle
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'firebase_options.dart';
import 'screens/wrapper.dart';
import 'services/background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- ASSET DETECTIVE START ---
  // This will print every file Flutter can see.
  // Look for your .tflite file in the Debug Console!
  try {
    final AssetBundle bundle = rootBundle;
    final String manifestJson = await bundle.loadString('AssetManifest.json');
    print("📂 FOUND ASSETS: $manifestJson");
  } catch (e) {
    print("❌ Cannot list assets: $e");
  }
  // --- ASSET DETECTIVE END ---

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await _requestPermissions();
  
  try {
    await initializeService();
  } catch (e) {
    print("❌ Service Error: $e");
  }

  runApp(const WorkoutApp());
}

// ... Keep the rest of your main.dart (_requestPermissions and WorkoutApp) the same
Future<void> _requestPermissions() async {
  await [
    Permission.activityRecognition,
    Permission.sensors,
    Permission.notification,
    Permission.location,
    Permission.ignoreBatteryOptimizations,
  ].request();
}

class WorkoutApp extends StatelessWidget {
  const WorkoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Workout Tracker',
      theme: ThemeData(
        brightness: Brightness.dark, 
        scaffoldBackgroundColor: const Color(0xFF121212),
        useMaterial3: true,
      ),
      home: Wrapper(), 
    );
  }
}