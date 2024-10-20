// import 'package:flutter/material.dart';

// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Placeholder data
//     String fullName = 'John Doe';
//     String email = 'john.doe@example.com';
//     String birthDate = '01/01/1990';

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Profile'),
//         backgroundColor: Colors.blue,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               Center(
//                 child: CircleAvatar(
//                   radius: 50,
//                   backgroundColor: Colors.blue.shade100,
//                   child: Text(
//                     fullName.substring(0, 2).toUpperCase(),
//                     style: TextStyle(fontSize: 32, color: Colors.blue.shade800),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               _buildInfoCard('Full Name', fullName, Icons.person),
//               _buildInfoCard('Email', email, Icons.email),
//               _buildInfoCard('Date of Birth', birthDate, Icons.cake),
//               const SizedBox(height: 20),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton.icon(
//                   onPressed: () {
//                     Navigator.pushNamed(context, '/recovery');
//                   },
//                   icon: const Icon(Icons.security),
//                   label: const Text('Account Recovery'),
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoCard(String label, String value, IconData icon) {
//     return Card(
//       elevation: 2,
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       child: ListTile(
//         leading: Icon(icon, color: Colors.blue),
//         title: Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
//         subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  final User user;

  ProfileScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your Profile')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Profile not found'));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;

          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              ListTile(title: Text('Full Name'), subtitle: Text(userData['fullName'] ?? '')),
              ListTile(title: Text('Email'), subtitle: Text(user.email ?? '')),
              ListTile(title: Text('Date of Birth'), subtitle: Text(userData['dateOfBirth'] ?? '')),
              ListTile(title: Text('Blood Group'), subtitle: Text(userData['bloodGroup'] ?? '')),
              ListTile(title: Text('Height'), subtitle: Text(userData['height'] ?? '')),
              ListTile(title: Text('Ethnicity'), subtitle: Text(userData['ethnicity'] ?? '')),
              ListTile(title: Text('Eye Color'), subtitle: Text(userData['eyeColor'] ?? '')),
              // Add more fields as needed
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Implement unsubscribe functionality
                },
                child: Text('Unsubscribe from Biomark'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          );
        },
      ),
    );
  }
}