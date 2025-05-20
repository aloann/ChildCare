import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SizesPage extends StatefulWidget {
  final String childId;
  final DateTime dob;

  const SizesPage({Key? key, required this.childId, required this.dob}) : super(key: key);

  @override
  _SizesPageState createState() => _SizesPageState();
}

class _SizesPageState extends State<SizesPage> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  List<Map<String, dynamic>> sizeEntries = [];

  @override
  void initState() {
    super.initState();
    _loadSizeData();
  }

  Future<void> _loadSizeData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('children')
        .doc(widget.childId)
        .collection('sizes')
        .orderBy('date')
        .get();

    setState(() {
      sizeEntries = snapshot.docs.map((doc) {
        final data = doc.data();
        final DateTime date = (data['date'] as Timestamp).toDate();
        final int ageInMonths = _calculateAgeInMonths(widget.dob, date);
        return {
          'weight': data['weight'],
          'height': data['height'],
          'date': date,
          'ageInMonths': ageInMonths,
        };
      }).toList();
    });
  }

  int _calculateAgeInMonths(DateTime dob, DateTime date) {
    return (date.year - dob.year) * 12 + (date.month - dob.month);
  }

  Future<void> _addSizeEntry() async {
    final double? weight = double.tryParse(_weightController.text);
    final double? height = double.tryParse(_heightController.text);

    if (weight == null || height == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال قيم صحيحة للطول والوزن')),
      );
      return;
    }

    final now = DateTime.now();

    await FirebaseFirestore.instance
        .collection('children')
        .doc(widget.childId)
        .collection('sizes')
        .add({
      'weight': weight,
      'height': height,
      'date': now,
    });

    _weightController.clear();
    _heightController.clear();
    _loadSizeData();
  }

  @override
  Widget build(BuildContext context) {
    final weightSpots = sizeEntries.map((entry) {
      return FlSpot(entry['ageInMonths'].toDouble(), entry['weight']);
    }).toList();

    final heightSpots = sizeEntries.map((entry) {
      return FlSpot(entry['ageInMonths'].toDouble(), entry['height']);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('تطور الحجم')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _weightController,
                      decoration: const InputDecoration(labelText: 'الوزن (كغ)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _heightController,
                      decoration: const InputDecoration(labelText: 'الطول (سم)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addSizeEntry,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: sizeEntries.isEmpty
                    ? const Center(child: Text('لا توجد بيانات حتى الآن.'))
                    : Column(
                        children: [
                          SizedBox(
                            height: 300,
                            child: LineChart(
                              LineChartData(
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: weightSpots,
                                    isCurved: true,
                                    color: Colors.pink,
                                    barWidth: 3,
                                    dotData: FlDotData(show: true),
                                    belowBarData: BarAreaData(show: false),
                                  ),
                                  LineChartBarData(
                                    spots: heightSpots,
                                    isCurved: true,
                                    color: Colors.blue,
                                    barWidth: 3,
                                    dotData: FlDotData(show: true),
                                    belowBarData: BarAreaData(show: false),
                                  ),
                                ],
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 1,
                                      getTitlesWidget: (value, meta) {
                                        return Text('${value.toInt()} شهر');
                                      },
                                    ),
                                  ),
                                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                gridData: FlGridData(show: true),
                                borderData: FlBorderData(show: true),
                                minX: 0,
                                maxX: 24,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text('سجل الطول والوزن'),
                          Expanded(
                            child: ListView.builder(
                              itemCount: sizeEntries.length,
                              itemBuilder: (context, index) {
                                final entry = sizeEntries[index];
                                return ListTile(
                                  title: Text(
                                    '${entry['weight']} كغ - ${entry['height']} سم',
                                  ),
                                  subtitle: Text(
                                    '${entry['ageInMonths']} شهر - ${entry['date'].toLocal().toString().split(' ')[0]}',
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
