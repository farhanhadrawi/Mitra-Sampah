import 'package:flutter/material.dart';
import 'profile.dart';
import 'customer.dart'; // Impor halaman customer.dart

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeContent(),
    const Center(
        child: Text('Tambah Data')), // Placeholder untuk halaman Tambah Data
    const CustomerScreen(), // Arahkan ke halaman customer
    const ProfileScreen(), // Halaman profil
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 300,
          height: 400,
          child: Image.asset(
            'assets/image1.png',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 50),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIconButton(context, 'assets/icon1.png'),
            const SizedBox(width: 20),
            _buildIconButton(context, 'assets/icon2.png'),
            const SizedBox(width: 20),
            _buildIconButton(context, 'assets/icon3.png'),
          ],
        ),
      ],
    );
  }

  Widget _buildIconButton(BuildContext context, String assetPath) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        icon: Image.asset(assetPath),
        iconSize: 40,
        onPressed: () {},
      ),
    );
  }
}
