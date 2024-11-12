import 'package:biomark/db/database_helper.dart';
import 'package:biomark/screens/login.dart';
import 'package:biomark/screens/profileSetup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RecoveryScreen extends StatefulWidget {
  const RecoveryScreen({super.key});

  @override
  _RecoveryScreenState createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String fullName = '';
  String userEmail = '';
  String motherMaidenName = '';
  String childhoodBestFriend = '';
  String additionalQuestion = ''; // User-defined security question
  String additionalQuestionAnswer = ''; // User-defined security question answer
  bool _isLoading = false;
  bool _isPasswordReset = false;

  Future<void> recoverAccount() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Step 1: Query Firestore to find user by fullName
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('fullName', isEqualTo: fullName)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception("No user found with the provided full name.");
      }

      // Assume the first match if multiple users have the same full name
      DocumentSnapshot userDoc = querySnapshot.docs.first;
      String userId = userDoc.id;



      // Step 2: Retrieve encrypted security answers from SQLite
      Map<String, String>? securityData = await DatabaseHelper.instance.getSecurityQuestions(userId);

      if (securityData == null) {
        throw Exception("Security questions not found for the user.");
      }

      // Step 3: Decrypt stored answers
      String decryptedMotherMaidenName = decryptData(securityData['mothersMaidenName']!);
      String decryptedChildhoodBestFriend = decryptData(securityData['childhoodFriend']!);
      String decryptedCustomAnswer = decryptData(securityData['customAnswer']!);
      additionalQuestion = decryptData(securityData['customQuestion']!);

      // Step 4: Validate answers
      if (decryptedMotherMaidenName == motherMaidenName &&
          decryptedChildhoodBestFriend == childhoodBestFriend &&
          decryptedCustomAnswer == additionalQuestionAnswer) {
        setState(() {
          _isPasswordReset = true;
        });
      } else {
        throw Exception("Security answers are incorrect.");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> resetPassword() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    try {
      // Send a password reset email to the user
      await FirebaseAuth.instance.sendPasswordResetEmail(email: userEmail);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password reset email sent. Please check your email to reset your password.',
          ),
        ),
      );
      // Wait 2 seconds and redirect to the login screen
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Recovery'),
        elevation: 0,
        backgroundColor: Colors.deepPurple,
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade300, Colors.blue.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Text(
                        'Recover Your Account',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            _buildTextField(
                              label: 'Full Name',
                              icon: Icons.person,
                              onChanged: (value) => fullName = value,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'Email',
                              icon: Icons.email,
                              onChanged: (value) => userEmail = value,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: "Mother's Maiden Name",
                              icon: Icons.family_restroom,
                              onChanged: (value) => motherMaidenName = value,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'Childhood Best Friend',
                              icon: Icons.group,
                              onChanged: (value) => childhoodBestFriend = value,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: additionalQuestion,
                              icon: Icons.security,
                              onChanged: (value) => additionalQuestionAnswer = value,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  recoverAccount();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                'Verify Security Answers',
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                            ),
                      if (_isPasswordReset)
                        Column(
                          children: [
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: resetPassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                'Reset Password',
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        onChanged(value);
        return null;
      },
    );
  }
}
