import 'dart:async';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase_options.dart';
import 'classifier.dart';

const String KEY_WALKING = 'walking_sec';
const String KEY_JOGGING = 'jogging_sec';
const String KEY_SITTING = 'sitting_sec';
const String KEY_STANDING = 'standing_sec';
const String KEY_FALLS = 'fall_count';
const String KEY_DATE = 'last_active_date';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', 'Fiter Tracking',
    description: 'Background Service',
    importance: Importance.low,
  );
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'Fiter AI',
      initialNotificationContent: 'Active',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
    ),
  );
  service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  try { await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); } catch (e) {}

  final prefs = await SharedPreferences.getInstance();
  final classifier = ActivityClassifier();
  await classifier.loadModel();

  List<double> _acc = [0, 0, 0];
  List<double> _gyro = [0, 0, 0];
  List<double> _mag = [0, 0, 0];
  List<double> _smoothAcc = [0, 0, 0];
  List<double> _smoothMag = [0, 0, 0];

  List<List<double>> _windowBuffer = [];
  bool _isPredicting = false; // Lock to prevent overlap crashes

  accelerometerEvents.listen((event) {
    _acc = [event.x, event.y, event.z];
    for(int i=0; i<3; i++) _smoothAcc[i] = (_smoothAcc[i]*0.9) + (_acc[i]*0.1);
  });
  gyroscopeEvents.listen((event) => _gyro = [event.x, event.y, event.z]);
  magnetometerEvents.listen((event) {
    _mag = [event.x, event.y, event.z];
    for(int i=0; i<3; i++) _smoothMag[i] = (_smoothMag[i]*0.9) + (_mag[i]*0.1);
  });

  // 50Hz Loop
  Timer.periodic(const Duration(milliseconds: 20), (timer) async {
    if (_acc.every((v) => v == 0)) return;

    List<double> _ori = _calculateOrientationDegrees(_smoothAcc, _smoothMag);
    
    // UI Update (Throttle)
    if (timer.tick % 50 == 0) {
       service.invoke('sensor_update', {'acc': _acc, 'gyro': _gyro, 'mag': _ori});
    }

    // Prepare Features [acc_x, acc_y, acc_z, gyro_x, gyro_y, gyro_z, ori_y, ori_z]
    // Note: ori_x is skipped as per your training code
    List<double> features = [
      _acc[0], _acc[1], _acc[2],
      _gyro[0], _gyro[1], _gyro[2],
      _ori[1], _ori[2]
    ];

    _windowBuffer.add(features);

    // Predict if buffer is full AND not currently predicting
    if (_windowBuffer.length >= 128 && !_isPredicting) {
        _isPredicting = true;
        
        try {
          // Slice exactly 128 (Safety for the 129 bug)
          List<List<double>> exactInput = _windowBuffer.sublist(_windowBuffer.length - 128);
          
          String activity = classifier.predict(exactInput);
          
          // Physics Fall Check (Backup)
          if (activity == 'Falling' && !_isRealFall(exactInput)) {
             activity = 'Sitting';
          }

          await _updateStats(prefs, activity, service);
          service.invoke('prediction_update', {'activity': activity, 'confidence': ''});
          
          // Slide Window: Remove oldest 28, Keep newest 100 for overlap
          // Ensure we don't crash if length changed
          if (_windowBuffer.length >= 28) {
             _windowBuffer.removeRange(0, 28);
          }
        } catch (e) {
          print("Loop Error: $e");
          _windowBuffer.clear();
        } finally {
          _isPredicting = false;
        }
    }
  });

  service.on('get_stats').listen((event) => _broadcastStats(service, prefs));
}

// --- HELPER LOGIC ---

bool _isRealFall(List<List<double>> buffer) {
  double maxMag = 0.0;
  for (var row in buffer) {
    // Row is Raw values here
    double mag = math.sqrt(row[0]*row[0] + row[1]*row[1] + row[2]*row[2]);
    if (mag > maxMag) maxMag = mag;
  }
  return maxMag > 18.0; // >1.8G impact
}

List<double> _calculateOrientationDegrees(List<double> acc, List<double> mag) {
  if (acc.every((e) => e == 0) || mag.every((e) => e == 0)) return [0.0, 0.0, 0.0];
  try {
    final vector.Vector3 a = vector.Vector3(acc[0], acc[1], acc[2])..normalize();
    final vector.Vector3 m = vector.Vector3(mag[0], mag[1], mag[2])..normalize();
    final vector.Vector3 h = m.cross(a)..normalize();
    final vector.Vector3 m_norm = a.cross(h)..normalize();
    double clampedAy = (-a.y).clamp(-1.0, 1.0);
    double pitch = math.asin(clampedAy) * 57.29;
    double roll = math.atan2(a.x, a.z) * 57.29;
    double yaw = math.atan2(h.y, m_norm.y) * 57.29;
    return [yaw, roll, pitch];
  } catch (e) {
    return [0.0, 0.0, 0.0];
  }
}

Future<void> _updateStats(SharedPreferences prefs, String activity, ServiceInstance service) async {
  if (activity == "Error" || activity == "Buffering...") return;
  const double duration = 0.56; 
  await _checkDayReset(prefs);

  if (activity == 'Falling') {
    int now = DateTime.now().millisecondsSinceEpoch;
    int lastFall = prefs.getInt('last_fall_ts') ?? 0;
    if (now - lastFall > 5000) { // Debounce 5s
      await prefs.setInt(KEY_FALLS, (prefs.getInt(KEY_FALLS) ?? 0) + 1);
      await prefs.setInt('last_fall_ts', now);
      _showNotification("Fall Detected!", "Are you okay?");
    }
  } else {
    String key = '';
    if (activity == 'Walking') key = KEY_WALKING;
    if (activity == 'Jogging') key = KEY_JOGGING;
    if (activity == 'Sitting') key = KEY_SITTING;
    if (activity == 'Standing') key = KEY_STANDING;
    if (key.isNotEmpty) {
      await prefs.setDouble(key, (prefs.getDouble(key) ?? 0.0) + duration);
    }
  }

  if (service is AndroidServiceInstance && await service.isForegroundService()) {
      service.setForegroundNotificationInfo(title: "Fiter AI", content: "Current: $activity");
  }
  _broadcastStats(service, prefs);
}

void _broadcastStats(ServiceInstance service, SharedPreferences prefs) {
  service.invoke('stats_update', {
    'walking': prefs.getDouble(KEY_WALKING) ?? 0.0,
    'jogging': prefs.getDouble(KEY_JOGGING) ?? 0.0,
    'sitting': prefs.getDouble(KEY_SITTING) ?? 0.0,
    'standing': prefs.getDouble(KEY_STANDING) ?? 0.0,
    'falls': prefs.getInt(KEY_FALLS) ?? 0,
  });
}

Future<void> _checkDayReset(SharedPreferences prefs) async {
  String today = DateTime.now().toIso8601String().split('T')[0];
  if (prefs.getString(KEY_DATE) != today) {
    // Save to firebase ...
    for (var key in [KEY_WALKING, KEY_JOGGING, KEY_SITTING, KEY_STANDING, KEY_FALLS]) {
       if (key == KEY_FALLS) await prefs.setInt(key, 0); else await prefs.setDouble(key, 0);
    }
    await prefs.setString(KEY_DATE, today);
  }
}

void _showNotification(String title, String body) {
  final FlutterLocalNotificationsPlugin flnp = FlutterLocalNotificationsPlugin();
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'fall_channel', 'Fall Alerts', importance: Importance.max, priority: Priority.high);
  flnp.show(999, title, body, NotificationDetails(android: androidDetails));
}