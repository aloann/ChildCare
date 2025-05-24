import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VaccinesPage extends StatefulWidget {
  final String childId;

  const VaccinesPage({Key? key, required this.childId}) : super(key: key);

  @override
  _VaccinesPageState createState() => _VaccinesPageState();
}

class _VaccinesPageState extends State<VaccinesPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nlotController;
  late TextEditingController _doctorController;
  late TextEditingController _vaccineTypeController;
  late TextEditingController _dateController;
  late TextEditingController _locationController;

  List<Map<String, dynamic>> _vaccines = [];

  @override
  void initState() {
    super.initState();
    _nlotController = TextEditingController();
    _doctorController = TextEditingController();
    _vaccineTypeController = TextEditingController();
    _dateController = TextEditingController();
    _locationController = TextEditingController();
    _loadVaccinesData();
  }

  Future<void> _loadVaccinesData() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('children')
        .doc(widget.childId)
        .get();

    if (snapshot.exists) {
      var childData = snapshot.data() as Map<String, dynamic>;
      setState(() {
        _vaccines = List<Map<String, dynamic>>.from(childData['vaccines'] ?? []);
      });
    }
  }

  Future<void> _addVaccine() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> vaccine = {
        'nlot': _nlotController.text,
        'doctor': _doctorController.text,
        'vaccineType': _vaccineTypeController.text,
        'date': _dateController.text,
        'location': _locationController.text,
      };

      setState(() {
        _vaccines.add(vaccine);
      });

      await FirebaseFirestore.instance
          .collection('children')
          .doc(widget.childId)
          .update({'vaccines': _vaccines});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إضافة اللقاح بنجاح')),
      );

      _clearFields();
    }
  }

  void _clearFields() {
    _nlotController.clear();
    _doctorController.clear();
    _vaccineTypeController.clear();
    _dateController.clear();
    _locationController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة اللقاحات'),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = constraints.maxHeight;
            final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
            final adjustedPadding = keyboardHeight > 0 ? 8.0 : 16.0;

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(adjustedPadding),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: _addVaccine,
                      child: const Text('إضافة لقاح'),
                    ),
                    const SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nlotController,
                              decoration: const InputDecoration(labelText: 'رقم الحصة NLOT'),
                              validator: (value) => value?.isEmpty ?? true ? 'هذا الحقل مطلوب' : null,
                            ),
                            TextFormField(
                              controller: _doctorController,
                              decoration: const InputDecoration(labelText: 'الطبيب المسوول'),
                              validator: (value) => value?.isEmpty ?? true ? 'هذا الحقل مطلوب' : null,
                            ),
                            TextFormField(
                              controller: _vaccineTypeController,
                              decoration: const InputDecoration(labelText: 'نوع اللقاح'),
                              validator: (value) => value?.isEmpty ?? true ? 'هذا الحقل مطلوب' : null,
                            ),
                            TextFormField(
                              controller: _dateController,
                              decoration: const InputDecoration(labelText: 'التاريخ'),
                              validator: (value) => value?.isEmpty ?? true ? 'هذا الحقل مطلوب' : null,
                            ),
                            TextFormField(
                              controller: _locationController,
                              decoration: const InputDecoration(labelText: 'الموضع'),
                              validator: (value) => value?.isEmpty ?? true ? 'هذا الحقل مطلوب' : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: availableHeight * 0.5, // Increased to 50% of available height
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width - (adjustedPadding * 2),
                            ),
                            child: DataTable(
                              columnSpacing: 10, // Increased spacing for less clutter
                              dataRowHeight: 50, // Increased row height for better readability
                              headingTextStyle: const TextStyle(fontSize: 12),
                              dataTextStyle: const TextStyle(fontSize: 10),
                              columns: const [
                                DataColumn(label: Text('رقم الحصة')),
                                DataColumn(label: Text('الطبيب')),
                                DataColumn(label: Text('اللقاح')),
                                DataColumn(label: Text('التاريخ')),
                                DataColumn(label: Text('الموضع')),
                              ],
                              rows: _vaccines.map((vaccine) {
                                return DataRow(cells: [
                                  DataCell(
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 80), // Increased cell width
                                      child: Text(
                                        vaccine['nlot'],
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 80), // Increased cell width
                                      child: Text(
                                        vaccine['doctor'],
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 80), // Increased cell width
                                      child: Text(
                                        vaccine['vaccineType'],
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 80), // Increased cell width
                                      child: Text(
                                        vaccine['date'],
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 80), // Increased cell width
                                      child: Text(
                                        vaccine['location'],
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}