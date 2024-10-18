import 'package:flutter/material.dart';

class RecoveryScreen extends StatefulWidget {
  const RecoveryScreen({super.key});

  @override
  _RecoveryScreenState createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  final _formKey = GlobalKey<FormState>();
  String fullName = '';
  String motherMaidenName = '';
  String childhoodBestFriend = '';

  void recoverAccount() {
    // Logic to recover the account based on provided security questions
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Recovery'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  fullName = value;
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Mother\'s Maiden Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your mother\'s maiden name';
                  }
                  motherMaidenName = value;
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Childhood Best Friend'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your childhood best friend\'s name';
                  }
                  childhoodBestFriend = value;
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    recoverAccount();
                  }
                },
                child: const Text('Recover Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
