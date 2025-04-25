import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/login.dart';
import 'pages/doctor_home.dart';
import 'pages/mother_home.dart';
import 'pages/admin_home.dart';

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

  Future<void> checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('role');

    if (role != null) {
      if (role == 'doctor') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DoctorHomePage()),
        );
      } else if (role == 'mother') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MotherHomePage()),
        );
      } else if (role == 'admin') {
        Navigator.pushReplacementNamed(context, '/adminHome');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'دفتر صحة الطفل',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Arial',
        primaryColor: Colors.pink.shade200,
        scaffoldBackgroundColor: Colors.pink.shade50,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.pink.shade200,
          foregroundColor: Colors.white,
        ),
      ),
      // Add localization support here
      locale: const Locale('ar', ''),
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('ar', ''), // Arabic
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routes: {
        '/adminHome': (context) => const AdminHomePage(),
      },
      home: const LoginPage(),
    );
  }
}