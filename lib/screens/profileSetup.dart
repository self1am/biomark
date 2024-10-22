import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biomark/screens/profile.dart';

class ProfileSetupScreen extends StatefulWidget {
  final User user;

  const ProfileSetupScreen({super.key, required this.user});

  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  final _firestore = FirebaseFirestore.instance;

  // Controllers for form fields
  final _fullNameController = TextEditingController();
  final _lobController = TextEditingController();
  final _bloodGroupController = TextEditingController();
  final _heightController = TextEditingController();
  final _ethnicityController = TextEditingController();
  final _eyeColorController = TextEditingController();
  final _mothersMaidenNameController = TextEditingController();
  final _childhoodFriendController = TextEditingController();
  final _childhoodPetController = TextEditingController();
  final _customQuestionController = TextEditingController();
  final _customAnswerController = TextEditingController();

  // State for date, time, and sex
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedSex;

  @override
  void dispose() {
    // Dispose all controllers
    _fullNameController.dispose();
    _lobController.dispose();
    _bloodGroupController.dispose();
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
      title: const Text('Personal Information'),
      content: Column(
        children: [
          TextFormField(controller: _fullNameController, decoration: const InputDecoration(labelText: 'Full Name')),
          TextFormField(
            controller: TextEditingController(text: _selectedDate == null ? '' : "${_selectedDate!.toLocal()}".split(' ')[0]),
            decoration: const InputDecoration(labelText: 'Date of Birth'),
            readOnly: true,  // Prevent manual input
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null) {
                setState(() {
                  _selectedDate = pickedDate;
                });
              }
            },
          ),
          TextFormField(
            controller: TextEditingController(text: _selectedTime == null ? '' : _selectedTime!.format(context)),
            decoration: const InputDecoration(labelText: 'Time of Birth'),
            readOnly: true,  // Prevent manual input
            onTap: () async {
              TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (pickedTime != null) {
                setState(() {
                  _selectedTime = pickedTime;
                });
              }
            },
          ),
          TextFormField(controller: _lobController, decoration: const InputDecoration(labelText: 'Location of Birth')),
        ],
      ),
      isActive: _currentStep >= 0,
    ),
    Step(
      title: const Text('Physical Characteristics'),
      content: Column(
        children: [
          TextFormField(controller: _bloodGroupController, decoration: const InputDecoration(labelText: 'Blood Group')),
          DropdownButtonFormField<String>(
            value: _selectedSex,
            items: ['Male', 'Female', 'Other'].map((String sex) {
              return DropdownMenuItem<String>(
                value: sex,
                child: Text(sex),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedSex = newValue;
              });
            },
            decoration: const InputDecoration(labelText: 'Sex'),
          ),
          TextFormField(controller: _heightController, decoration: const InputDecoration(labelText: 'Height')),
          TextFormField(controller: _ethnicityController, decoration: const InputDecoration(labelText: 'Ethnicity')),
          TextFormField(controller: _eyeColorController, decoration: const InputDecoration(labelText: 'Eye Color')),
        ],
      ),
      isActive: _currentStep >= 1,
    ),
    Step(
      title: const Text('Security Questions'),
      content: Column(
        children: [
          TextFormField(controller: _mothersMaidenNameController, decoration: const InputDecoration(labelText: "Mother's Maiden Name")),
          TextFormField(controller: _childhoodFriendController, decoration: const InputDecoration(labelText: "Childhood Best Friend's Name")),
          TextFormField(controller: _childhoodPetController, decoration: const InputDecoration(labelText: "Childhood Pet's Name")),
          TextFormField(controller: _customQuestionController, decoration: const InputDecoration(labelText: 'Custom Security Question')),
          TextFormField(controller: _customAnswerController, decoration: const InputDecoration(labelText: 'Answer to Custom Question')),
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
          'dateOfBirth': _selectedDate?.toLocal().toString().split(' ')[0],
          'timeOfBirth': _selectedTime?.format(context),
          'locationOfBirth': _lobController.text,
          'bloodGroup': _bloodGroupController.text,
          'sex': _selectedSex,
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
      appBar: AppBar(title: const Text('Complete Your Profile')),
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
