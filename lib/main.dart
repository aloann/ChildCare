import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/login.dart';
import 'pages/doctor_home.dart';
import 'pages/mother_home.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ChildHealthApp());
}

class ChildHealthApp extends StatefulWidget {
  const ChildHealthApp({super.key});

  @override
  _ChildHealthAppState createState() => _ChildHealthAppState();
}

class _ChildHealthAppState extends State<ChildHealthApp> {
  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  // Check login status
  Future<void> checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');

    if (email != null) {
      if (email == 'doctor') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DoctorHomePage()),
        );
      } else if (email == 'mom') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MotherHomePage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'دفتر صحة الطفل',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Cairo',
        primaryColor: Colors.pink.shade200,
        scaffoldBackgroundColor: Colors.pink.shade50,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.pink.shade200,
          foregroundColor: Colors.white,
        ),
      ),
      home: const LoginPage(), // Default login screen
    );
  }
}