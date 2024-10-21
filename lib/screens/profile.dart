import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  final User user;

  ProfileScreen({required this.user});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Map<String, dynamic> _userData;
  bool _isEditing = false;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          _userData = snapshot.data()!;
        });
      }
    });
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveProfile() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .update(_userData);
      if (_profileImage != null) {
        // Upload the profile image to Firebase Storage and update the user's profile photo URL
      }
      _toggleEditMode();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
        ),
      );
    }
  }

  Future<void> _unsubscribeFromBiomark() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .delete();
      await widget.user.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You have been unsubscribed from Biomark'),
        ),
      );
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to unsubscribe: $e'),
        ),
      );
    }
  }

  // Future<void> _pickProfileImage() async {
  //   final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _profileImage = File(pickedFile.path);
  //     });
  //   }
  // }
  // // this getImage function is deprecated

  Future<void> _pickProfileImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: _userData == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.blue.shade700, Colors.purple.shade700],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: _pickProfileImage,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundImage: _profileImage != null
                                    ? FileImage(_profileImage!)
                                    : NetworkImage(_userData['profilePhotoUrl'] ?? 'https://via.placeholder.com/150'),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: TextEditingController(text: _userData['fullName']),
                                onChanged: (value) {
                                  _userData['fullName'] = value;
                                },
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Enter your name',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoCard(
                          title: 'Personal Info',
                          children: [
                            _buildInfoItem(
                              title: 'Date of Birth',
                              value: _userData['dateOfBirth'],
                              editable: _isEditing,
                              onChanged: (value) {
                                _userData['dateOfBirth'] = value;
                              },
                            ),
                            _buildInfoItem(
                              title: 'Profession',
                              value: _userData['profession'],
                              editable: _isEditing,
                              onChanged: (value) {
                                _userData['profession'] = value;
                              },
                            ),
                            _buildInfoItem(
                              title: 'Email',
                              value: widget.user.email ?? '',
                              editable: false,
                            ),
                            _buildInfoItem(
                              title: 'Phone',
                              value: _userData['phone'],
                              editable: _isEditing,
                              onChanged: (value) {
                                _userData['phone'] = value;
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        _buildInfoCard(
                          title: 'Details',
                          children: [
                            _buildInfoItem(
                              title: 'Blood Group',
                              value: _userData['bloodGroup'],
                              editable: _isEditing,
                              onChanged: (value) {
                                _userData['bloodGroup'] = value;
                              },
                            ),
                            _buildInfoItem(
                              title: 'Height',
                              value: _userData['height'],
                              editable: _isEditing,
                              onChanged: (value) {
                                _userData['height'] = value;
                              },
                            ),
                            _buildInfoItem(
                              title: 'Ethnicity',
                              value: _userData['ethnicity'],
                              editable: _isEditing,
                              onChanged: (value) {
                                _userData['ethnicity'] = value;
                              },
                            ),
                            _buildInfoItem(
                              title: 'Eye Color',
                              value: _userData['eyeColor'],
                              editable: _isEditing,
                              onChanged: (value) {
                                _userData['eyeColor'] = value;
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        if (_isEditing)
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: _saveProfile,
                                  child: Text('Save'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: _toggleEditMode,
                                  child: Text('Cancel'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Center(
                            child: ElevatedButton(
                              onPressed: _toggleEditMode,
                              child: Text('Edit Profile'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ),
                        SizedBox(height: 16),
                        Center(
                          child: ElevatedButton(
                            onPressed: _unsubscribeFromBiomark,
                            child: Text('Unsubscribe from Biomark'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required String title,
    required String? value,
    bool editable = false,
    void Function(String)? onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade800,
            ),
          ),
          if (editable)
            Expanded(
              child: TextField(
                controller: TextEditingController(text: value),
                onChanged: onChanged,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade800,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: value,
                ),
              ),
            )
          else
            Text(
              value ?? '',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade800,
              ),
            ),
        ],
      ),
    );
  }
}