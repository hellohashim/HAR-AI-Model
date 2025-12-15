import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:work_out_app/screens/home_screen.dart';
import 'package:work_out_app/screens/wrapper.dart';

class NextAssessmentScreen extends StatelessWidget {
  const NextAssessmentScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Assessment Complete")),
      body: const Center(child: Text("Assessment Flow Complete!")),
    );
  }
}

class WeightSelectionScreen extends StatefulWidget {
  const WeightSelectionScreen({super.key});

  @override
  State<WeightSelectionScreen> createState() => _WeightSelectionScreenState();
}

class _WeightSelectionScreenState extends State<WeightSelectionScreen> {
  // --- UI Colors based on the image ---
  final Color primaryRed = const Color(0xFFEF5350); // Coral/Red color
  final Color bgWhite = Colors.white;
  final Color textBlack = const Color(0xFF2D3142);
  final Color textGrey = const Color(0xFF9E9E9E);
  final Color btnGrey = const Color(0xFFF5F5F5);
  final Color rulerGrey = const Color(0xFFE0E0E0);
  final Color keyboardBg = const Color(0xFFCFD3D9); // Standard iOS keyboard grey

  // --- State ---
  double _currentWeight = 60.0; // Default starting weight (Kg)
  bool _isSaving = false;

  // --- Ruler Config ---
  final int minWeight = 20;
  final int maxWeight = 200;
  final double itemWidth = 60.0; // Wider spacing for cleaner look
  late ScrollController _scrollController;
  bool _isKeyboardInput = false; // Flag to prevent scroll loops

  @override
  void initState() {
    super.initState();
    // Initialize scroll controller to center the starting weight
    // We pad the list with empty items so the first/last values can be centered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToWeight(_currentWeight);
    });
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Helper to scroll the ruler to a specific weight value
  void _scrollToWeight(double weight) {
    if (!_scrollController.hasClients) return;
    double offset = (weight - minWeight) * itemWidth;
    _scrollController.jumpTo(offset);
  }

  // --- Logic: Handle Keypad Input ---
  void _onKeyTap(String value) {
    String currentString = _currentWeight.toInt().toString();
    
    // If it's a single digit reset (optional UX choice, sticking to append for now)
    // Here we append numbers. Max 3 digits for weight usually.
    if (currentString.length >= 3) return; 

    // If current weight is the default 0 or we just started typing, maybe replace? 
    // For simplicity, let's just parse the string logic:
    String newString = currentString + value;
    double? newWeight = double.tryParse(newString);

    if (newWeight != null && newWeight <= maxWeight) {
      setState(() {
        _currentWeight = newWeight;
        _isKeyboardInput = true; // Flag to ignore scroll listener updates temporarily
      });
      _scrollToWeight(newWeight);
      // Reset flag after a short delay so user can scroll again
      Future.delayed(const Duration(milliseconds: 300), () {
        _isKeyboardInput = false;
      });
    }
  }

 
  // --- Logic: Save to Firebase ---
  void saveWeightAndContinue() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar("Error", "User not logged in.", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final DatabaseReference ref = FirebaseDatabase.instance.ref('users/${user.uid}/assessment');
      await ref.update({
        'weight': _currentWeight.toStringAsFixed(1),
        'weightUnit': 'kg', // Hardcoded as requested
        'lastUpdated_weight': DateTime.now().toIso8601String(),
        'isSetupComplete': true,
      });

      // Navigate to Home Screen
    Get.offAll(() => const Wrapper());      
   } catch (e) {
      Get.snackbar("Error", "Failed to save weight.");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // --- Widgets ---

  // Top Progress Bar
  Widget _buildProgressBar() {
    return Row(
      children: List.generate(6, (index) {
        return Expanded(
          child: Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: index == 1 ? primaryRed : const Color(0xFFFFEBEE), // Index 1 active
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  // Ruler Widget
  Widget _buildRuler() {
    return SizedBox(
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The Scrollable List
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollUpdateNotification) {
                // Calculate weight from scroll position
                // Center of screen is the reference point
                // Width of screen / 2 = offset + padding
                
                // Simplified logic: offset 0 = minWeight
                double offset = _scrollController.offset;
                double index = offset / itemWidth;
                double newWeight = minWeight + index;
                
                // Clamp
                if (newWeight < minWeight) newWeight = minWeight.toDouble();
                if (newWeight > maxWeight) newWeight = maxWeight.toDouble();

                setState(() {
                  _currentWeight = newWeight.roundToDouble();
                });
              }
              return true;
            },
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              // Pad the list so first/last items can reach the center
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 2 - itemWidth / 2),
              itemCount: maxWeight - minWeight + 1,
              itemBuilder: (context, index) {
                int value = minWeight + index;
                bool isMajor = value % 10 == 0; // Show text every 10kg
                
                return Container(
                  width: itemWidth,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Text Label
                      Text(
                        isMajor ? "$value" : "", // Only show numbers for major ticks
                        style: TextStyle(
                          color: const Color(0xFFCFD3D9),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Tick line
                      Container(
                        height: isMajor ? 40 : 25,
                        width: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCFD3D9), // Light grey for all inactive ticks
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // The Central Indicator (Black Line)
          Positioned(
            bottom: 25, // Align with the ticks
            child: Container(
              height: 50,
              width: 5,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 143 in the image has a red cursor line, we can simulate that or just text
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Assessment',
          style: TextStyle(color: textBlack, fontWeight: FontWeight.bold),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: btnGrey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '3 of 4',
              style: TextStyle(
                color: textBlack,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
         
      ),
      backgroundColor: bgWhite,
      body: SafeArea(
        child: Column(
          children: [
            // --- Header ---
            Text(
              "What's your weight?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textBlack),
            ),

            const SizedBox(height: 30),

            // --- Weight Display Box ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _currentWeight.toInt().toString(),
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: textBlack),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- Ruler ---
            _buildRuler(),

            const SizedBox(height: 20),

            // --- Unit Label (Kg only) ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: btnGrey,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text("kg", style: TextStyle(fontWeight: FontWeight.bold)),
            ),

            const Spacer(flex: 2),

                  // Continue Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child:
              Expanded(
                child: SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : saveWeightAndContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryRed,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Continue", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),    
            ),

            // --- Custom Numeric Keypad ---
          ],
        ),
      ),
    );
  }
}