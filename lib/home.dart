import 'package:flutter/material.dart';
// import 'login.dart';
// import 'register.dart';
import 'profile.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfileScreen()),
      );
    }
  }

  static final List<Widget> _widgetOptions = <Widget>[
    HomeContent(),
    Center(child: Text('Tambah Data (Skip for now)')),
    Center(child: Text('Profil')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Image.asset('assets/home.png'),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/add.png'),
            label: 'Tambah Data',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/home.png'),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Gambar utama
        Container(
          width: 300,
          height: 400,
          child: Image.asset(
            'assets/image1.png', // Sesuaikan dengan path gambar utama
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: 50),

        // Ikon kecil di bagian bawah
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green, // Warna latar belakang hijau
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: Image.asset(
                    'assets/icon1.png'), // Sesuaikan dengan path ikon kecil pertama
                iconSize: 40,
                onPressed: () {},
              ),
            ),
            SizedBox(width: 20),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green, // Warna latar belakang hijau
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: Image.asset(
                    'assets/icon2.png'), // Sesuaikan dengan path ikon kecil kedua
                iconSize: 40,
                onPressed: () {},
              ),
            ),
            SizedBox(width: 20),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green, // Warna latar belakang hijau
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: Image.asset(
                    'assets/icon3.png'), // Sesuaikan dengan path ikon kecil ketiga
                iconSize: 40,
                onPressed: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }
}
