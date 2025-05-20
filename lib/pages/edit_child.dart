import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pfe2025/pages/sizes_page.dart';
import 'package:url_launcher/url_launcher.dart';

class EditChildPage extends StatefulWidget {
  final String childId;

  const EditChildPage({Key? key, required this.childId}) : super(key: key);

  @override
  _EditChildPageState createState() => _EditChildPageState();
}

class _EditChildPageState extends State<EditChildPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _allergiesController;
  late TextEditingController _commentsController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _nextAppointmentController;
  late TextEditingController _birthWeightController;
  late TextEditingController _birthMethodController;

  String _firstName = '';
  String _lastName = '';
  late DateTime _dob;
  late DateTime _nextAppointment;

  String _birthCry = 'لا'; // Default option: لا
  String _sex = 'ذكر'; // Default option: ذكر
  String _motherEmail = ''; // To store mother's email

  @override
  void initState() {
    super.initState();
    _allergiesController = TextEditingController();
    _commentsController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _nextAppointmentController = TextEditingController();
    _birthWeightController = TextEditingController();
    _birthMethodController = TextEditingController();
    _dob = DateTime.now();
    _nextAppointment = DateTime.now();
    _loadChildData();
  }

  Future<void> _loadChildData() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('children')
        .doc(widget.childId)
        .get();

    if (snapshot.exists) {
      var childData = snapshot.data() as Map<String, dynamic>;
      _firstName = childData['name'] ?? '';
      _lastName = childData['LName'] ?? '';
      _motherEmail = childData['motherMail'] ?? ''; // Get mother's email
      _allergiesController.text = childData['allergies'] ?? '';
      _commentsController.text = childData['comments'] ?? '';
      _heightController.text = childData['height']?.toString() ?? '';
      _weightController.text = childData['weight']?.toString() ?? '';
      _birthWeightController.text = childData['birthWeight']?.toString() ?? '';
      _birthMethodController.text = childData['birthMethod'] ?? '';

      _dob = (childData['dob'] as Timestamp).toDate();

      _nextAppointment = childData['nextAppointment'] != null
          ? (childData['nextAppointment'] as Timestamp).toDate()
          : DateTime.now();
      _nextAppointmentController.text =
          _nextAppointment.toLocal().toString().split(' ')[0];

      _birthCry = childData['birthCry'] ?? 'لا'; // Default is "لا"
      _sex = childData['sex'] ?? 'ذكر'; // Default is "ذكر"

      setState(() {});
    }
  }

  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection('children')
          .doc(widget.childId)
          .update({
        'allergies': _allergiesController.text,
        'comments': _commentsController.text,
        'height': double.tryParse(_heightController.text) ?? 0,
        'weight': double.tryParse(_weightController.text) ?? 0,
        'nextAppointment': _nextAppointment,
        'birthWeight': double.tryParse(_birthWeightController.text) ?? 0,
        'birthMethod': _birthMethodController.text,
        'birthCry': _birthCry,
        'sex': _sex,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث معلومات الطفل بنجاح')),
      );
      Navigator.pop(context);
    }
  }

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

  // Method to open Gmail with the mother's email
  Future<void> _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: _motherEmail,
      queryParameters: {'subject': 'استفسار عن الطفل $_firstName $_lastName'},
    );
    if (await canLaunch(emailUri.toString())) {
      await launch(emailUri.toString());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يمكن فتح البريد الإلكتروني')),
      );
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Display name and surname at the top
                Center(
                  child: Text(
                    '$_firstName $_lastName',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Dropdown for birth cry (بكاء عند الولادة)
                DropdownButtonFormField<String>(
                  value: _birthCry,
                  items: ['لا', 'نعم'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _birthCry = value!;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'بكاء عند الولادة'),
                ),

                // Dropdown for sex (ذكر/أنثى)
                DropdownButtonFormField<String>(
                  value: _sex,
                  items: ['ذكر', 'أنثى'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _sex = value!;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'النوع'),
                ),

                // New field for birth method (طريقة الولادة)
                TextFormField(
                  controller: _birthMethodController,
                  decoration: const InputDecoration(labelText: 'طريقة الولادة'),
                ),

                // New field for birth weight (الوزن عند الولادة)
                TextFormField(
                  controller: _birthWeightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'الوزن عند الولادة'),
                ),

                // Existing fields
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

                // Button to navigate to VaccinePage
                ElevatedButton(
                  onPressed: _navigateToVaccinesPage,
                  child: const Text('إدارة اللقاحات'),
                ),
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SizesPage(childId: widget.childId, dob: _dob),
      ),
    );
  },
  child: const Text('عرض تطور الطول والوزن'),
),
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

                Row(
                  children: [
                    const Text('تاريخ الميلاد: '),
                    Text(
                      _dob.toLocal().toString().split(' ')[0],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Display mother's email
                Row(
                  children: [
                    const Text('بريد الأم: '),
                    Text(
                      _motherEmail,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.email),
                      onPressed: _sendEmail,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _saveData,
                  child: const Text('حفظ التغييرات'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToVaccinesPage() {
    // Add navigation to the Vaccines page if needed
  }
}
