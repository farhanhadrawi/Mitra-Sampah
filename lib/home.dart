import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'add.dart'; // Impor halaman AddDataScreen
import 'profile.dart';
import 'customer.dart'; // Impor halaman customer.dart

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  double totalWeight = 0;
  int totalSampah = 0;
  Map<String, int> wasteCount = {'Organik': 0, 'Anorganik': 0};

  // Data rute pengambilan sampah hari ini (contoh data statis)
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

  // Mengambil statistik sampah dari Firestore
  Future<void> _fetchStats() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('wasteData').get();

    double weight = 0;
    int sampahCount = 0;
    Map<String, int> count = {'Organik': 0, 'Anorganik': 0};

    snapshot.docs.forEach((doc) {
      double docWeight = doc['weight']?.toDouble() ?? 0;
      weight += docWeight;
      sampahCount++;

      String wasteType = doc['wasteType'] ?? '';
      if (count.containsKey(wasteType)) {
        count[wasteType] = count[wasteType]! + 1;
      }
    });

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

  // Menyusun widget untuk tampilan menu
  static final List<Widget> _widgetOptions = <Widget>[
    const HomeContent(), // Halaman Home
    const AddDataScreen(), // Halaman AddDataScreen
    const CustomerScreen(), // Halaman Customer
    const ProfileScreen(), // Halaman Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions[
          _selectedIndex], // Menampilkan widget sesuai pilihan BottomNavigationBar
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
        backgroundColor: Colors.green, // Background hijau
        selectedItemColor: Colors.white, // Warna ikon yang dipilih putih
        unselectedItemColor:
            Colors.black, // Warna ikon yang tidak dipilih hitam
        onTap: _onItemTapped,
        type: BottomNavigationBarType
            .fixed, // Untuk mengatur ikon tetap pada posisi
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil instance dari _HomeScreenState untuk mengakses statistik
    final _HomeScreenState homeState =
        context.findAncestorStateOfType<_HomeScreenState>()!;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Statistik Sampah
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statCard('Total Sampah', homeState.totalSampah.toString()),
                    _statCard('Total Berat (kg)',
                        homeState.totalWeight.toStringAsFixed(2)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statCard(
                        'Organik', homeState.wasteCount['Organik'].toString()),
                    _statCard('Anorganik',
                        homeState.wasteCount['Anorganik'].toString()),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Rute Pengambilan Sampah Hari Ini
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
                ...homeState.routes
                    .map((route) => _routeCard(route['route']!, route['time']!))
                    .toList(),
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

  Widget _routeCard(String route, String time) {
    return Card(
      color: Colors.grey[100],
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              route,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              time,
              style: const TextStyle(fontSize: 16, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
