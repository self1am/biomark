import 'package:flutter/material.dart';
import 'package:biomark/screens/login.dart';
import 'package:biomark/screens/register.dart';
import 'package:biomark/screens/profile.dart';
import 'package:biomark/screens/recovery.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const BiomarkApp());
}

class BiomarkApp extends StatelessWidget {
  const BiomarkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biomark App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/recovery': (context) => const RecoveryScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/profile') {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            return MaterialPageRoute(
              builder: (context) => ProfileScreen(user: user),
            );
          } else {
            // Handle the case when the user is not logged in
            return MaterialPageRoute(
              builder: (context) => LoginScreen(),
            );
          }
        }
        return null;
      },
    );
  }
}