import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController(); // Last name controller
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nationalIdController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController(); // Phone number controller
  String _selectedRole = 'doctor'; // default role

  bool _isLoading = false;

  // Function to show success dialog
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تم إنشاء الحساب بنجاح'),
          content: const Text('لقد تم إنشاء الحساب بنجاح.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('حسنا'),
            ),
          ],
        );
      },
    );
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Save additional data to Firestore
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'name': _nameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'role': _selectedRole,
          'nationalID': _nationalIdController.text.trim(),
        });

        // Show the success dialog
        _showSuccessDialog();

        // Clear the input fields
        _nameController.clear();
        _lastNameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _nationalIdController.clear();
        _phoneController.clear();
        setState(() => _selectedRole = 'doctor');

      } on FirebaseAuthException catch (e) {
        // Show error message in case of failure
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'حدث خطأ')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nationalIdController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل حساب جديد')),
      body: SingleChildScrollView( // Added SingleChildScrollView
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'الاسم'),
                  validator: (value) => value!.isEmpty ? 'يرجى إدخال الاسم' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _lastNameController, // Last name field
                  decoration: const InputDecoration(labelText: 'اللقب'),
                  validator: (value) => value!.isEmpty ? 'يرجى إدخال اللقب' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
                  validator: (value) => value!.isEmpty ? 'يرجى إدخال البريد الإلكتروني' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'كلمة المرور'),
                  validator: (value) => value!.length < 6 ? 'كلمة المرور يجب أن تكون 6 أحرف أو أكثر' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nationalIdController,
                  decoration: const InputDecoration(labelText: 'الرقم الوطني'),
                  keyboardType: TextInputType.number,
                  maxLength: 18, // Restrict input to 18 characters for national ID
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'يرجى إدخال الرقم الوطني';
                    } else if (value.length != 18) {
                      return 'الرقم الوطني يجب أن يكون 18 رقمًا';
                    } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'الرقم الوطني يجب أن يحتوي على أرقام فقط';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                  keyboardType: TextInputType.phone,
                  maxLength: 10, // Restrict input to 10 characters for phone number
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'يرجى إدخال رقم الهاتف';
                    } else if (value.length != 10 || !RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                      return 'رقم الهاتف يجب أن يتكون من 10 أرقام';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(labelText: 'الدور'),
                  items: const [
                    DropdownMenuItem(value: 'doctor', child: Text('طبيب')),
                    DropdownMenuItem(value: 'mother', child: Text('أم')),
                    DropdownMenuItem(value: 'admin', child: Text('مسؤول')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _register,
                          child: const Text('تسجيل'),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
