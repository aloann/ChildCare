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
      locale: const Locale('ar', ''),
      supportedLocales: const [
        Locale('en', ''),
        Locale('ar', ''),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Ensure RTL text direction globally
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      routes: {
        '/adminHome': (context) => const AdminHomePage(),
      },
      // Use FutureBuilder to handle initial navigation based on login state
      home: FutureBuilder<Widget>(
        future: _checkLogin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return snapshot.data ?? const LoginPage();
        },
      ),
    );
  }

  Future<Widget> _checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('role');

    if (role != null) {
      if (role == 'doctor') {
        return const DoctorHomePage();
      } else if (role == 'mother') {
        return const MotherHomePage();
      } else if (role == 'admin') {
        return const AdminHomePage();
      }
    }
    return const LoginPage();
  }
}