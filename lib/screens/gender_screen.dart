import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:work_out_app/screens/weight_screen.dart';


enum Gender { male, female, preferNotToSay }

class SelectGenderScreen extends StatefulWidget {
  const SelectGenderScreen({super.key});

  @override
  State<SelectGenderScreen> createState() => _SelectGenderScreenState();
}

class _SelectGenderScreenState extends State<SelectGenderScreen> {
  final Color primaryOrange = const Color(0xFFFF7043);
  final Color darkBlack = const Color(0xFF1A1D26);
  final Color lightGrey = const Color(0xFFC7C7C7);
  
  Gender? _selectedGender;
  bool _isSaving = false;

  Widget _buildGenderCard(Gender gender, IconData icon, String label) {
    final isSelected = _selectedGender == gender;
    
    return InkWell(
      onTap: () => setState(() => _selectedGender = gender),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? primaryOrange.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryOrange : lightGrey.withOpacity(0.5),
            width: isSelected ? 2.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: isSelected ? primaryOrange : darkBlack),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: darkBlack)),
          ],
        ),
      ),
    );
  }

  void saveGenderAndContinue() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar("Error", "User not logged in.", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => _isSaving = true);

    try {
      await FirebaseDatabase.instance.ref('users/${user.uid}/assessment').update({
        'gender': _selectedGender.toString().split('.').last,
        'lastUpdated_gender': DateTime.now().toIso8601String(),
      });
      
      Get.to(() => const  WeightSelectionScreen());

    } catch (e) {
      Get.snackbar("Error", "Failed to save: $e", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black), onPressed: () => Get.back()),
        title: Text('Assessment', style: TextStyle(color: darkBlack, fontWeight: FontWeight.bold)),
        actions: [Center(child: Padding(padding: EdgeInsets.only(right: 16), child: Text('3 of 4', style: TextStyle(color: darkBlack, fontWeight: FontWeight.w600))))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("What's your Gender?", style: TextStyle(color: darkBlack, fontSize: 30, fontWeight: FontWeight.w800)),
            const SizedBox(height: 40),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  _buildGenderCard(Gender.male, Icons.male_rounded, "Male"),
                  _buildGenderCard(Gender.female, Icons.female_rounded, "Female"),
                  _buildGenderCard(Gender.preferNotToSay, Icons.close_rounded, "Other"),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isSaving || _selectedGender == null ? null : saveGenderAndContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkBlack,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: _isSaving ? CircularProgressIndicator(color: Colors.white) : Text("Continue", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}