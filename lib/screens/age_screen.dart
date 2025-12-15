import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:firebase_database/firebase_database.dart'; // Import Firebase Realtime Database
import 'package:get/get.dart'; // Import Get for navigation and snackbars
import 'gender_screen.dart';
import 'weight_screen.dart';

class AgeSelectionScreen extends StatefulWidget {
  const AgeSelectionScreen({super.key});

  @override
  State<AgeSelectionScreen> createState() => _AgeSelectionScreenState();
}

class _AgeSelectionScreenState extends State<AgeSelectionScreen> {
  // Constants
  final Color primaryOrange = const Color(0xFFFF7043);
  final Color darkBlack = const Color(0xFF1A1D26);
  final Color lightGrey = const Color(0xFFC7C7C7);
  
  // Age Range
  final int minAge = 10;
  final int maxAge = 90;
  
  // Picker configuration
  final double itemHeight = 90;
  late FixedExtentScrollController _scrollController;
  late int _selectedAge;

  bool _isSaving = false; // New state for loading indicator

  @override
  void initState() {
    super.initState();
    // Start with a default age, e.g., 20
    _selectedAge = 20;
    // Controller must be initialized with the initial item index
    _scrollController = FixedExtentScrollController(initialItem: _selectedAge - minAge);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  // Function to save age to Firebase and navigate
  void saveAgeAndNavigate() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar(
        "Error", 
        "User not logged in. Please sign in again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // 1. Get reference to the user's data node
      final databaseRef = FirebaseDatabase.instance.ref('users/${user.uid}/assessment');

      // 2. Save the selected age
      await databaseRef.update({
        'age': _selectedAge,
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      // 3. Navigate to the next screen (WeightSelectionScreen)
      Get.off(() => const SelectGenderScreen());

    } catch (e) {
      print('Firebase Save Error: $e');
      Get.snackbar(
        "Error Saving Data", 
        "Failed to save age. Please check your network connection and Firebase rules.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 60,
        automaticallyImplyLeading: false, // Hide default back button
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
            onPressed: () {},
          ),
        ),
        title: Text(
          'Assessment',
          style: TextStyle(color: darkBlack, fontWeight: FontWeight.bold),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: lightGrey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '1 of 4',
              style: TextStyle(
                color: darkBlack,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: Text(
              "What's your Age?",
              style: TextStyle(
                color: darkBlack,
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          // Age Picker Area
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. Highlighted Central Box (The Orange Selector)
                Container(
                  width: 100,
                  height: itemHeight,
                  decoration: BoxDecoration(
                    color: primaryOrange,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: primaryOrange.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                ),

                // 2. The ListWheelScrollView (Age Picker)
                NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification notification) {
                    if (notification is ScrollEndNotification) {
                      // Get the index of the item currently in the center
                      final int centralIndex = _scrollController.selectedItem;
                      setState(() {
                        _selectedAge = minAge + centralIndex;
                      });
                    }
                    return false;
                  },
                  child: ListWheelScrollView.useDelegate(
                    controller: _scrollController,
                    itemExtent: itemHeight,
                    diameterRatio: 2.5, // Controls the "3D" curvature
                    physics: const FixedExtentScrollPhysics(),
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: maxAge - minAge + 1,
                      builder: (context, index) {
                        final int age = minAge + index;
                        final bool isSelected = age == _selectedAge;
                        
                        // Dynamically adjust text style based on selection
                        final TextStyle style = TextStyle(
                          fontSize: isSelected ? 48 : 36,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                          color: isSelected ? Colors.white : lightGrey,
                        );

                        return Center(
                          child: Text(
                            age.toString(),
                            style: style,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Debugging/Selected Age Display (Optional)
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Center(
              child: Text(
                'Selected Age: $_selectedAge',
                style: TextStyle(fontSize: 18, color: darkBlack.withOpacity(0.7)),
              ),
            ),
          ),

          // Continue Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isSaving ? null : saveAgeAndNavigate, // Disabled when saving
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkBlack,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "Continue",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 12),
                          Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}