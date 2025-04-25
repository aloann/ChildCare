import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'doctor_home.dart';
import 'mother_home.dart';
import 'admin_home.dart'; // Import AdminHomePage here

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  void handleLogin() async {
    setState(() => isLoading = true);

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    // Check if the login is for the default Admin
    if (email == 'Admin28' && password == 'Admin28') {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('role', 'admin');
      Navigator.pushReplacementNamed(context, '/adminHome');
    } else {
      try {
        // Firebase login for other users (doctor or mother)
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists && userDoc['role'] != null) {
          String role = userDoc['role'];

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('email', email);
          await prefs.setString('role', role);

          if (role == 'doctor') {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const DoctorHomePage()));
          } else if (role == 'mother') {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const MotherHomePage()));
          } else if (role == 'admin') {
            Navigator.pushReplacementNamed(context, '/adminHome');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('نوع المستخدم غير معروف')));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('لم يتم العثور على بيانات المستخدم')));
        }
      } on FirebaseAuthException catch (e) {
        String message = 'حدث خطأ أثناء تسجيل الدخول';
        if (e.code == 'user-not-found') message = 'الحساب غير موجود';
        else if (e.code == 'wrong-password') message = 'كلمة المرور غير صحيحة';

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('حدث خطأ غير متوقع')));
      }
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تسجيل الدخول')),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/baby_carriage.png', width: 80, height: 80),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'كلمة المرور'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : handleLogin,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('تسجيل الدخول'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
