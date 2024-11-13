import 'package:flutter/material.dart';
import 'profile.dart';

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

  // Menambahkan halaman ProfileScreen di _widgetOptions
  static final List<Widget> _widgetOptions = <Widget>[
    HomeContent(),
    const Center(child: Text('Tambah Data')),
    ProfileScreen(), // Menampilkan halaman profil di sini
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
              'assets/profile.png',
              color: _selectedIndex == 2 ? Colors.white : Colors.black,
            ),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        backgroundColor: Colors.green, // Menjadikan background berwarna hijau
        selectedItemColor:
            Colors.white, // Warna ikon & teks yang dipilih menjadi putih
        unselectedItemColor: const Color.fromARGB(
            255, 0, 0, 0), // Warna ikon & teks yang tidak dipilih lebih gelap
        onTap: _onItemTapped,
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
        // Gambar utama
        SizedBox(
          width: 300,
          height: 400,
          child: Image.asset(
            'assets/image1.png', // Sesuaikan dengan path gambar utama
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 50),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ikon kecil di bagian bawah
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
