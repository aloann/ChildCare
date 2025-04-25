import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditChildPage extends StatefulWidget {
  final String childId;

  const EditChildPage({Key? key, required this.childId}) : super(key: key);

  @override
  _EditChildPageState createState() => _EditChildPageState();
}

class _EditChildPageState extends State<EditChildPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _lnameController;
  late TextEditingController _allergiesController;
  late TextEditingController _commentsController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _nextAppointmentController;
  late TextEditingController _vaccinesController;

  late DateTime _dob;
  late DateTime _nextAppointment;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _lnameController = TextEditingController();
    _allergiesController = TextEditingController();
    _commentsController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _nextAppointmentController = TextEditingController();
    _vaccinesController = TextEditingController();
    _dob = DateTime.now();
    _nextAppointment = DateTime.now();
    _loadChildData();
  }

  // Load child data from Firestore
  Future<void> _loadChildData() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('children')
        .doc(widget.childId)
        .get();

    if (snapshot.exists) {
      var childData = snapshot.data() as Map<String, dynamic>;
      _nameController.text = childData['name'] ?? '';
      _lnameController.text = childData['LName'] ?? '';
      _allergiesController.text = childData['allergies'] ?? '';
      _commentsController.text = childData['comments'] ?? '';
      _heightController.text = childData['height']?.toString() ?? '';
      _weightController.text = childData['weight']?.toString() ?? '';
      _vaccinesController.text = childData['vaccines'] ?? '';

      _dob = (childData['dob'] as Timestamp).toDate();

      _nextAppointment = childData['nextAppointment'] != null
          ? (childData['nextAppointment'] as Timestamp).toDate()
          : DateTime.now();
      _nextAppointmentController.text =
          _nextAppointment.toLocal().toString().split(' ')[0];

      setState(() {});
    }
  }

  // Save edited data to Firestore
  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection('children')
          .doc(widget.childId)
          .update({
        'name': _nameController.text,
        'LName': _lnameController.text,
        'dob': _dob,
        'allergies': _allergiesController.text,
        'comments': _commentsController.text,
        'height': double.tryParse(_heightController.text) ?? 0,
        'weight': double.tryParse(_weightController.text) ?? 0,
        'nextAppointment': _nextAppointment,
        'vaccines': _vaccinesController.text,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث معلومات الطفل بنجاح')),
      );
      Navigator.pop(context);
    }
  }

  // Date picker for next appointment
  Future<void> _selectNextAppointment(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _nextAppointment,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _nextAppointment) {
      setState(() {
        _nextAppointment = picked;
        _nextAppointmentController.text =
            _nextAppointment.toLocal().toString().split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل معلومات الطفل'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'الاسم الأول للطفل'),
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء إدخال الاسم' : null,
                ),
                TextFormField(
                  controller: _lnameController,
                  decoration: const InputDecoration(labelText: 'اللقب'),
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء إدخال اللقب' : null,
                ),
                TextFormField(
                  controller: _allergiesController,
                  decoration: const InputDecoration(labelText: 'الحساسيات'),
                ),
                TextFormField(
                  controller: _commentsController,
                  decoration: const InputDecoration(labelText: 'التعليقات'),
                ),
                TextFormField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'الطول'),
                ),
                TextFormField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'الوزن'),
                ),
                TextFormField(
                  controller: _vaccinesController,
                  decoration: const InputDecoration(labelText: 'اللقاحات'),
                ),

                // Next Appointment with date picker
                GestureDetector(
                  onTap: () => _selectNextAppointment(context),
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _nextAppointmentController,
                      decoration: const InputDecoration(
                        labelText: 'الموعد التالي',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Display DOB
                Row(
                  children: [
                    const Text('تاريخ الميلاد: '),
                    Text(
                      _dob.toLocal().toString().split(' ')[0],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveData,
                  child: const Text('حفظ'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
