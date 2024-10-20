import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biomark/screens/profile.dart';


class ProfileSetupScreen extends StatefulWidget {
  final User user;

  ProfileSetupScreen({required this.user});

  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  final _firestore = FirebaseFirestore.instance;

  // Controllers for form fields
  final _fullNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _tobController = TextEditingController();
  final _lobController = TextEditingController();
  final _bloodGroupController = TextEditingController();
  final _sexController = TextEditingController();
  final _heightController = TextEditingController();
  final _ethnicityController = TextEditingController();
  final _eyeColorController = TextEditingController();
  final _mothersMaidenNameController = TextEditingController();
  final _childhoodFriendController = TextEditingController();
  final _childhoodPetController = TextEditingController();
  final _customQuestionController = TextEditingController();
  final _customAnswerController = TextEditingController();

  @override
  void dispose() {
    // Dispose all controllers
    _fullNameController.dispose();
    _dobController.dispose();
    _tobController.dispose();
    _lobController.dispose();
    _bloodGroupController.dispose();
    _sexController.dispose();
    _heightController.dispose();
    _ethnicityController.dispose();
    _eyeColorController.dispose();
    _mothersMaidenNameController.dispose();
    _childhoodFriendController.dispose();
    _childhoodPetController.dispose();
    _customQuestionController.dispose();
    _customAnswerController.dispose();
    super.dispose();
  }

  List<Step> get _formSteps => [
    Step(
      title: Text('Personal Information'),
      content: Column(
        children: [
          TextFormField(controller: _fullNameController, decoration: InputDecoration(labelText: 'Full Name')),
          TextFormField(controller: _dobController, decoration: InputDecoration(labelText: 'Date of Birth')),
          TextFormField(controller: _tobController, decoration: InputDecoration(labelText: 'Time of Birth')),
          TextFormField(controller: _lobController, decoration: InputDecoration(labelText: 'Location of Birth')),
        ],
      ),
      isActive: _currentStep >= 0,
    ),
    Step(
      title: Text('Physical Characteristics'),
      content: Column(
        children: [
          TextFormField(controller: _bloodGroupController, decoration: InputDecoration(labelText: 'Blood Group')),
          TextFormField(controller: _sexController, decoration: InputDecoration(labelText: 'Sex')),
          TextFormField(controller: _heightController, decoration: InputDecoration(labelText: 'Height')),
          TextFormField(controller: _ethnicityController, decoration: InputDecoration(labelText: 'Ethnicity')),
          TextFormField(controller: _eyeColorController, decoration: InputDecoration(labelText: 'Eye Color')),
        ],
      ),
      isActive: _currentStep >= 1,
    ),
    Step(
      title: Text('Security Questions'),
      content: Column(
        children: [
          TextFormField(controller: _mothersMaidenNameController, decoration: InputDecoration(labelText: "Mother's Maiden Name")),
          TextFormField(controller: _childhoodFriendController, decoration: InputDecoration(labelText: "Childhood Best Friend's Name")),
          TextFormField(controller: _childhoodPetController, decoration: InputDecoration(labelText: "Childhood Pet's Name")),
          TextFormField(controller: _customQuestionController, decoration: InputDecoration(labelText: 'Custom Security Question')),
          TextFormField(controller: _customAnswerController, decoration: InputDecoration(labelText: 'Answer to Custom Question')),
        ],
      ),
      isActive: _currentStep >= 2,
    ),
  ];

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Store user data in Firestore
        await _firestore.collection('users').doc(widget.user.uid).set({
          'fullName': _fullNameController.text,
          'dateOfBirth': _dobController.text,
          'timeOfBirth': _tobController.text,
          'locationOfBirth': _lobController.text,
          'bloodGroup': _bloodGroupController.text,
          'sex': _sexController.text,
          'height': _heightController.text,
          'ethnicity': _ethnicityController.text,
          'eyeColor': _eyeColorController.text,
          // Store security questions separately or encrypt them
        });

        // Navigate to ProfileScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen(user: widget.user)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Complete Your Profile')),
      body: Form(
        key: _formKey,
        child: Stepper(
          type: StepperType.horizontal,
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < _formSteps.length - 1) {
              setState(() {
                _currentStep += 1;
              });
            } else {
              _submitForm();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep -= 1;
              });
            }
          },
          steps: _formSteps,
        ),
      ),
    );
  }
}