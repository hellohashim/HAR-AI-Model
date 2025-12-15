import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:work_out_app/services/background_service.dart';

const Color kBackgroundColor = Color(0xFF121212);
const Color kCardColor = Color(0xFF1E1E1E);
const Color kAccentGreen = Color(0xFFC0F83F);
const Color kTextWhite = Colors.white;
const Color kTextGrey = Colors.grey;
const Color kAlertRed = Color(0xFFFF5252);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  File? _localProfileImage;
  String? _profileImageUrl;
  final ImagePicker _picker = ImagePicker();
  final currentUser = FirebaseAuth.instance.currentUser;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  String _currentStatus = "Waiting...";
  String _currentConfidence = "0%";
  String _lastUpdateTime = "--:--:--";
  List<double> _acc = [0,0,0];
  List<double> _gyro = [0,0,0];
  List<double> _mag = [0,0,0];

  @override
  void initState() {
    super.initState();
    _loadProfileImageUrl();
    initializeService(); 

    FlutterBackgroundService().on('sensor_update').listen((event) {
      if (event != null && mounted) {
        setState(() {
          _acc = List<double>.from(event['acc'] ?? [0,0,0]);
          _gyro = List<double>.from(event['gyro'] ?? [0,0,0]);
          _mag = List<double>.from(event['mag'] ?? [0,0,0]); 
        });
      }
    });

    FlutterBackgroundService().on('prediction_update').listen((event) {
      if (event != null && mounted) {
        setState(() {
          _currentStatus = event['activity'] ?? "Unknown";
          _currentConfidence = event['confidence'] ?? "0%";
          final now = DateTime.now();
          _lastUpdateTime = "${now.hour}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
        });
      }
    });
  }

  String _formatDuration(double seconds) {
    if (seconds == 0) return "0m";
    final d = Duration(seconds: seconds.toInt());
    return "${d.inHours}h ${d.inMinutes.remainder(60)}m";
  }

  Future<void> _loadProfileImageUrl() async {
    if (currentUser == null) return;
    final snap = await _dbRef.child('users/${currentUser!.uid}/profileImageUrl').get();
    if (snap.exists && snap.value is String) {
      setState(() { _profileImageUrl = snap.value as String; });
    }
  }

  Future<void> _pickAndUploadProfilePhoto() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        File file = File(pickedFile.path);
        setState(() { _localProfileImage = file; });
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_profile_images/${currentUser?.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');
        final uploadTask = await storageRef.putFile(file);
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        if (currentUser != null) {
          await _dbRef.child('users/${currentUser!.uid}/profileImageUrl').set(downloadUrl);
          setState(() { _profileImageUrl = downloadUrl; });
        }
      }
    } catch (e) {
      debugPrint("Error picking or uploading image: $e");
    }
  }

  void _handleSignOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: kBackgroundColor,
      drawer: Drawer(
        backgroundColor: kCardColor,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: kCardColor),
              accountName: const Text("Fiter", style: TextStyle(color: kTextWhite, fontSize: 18, fontWeight: FontWeight.bold)),
              accountEmail: Text('${currentUser?.email}', style: const TextStyle(color: kTextGrey)),
              currentAccountPicture: GestureDetector(
                onTap: _pickAndUploadProfilePhoto,
                child: CircleAvatar(
                  backgroundColor: kBackgroundColor,
                  backgroundImage: _profileImageUrl != null ? NetworkImage(_profileImageUrl!) : (_localProfileImage != null ? FileImage(_localProfileImage!) as ImageProvider : null),
                  child: (_profileImageUrl == null && _localProfileImage == null) ? const Icon(Icons.person, color: kTextWhite) : null,
                ),
              ),
            ),
            const Spacer(),
            const Divider(color: kTextGrey),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text("Sign Out", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              onTap: _handleSignOut,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<Map<String, dynamic>?>(
          stream: FlutterBackgroundService().on('stats_update'),
          builder: (context, snapshot) {
            double walkingSec = 0;
            double joggingSec = 0;
            double sittingSec = 0;
            double standingSec = 0;
            int fallCount = 0;

            if (snapshot.hasData && snapshot.data != null) {
              final data = snapshot.data!;
              walkingSec = (data['walking'] as num?)?.toDouble() ?? 0;
              joggingSec = (data['jogging'] as num?)?.toDouble() ?? 0;
              sittingSec = (data['sitting'] as num?)?.toDouble() ?? 0;
              standingSec = (data['standing'] as num?)?.toDouble() ?? 0;
              fallCount = (data['falls'] as num?)?.toInt() ?? 0;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 30),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Daily Report", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kTextWhite)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: kAccentGreen.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                        child: Text("Now: $_currentStatus", style: const TextStyle(color: kAccentGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: StatCard(title: "Walking", valueText: _formatDuration(walkingSec), goalText: "Goal: 1h", percent: (walkingSec / 3600).clamp(0.0, 1.0), icon: Icons.directions_walk)),
                      const SizedBox(width: 10),
                      Expanded(child: StatCard(title: "Jogging", valueText: _formatDuration(joggingSec), goalText: "Goal: 30m", percent: (joggingSec / 1800).clamp(0.0, 1.0), icon: Icons.directions_run)),
                      const SizedBox(width: 10),
                      Expanded(child: StatCard(title: "Standing", valueText: _formatDuration(standingSec), goalText: "Goal: 2h", percent: (standingSec / 7200).clamp(0.0, 1.0), icon: Icons.accessibility)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: StatCard(title: "Sitting", valueText: _formatDuration(sittingSec), goalText: "Max: 8h", percent: (sittingSec / 28800).clamp(0.0, 1.0), icon: Icons.chair)),
                      const SizedBox(width: 10),
                      Expanded(child: StatCard(title: "Falls Count", valueText: "$fallCount", goalText: "Falls" , percent: (fallCount > 0 ? 1.0 : 0.0), icon: Icons.personal_injury, isAlert: true)),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text("Sensor Debugging", style: TextStyle(color: kTextGrey, fontSize: 12)),
                  const SizedBox(height: 5),
                  _buildSensorDebugRow("Accel", _acc),
                  _buildSensorDebugRow("Gyro", _gyro),
                  // Removed Yaw (Ori X). Showing only Roll (Y) and Pitch (Z)
                  _buildSensorDebugRow("Orient (Calc)", [0.0, _mag[1], _mag[2]]), 
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: kCardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kAccentGreen.withOpacity(0.5)),
                      boxShadow: [BoxShadow(color: kAccentGreen.withOpacity(0.05), blurRadius: 10, spreadRadius: 1)]
                    ),
                    child: Column(
                      children: [
                        const Text("AI MODEL DECISION", style: TextStyle(color: kTextGrey, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(_currentStatus.toUpperCase(), style: const TextStyle(color: kAccentGreen, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                        const SizedBox(height: 8),
                        Text("Updated: $_lastUpdateTime", style: TextStyle(color: kTextGrey.withOpacity(0.5), fontSize: 10)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () { FlutterBackgroundService().startService(); },
                      style: ElevatedButton.styleFrom(backgroundColor: kAccentGreen, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text("Start Workout", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kBackgroundColor)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSensorDebugRow(String name, List<double> vals) {
    return Text(
      "$name: X:${vals[0].toStringAsFixed(1)} Y:${vals[1].toStringAsFixed(1)} Z:${vals[2].toStringAsFixed(1)}",
      style: const TextStyle(color: kTextGrey, fontSize: 10, fontFamily: "monospace"),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        IconButton(icon: const Icon(Icons.menu, color: kTextWhite), onPressed: () => _scaffoldKey.currentState?.openDrawer()),
        GestureDetector(
          onTap: _pickAndUploadProfilePhoto,
          child: CircleAvatar(
            radius: 24,
            backgroundColor: kTextGrey.withOpacity(0.3),
            backgroundImage: _profileImageUrl != null ? NetworkImage(_profileImageUrl!) : (_localProfileImage != null ? FileImage(_localProfileImage!) as ImageProvider : null),
            child: (_profileImageUrl == null && _localProfileImage == null) ? const Icon(Icons.person, color: kTextWhite) : null,
          ),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome, Fiter", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextWhite)),
            Text("ProAthlete", style: TextStyle(color: kTextGrey, fontSize: 14)),
          ],
        ),
        const Spacer(),
        IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: kAccentGreen, size: 28)),
        Stack(
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.notifications, color: kAccentGreen, size: 28)),
            Positioned(right: 8, top: 8, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: const Text('1', style: TextStyle(fontSize: 10, color: Colors.white)))),
          ],
        ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String valueText;
  final String goalText;
  final double percent;
  final IconData icon;
  final bool isAlert;
  const StatCard({super.key, required this.title, required this.valueText, required this.goalText, required this.percent, required this.icon, this.isAlert = false});
  @override
  Widget build(BuildContext context) {
    final Color mainColor = isAlert ? kAlertRed : kAccentGreen;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: kCardColor, borderRadius: BorderRadius.circular(16), border: isAlert ? Border.all(color: kAlertRed.withOpacity(0.5)) : null),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: mainColor, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(valueText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: kTextWhite)), const SizedBox(height: 5), Text(goalText, style: TextStyle(color: kTextGrey.withOpacity(0.8), fontSize: 10))])),
              SizedBox(height: 45, width: 45, child: Stack(fit: StackFit.expand, children: [CircularProgressIndicator(value: 1.0, valueColor: AlwaysStoppedAnimation<Color>(kTextGrey.withOpacity(0.2)), strokeWidth: 4), CircularProgressIndicator(value: percent.clamp(0.0, 1.0), valueColor: AlwaysStoppedAnimation<Color>(mainColor), backgroundColor: Colors.transparent, strokeWidth: 4, strokeCap: StrokeCap.round), Center(child: Icon(icon, color: mainColor, size: 20))]))
            ],
          ),
        ],
      ),
    );
  }
}