import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Untuk mendapatkan user yang sedang login
import 'home.dart'; // Pastikan mengimpor file home.dart yang berisi HomeScreen

class AddDataScreen extends StatefulWidget {
  const AddDataScreen({super.key});

  @override
  _AddDataScreenState createState() => _AddDataScreenState();
}

class _AddDataScreenState extends State<AddDataScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedWasteType;
  double? _weight;

  // Fungsi untuk menyimpan data ke Firestore
  Future<void> _saveData() async {
    if (_formKey.currentState!.validate() && _selectedWasteType != null) {
      try {
        final user = FirebaseAuth.instance.currentUser;

        // Menyimpan data ke Firestore
        await FirebaseFirestore.instance.collection('wasteData').add({
          'userId': user?.uid,
          'wasteType': _selectedWasteType,
          'weight': _weight,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Tampilkan pesan sukses
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil disimpan')),
        );

        // Arahkan ke halaman Home setelah berhasil simpan
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } catch (e) {
        // Tampilkan pesan error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Sampah'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Pilihan jenis sampah
              DropdownButtonFormField<String>(
                value: _selectedWasteType,
                decoration:
                    const InputDecoration(labelText: 'Pilih Jenis Sampah'),
                items: ['Organik', 'Anorganik']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedWasteType = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Pilih jenis sampah';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Input berat sampah
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Berat Sampah (kg)'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _weight = double.tryParse(value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan berat sampah';
                  } else if (_weight == null || _weight! <= 0) {
                    return 'Berat sampah harus lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Tombol Simpan
              ElevatedButton(
                onPressed: _saveData,
                child: const Text('Simpan'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
