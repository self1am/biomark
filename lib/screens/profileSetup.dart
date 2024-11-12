import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biomark/screens/profile.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:biomark/db/database_helper.dart';


final key = encrypt.Key.fromUtf8('thisisaverysecretkey123456789012'); // 32 characters for 256-bit encryption
final iv = encrypt.IV.fromLength(16);
final encrypter = encrypt.Encrypter(encrypt.AES(key));

String encryptData(String text) {
  final encrypted = encrypter.encrypt(text, iv: iv);
  return encrypted.base64;
}

String decryptData(String base64Text) {
  final decrypted = encrypter.decrypt64(base64Text, iv: iv);
  return decrypted;
}

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
  final _scrollController = ScrollController();

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
    _scrollController.dispose();
    // Dispose all other controllers
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        readOnly: readOnly,
        onTap: onTap,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  List<Step> get _formSteps => [
    Step(
      title: const Text('Personal'),
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(
              controller: _fullNameController,
              label: 'Full Name',
            ),
            _buildTextField(
              controller: TextEditingController(
                text: _selectedDate == null ? '' : "${_selectedDate!.toLocal()}".split(' ')[0]
              ),
              label: 'Date of Birth',
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: Theme.of(context).primaryColor,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (pickedDate != null) {
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                }
              },
            ),
            _buildTextField(
              controller: TextEditingController(
                text: _selectedTime == null ? '' : _selectedTime!.format(context)
              ),
              label: 'Time of Birth',
              readOnly: true,
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
            _buildTextField(
              controller: _lobController,
              label: 'Location of Birth',
            ),
          ],
        ),
      ),
      isActive: _currentStep >= 0,
    ),
    Step(
      title: const Text('Physical'),
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(
              controller: _bloodGroupController,
              label: 'Blood Group',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: DropdownButtonFormField<String>(
                value: _selectedSex,
                decoration: InputDecoration(
                  labelText: 'Sex',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
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
              ),
            ),
            _buildTextField(
              controller: _heightController,
              label: 'Height',
            ),
            _buildTextField(
              controller: _ethnicityController,
              label: 'Ethnicity',
            ),
            _buildTextField(
              controller: _eyeColorController,
              label: 'Eye Color',
            ),
          ],
        ),
      ),
      isActive: _currentStep >= 1,
    ),
    Step(
      title: const Text('Security'),
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(
              controller: _mothersMaidenNameController,
              label: "Mother's Maiden Name",
            ),
            _buildTextField(
              controller: _childhoodFriendController,
              label: "Childhood Best Friend's Name",
            ),
            _buildTextField(
              controller: _childhoodPetController,
              label: "Childhood Pet's Name",
            ),
            _buildTextField(
              controller: _customQuestionController,
              label: 'Custom Security Question',
            ),
            _buildTextField(
              controller: _customAnswerController,
              label: 'Answer to Custom Question',
            ),
          ],
        ),
      ),
      isActive: _currentStep >= 2,
    ),
  ];

  // Future<void> _submitForm() async {
  //   if (_formKey.currentState!.validate()) {
  //     try {
  //       await _firestore.collection('users').doc(widget.user.uid).set({
  //         'fullName': _fullNameController.text,
  //         'dateOfBirth': _selectedDate?.toLocal().toString().split(' ')[0],
  //         'timeOfBirth': _selectedTime?.format(context),
  //         'locationOfBirth': _lobController.text,
  //         'bloodGroup': _bloodGroupController.text,
  //         'sex': _selectedSex,
  //         'height': _heightController.text,
  //         'ethnicity': _ethnicityController.text,
  //         'eyeColor': _eyeColorController.text,
  //         'mothersMaidenName': encryptData(_mothersMaidenNameController.text),
  //         'childhoodFriend': encryptData(_childhoodFriendController.text),
  //         'childhoodPet': encryptData(_childhoodPetController.text),
  //         'customQuestion': encryptData(_customQuestionController.text),
  //         'customAnswer': encryptData(_customAnswerController.text),
  //       });

  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => ProfileScreen(user: widget.user)),
  //       );
  //     } catch (e) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Error saving profile: $e'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   }
  // }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Save data in Firestore as before
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
        });

        // Prepare encrypted security answers
        final securityData = {
          'mothersMaidenName': encryptData(_mothersMaidenNameController.text),
          'childhoodFriend': encryptData(_childhoodFriendController.text),
          'childhoodPet': encryptData(_childhoodPetController.text),
          'customQuestion': encryptData(_customQuestionController.text),
          'customAnswer': encryptData(_customAnswerController.text),
        };

        // Save encrypted answers in SQLite
        await DatabaseHelper.instance.saveSecurityQuestions(widget.user.uid, securityData);

        // Navigate to profile screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen(user: widget.user)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Stepper(
            type: StepperType.vertical,  // Changed to vertical for better mobile experience
            currentStep: _currentStep,
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: details.onStepCancel,
                          child: const Text('Back'),
                        ),
                      ),
                    if (_currentStep > 0)
                      const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: details.onStepContinue,
                        child: Text(
                          _currentStep == _formSteps.length - 1 ? 'Submit' : 'Next'
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
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
      ),
    );
  }
}