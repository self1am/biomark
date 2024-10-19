import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder data
    String fullName = 'John Doe';
    String email = 'john.doe@example.com';
    String birthDate = '01/01/1990';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    fullName.substring(0, 2).toUpperCase(),
                    style: TextStyle(fontSize: 32, color: Colors.blue.shade800),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildInfoCard('Full Name', fullName, Icons.person),
              _buildInfoCard('Email', email, Icons.email),
              _buildInfoCard('Date of Birth', birthDate, Icons.cake),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/recovery');
                  },
                  icon: const Icon(Icons.security),
                  label: const Text('Account Recovery'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}