import 'package:biomark/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({super.key, required this.user});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late Map<String, dynamic> _userData;
  bool _isEditing = false;
  File? _profileImage;
  bool _isUploadingImage = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

  Future<void> _pickAndUploadProfileImage() async {
    final ImagePicker picker = ImagePicker();
    
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() {
        _isUploadingImage = true;
        _profileImage = File(pickedFile.path);
      });

      // Upload to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${widget.user.uid}.jpg');

      // Upload the file
      await storageRef.putFile(_profileImage!);

      // Get the download URL
      final String downloadURL = await storageRef.getDownloadURL();

      // Update Firestore with new photo URL
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .update({'profilePhotoUrl': downloadURL});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile photo updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile photo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  Future<void> _pickProfileImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Widget _buildProfileImage() {
    return Stack(
      children: [
        GestureDetector(
          onTap: _pickAndUploadProfileImage,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircleAvatar(
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : (_userData['profilePhotoUrl'] != null
                          ? NetworkImage(_userData['profilePhotoUrl'])
                          : const AssetImage('assets/default-avatar.jpg')) as ImageProvider,
                ),
                if (_isUploadingImage)
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.5),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.blue.shade900,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _userData == null
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 300,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.blue.shade900,
                                Colors.purple.shade900,
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Hero(
                                tag: 'profile-image',
                                child: _buildProfileImage(),  // Using the new profile image widget
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _userData['fullName'] ?? 'User Name',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                _userData['profession'] ?? 'Profession',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildSection(
                          title: 'Personal Information',
                          icon: Icons.person,
                          children: [
                            _buildInfoTile(
                              icon: Icons.cake,
                              title: 'Date of Birth',
                              value: _userData['dateOfBirth'],
                              editable: _isEditing,
                              onChanged: (value) => _userData['dateOfBirth'] = value,
                            ),
                            _buildInfoTile(
                              icon: Icons.work,
                              title: 'Profession',
                              value: _userData['profession'],
                              editable: _isEditing,
                              onChanged: (value) => _userData['profession'] = value,
                            ),
                            _buildInfoTile(
                              icon: Icons.email,
                              title: 'Email',
                              value: widget.user.email,
                              editable: false,
                            ),
                            _buildInfoTile(
                              icon: Icons.phone,
                              title: 'Phone',
                              value: _userData['phone'],
                              editable: _isEditing,
                              onChanged: (value) => _userData['phone'] = value,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildSection(
                          title: 'Medical Information',
                          icon: Icons.medical_services,
                          children: [
                            _buildInfoTile(
                              icon: Icons.bloodtype,
                              title: 'Blood Group',
                              value: _userData['bloodGroup'],
                              editable: _isEditing,
                              onChanged: (value) => _userData['bloodGroup'] = value,
                            ),
                            _buildInfoTile(
                              icon: Icons.height,
                              title: 'Height',
                              value: _userData['height'],
                              editable: _isEditing,
                              onChanged: (value) => _userData['height'] = value,
                            ),
                            _buildInfoTile(
                              icon: Icons.people,
                              title: 'Ethnicity',
                              value: _userData['ethnicity'],
                              editable: _isEditing,
                              onChanged: (value) => _userData['ethnicity'] = value,
                            ),
                            _buildInfoTile(
                              icon: Icons.remove_red_eye,
                              title: 'Eye Color',
                              value: _userData['eyeColor'],
                              editable: _isEditing,
                              onChanged: (value) => _userData['eyeColor'] = value,
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _isEditing
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: _buildActionButton(
                                            onPressed: _saveProfile,  // Changed from the previous version
                                            icon: Icons.save,
                                            label: 'Save Changes',
                                            color: Colors.green,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: _buildActionButton(
                                            onPressed: _toggleEditMode,
                                            icon: Icons.close,
                                            label: 'Cancel',
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : _buildActionButton(
                                  onPressed: _toggleEditMode,
                                  icon: Icons.edit,
                                  label: 'Edit Profile',
                                  color: Colors.blue,
                                ),
                        ),
                        const SizedBox(height: 16),
                        // logout button
                        _buildActionButton(
                          onPressed: _logout,
                          icon: Icons.logout,
                          label: 'Logout',
                          color: Colors.blueGrey,
                        ),
                        const SizedBox(height: 16),
                        _buildActionButton(
                          onPressed: () => _showUnsubscribeDialog(context),
                          icon: Icons.unsubscribe,
                          label: 'Unsubscribe from Biomark',
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: Colors.blue.shade900),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String? value,
    required bool editable,
    void Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (editable)
                  TextField(
                    controller: TextEditingController(text: value),
                    onChanged: onChanged,
                    style: const TextStyle(fontSize: 16),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  )
                else
                  Text(
                    value ?? '',
                    style: const TextStyle(fontSize: 16),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // _logout
  void _logout() {
    FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Future<void> _showUnsubscribeDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Unsubscribe'),
          content: const Text(
            'Are you sure you want to unsubscribe from Biomark? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _unsubscribeFromBiomark();
              },
              child: const Text(
                'Unsubscribe',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .update(_userData);
      
      if (_profileImage != null) {
        // Upload the profile image to Firebase Storage and update the user's profile photo URL
        final File imageFile = File(_profileImage!.path);
        final String downloadUrl = await FirebaseStorage.instance
        .ref('profile_images/${widget.user.uid}')
        .putFile(imageFile)
        .then((taskSnapshot) => taskSnapshot.ref.getDownloadURL());

      }

      // Hide loading indicator
      Navigator.pop(context);
      
      _toggleEditMode();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Hide loading indicator
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          backgroundColor: Colors.red,
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
        const SnackBar(
          content: Text('You have been unsubscribed from Biomark'),
          backgroundColor: Colors.blue,
        ),
      );
      Navigator.of(context).pushReplacementNamed('/');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to unsubscribe: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}