import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'add.dart';
import 'profile.dart';
import 'customer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  double totalWeight = 0;
  int totalSampah = 0;
  Map<String, double> wasteCount = {'Organik': 0.0, 'Anorganik': 0.0};

  final List<Map<String, String>> routes = [
    {"route": "Jalan Merdeka", "time": "08:00 AM"},
    {"route": "Jalan Sudirman", "time": "10:00 AM"},
    {"route": "Jalan Thamrin", "time": "01:00 PM"},
  ];

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('wasteData').get();

    double weight = 0;
    int sampahCount = 0;
    Map<String, double> count = {'Organik': 0.0, 'Anorganik': 0.0};

    for (var doc in snapshot.docs) {
      double docWeight = doc['weight']?.toDouble() ?? 0.0;
      weight += docWeight;
      sampahCount++;

      String wasteType = doc['wasteType'] ?? '';
      if (count.containsKey(wasteType)) {
        count[wasteType] = count[wasteType]! + 1.0;
      }
    }

    setState(() {
      totalWeight = weight;
      totalSampah = sampahCount;
      wasteCount = count;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeContent(),
    const AddDataScreen(),
    const CustomerScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/home.png',
              color: _selectedIndex == 0 ? Colors.white : Colors.black,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/add.png',
              color: _selectedIndex == 1 ? Colors.white : Colors.black,
            ),
            label: 'Tambah Data',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/add.png',
              color: _selectedIndex == 2 ? Colors.white : Colors.black,
            ),
            label: 'Pelanggan',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/profile.png',
              color: _selectedIndex == 3 ? Colors.white : Colors.black,
            ),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        backgroundColor: Colors.green,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final _HomeScreenState homeState =
        context.findAncestorStateOfType<_HomeScreenState>()!;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Statistik Sampah dengan Pie Chart
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.green[200],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Statistik Sampah',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                // Pie chart untuk jenis sampah (Organik vs Anorganik)
                SfCircularChart(
                  legend: Legend(isVisible: true),
                  series: <CircularSeries>[
                    PieSeries<MapEntry<String, double>, String>(
                      dataSource: homeState.wasteCount.entries.toList(),
                      xValueMapper: (MapEntry<String, double> data, _) =>
                          data.key,
                      yValueMapper: (MapEntry<String, double> data, _) =>
                          data.value,
                      dataLabelSettings: const DataLabelSettings(isVisible: true),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Menampilkan statistik sampah secara numerik
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     _statCard('Total Sampah', homeState.totalSampah.toString()),
                //     _statCard(
                //         'Total Berat (kg)',
                //         homeState.totalWeight
                //             .toStringAsFixed(2)), // Two decimal points
                //   ],
                // ),
                const SizedBox(height: 20),
                // Grafik Batang untuk Menampilkan Total Berat Sampah
                SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  series: <ChartSeries>[
                    BarSeries<Map<String, dynamic>, String>(
                      dataSource: [
                        {
                          "category": "Total Berat",
                          "value": homeState.totalWeight.toDouble()
                        }
                      ],
                      xValueMapper: (Map<String, dynamic> data, _) =>
                          data['category']!,
                      yValueMapper: (Map<String, dynamic> data, _) =>
                          data['value']!,
                      color: Colors.green,
                      dataLabelSettings: const DataLabelSettings(isVisible: true),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Grafik Bar untuk Rute Pengambilan Sampah
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rute Pengambilan Sampah Hari Ini',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...homeState.routes.map((route) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Rute: ${route['route']} - Waktu: ${route['time']}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value) {
    return Card(
      color: Colors.white,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}