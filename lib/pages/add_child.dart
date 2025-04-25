import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddChildPage extends StatefulWidget {
  const AddChildPage({super.key});

  @override
  State<AddChildPage> createState() => _AddChildPageState();
}

class _AddChildPageState extends State<AddChildPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _motherEmailController = TextEditingController();
  final TextEditingController _nationalIdController = TextEditingController();

  DateTime? _selectedDate;

  bool _isLoading = false;

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2020),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale("ar", ""), // Arabic localization
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _addChild() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      setState(() => _isLoading = true);

      try {
        await FirebaseFirestore.instance
            .collection('children')
            .doc(_nationalIdController.text.trim())
            .set({
          'name': _nameController.text.trim(),
          'LName': _lastNameController.text.trim(), // Renamed here
          'dob': _selectedDate,
          'motherMail': _motherEmailController.text.trim(),
          'nationalID': _nationalIdController.text.trim(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت إضافة الطفل بنجاح')),
        );

        // Clear fields
        _nameController.clear();
        _lastNameController.clear();
        _motherEmailController.clear();
        _nationalIdController.clear();
        setState(() => _selectedDate = null);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في إضافة الطفل: $e')),
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
    _motherEmailController.dispose();
    _nationalIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة طفل جديد')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'الاسم'),
                  validator: (value) =>
                      value!.isEmpty ? 'يرجى إدخال الاسم' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'اللقب'),
                  validator: (value) =>
                      value!.isEmpty ? 'يرجى إدخال اللقب' : null,
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'تاريخ الميلاد',
                        hintText: 'اختر تاريخ الميلاد',
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      controller: TextEditingController(
                        text: _selectedDate == null
                            ? ''
                            : '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
                      ),
                      validator: (value) =>
                          _selectedDate == null ? 'يرجى اختيار تاريخ الميلاد' : null,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _motherEmailController,
                  decoration: const InputDecoration(labelText: 'بريد الأم الإلكتروني'),
                  validator: (value) =>
                      value!.isEmpty ? 'يرجى إدخال البريد الإلكتروني للأم' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nationalIdController,
                  decoration: const InputDecoration(labelText: 'الرقم الوطني للطفل'),
                  keyboardType: TextInputType.number,
                  maxLength: 18,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'يرجى إدخال الرقم الوطني';
                    } else if (value.length != 18) {
                      return 'يجب أن يحتوي الرقم الوطني على 18 رقمًا';
                    } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'الرقم الوطني يجب أن يحتوي على أرقام فقط';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _addChild,
                          child: const Text('إضافة الطفل'),
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
