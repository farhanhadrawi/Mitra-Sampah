import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  _CustomerScreenState createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final TextEditingController searchController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  List<QueryDocumentSnapshot>? allCustomers; // Semua pelanggan dari Firestore
  List<QueryDocumentSnapshot>? filteredCustomers; // Hasil pencarian
  String? uid; // UID akun yang sedang login

  @override
  void initState() {
    super.initState();
    uid = auth.currentUser?.uid;
    _fetchCustomers(); // Ambil data pelanggan saat init
  }

  Future<void> _fetchCustomers() async {
    if (uid == null) return;

    final querySnapshot = await firestore
        .collection('users')
        .doc(uid)
        .collection('customers')
        .get();

    setState(() {
      allCustomers = querySnapshot.docs;

      // Urutkan secara manual berdasarkan nama
      allCustomers?.sort((a, b) {
        String nameA = a['name'].toString().toLowerCase();
        String nameB = b['name'].toString().toLowerCase();
        return nameA.compareTo(nameB); // A-Z
      });

      filteredCustomers = allCustomers; // Mengisi data untuk pencarian
    });
  }

  void _filterCustomers(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredCustomers = allCustomers;
      });
      return;
    }

    final results = allCustomers?.where((customer) {
      final name = customer['name'].toString().toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredCustomers = results;
    });
  }

  Future<void> _addCustomer() async {
    if (uid == null) return;

    try {
      await firestore.collection('users').doc(uid).collection('customers').add({
        'name': nameController.text.trim(),
        'location': locationController.text.trim(),
        'phone': phoneController.text.trim(),
        'isPaid': false, // Field baru
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pelanggan berhasil ditambahkan')),
      );

      _fetchCustomers(); // Refresh data pelanggan
      nameController.clear();
      locationController.clear();
      phoneController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan pelanggan: $e')),
      );
    }
  }

  bool _isHovered = false; // Status hover untuk animasi

  void _showAddCustomerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          // Agar bisa memperbarui state di dalam dialog
          builder: (context, setState) {
            bool isLoading = false; // Status loading untuk tombol

            Future<void> addCustomerWithValidation() async {
              if (nameController.text.trim().isEmpty ||
                  locationController.text.trim().isEmpty ||
                  phoneController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Harap isi semua bidang!'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              setState(() {
                isLoading = true;
              });

              try {
                await _addCustomer();
                Navigator.pop(context); // Tutup dialog setelah berhasil
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal menambahkan pelanggan: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              } finally {
                setState(() {
                  isLoading = false;
                });
              }
            }

            return AlertDialog(
              title: const Text('Tambah Mitra'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration:
                          const InputDecoration(labelText: 'Nama Mitra'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(labelText: 'Lokasi'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: phoneController,
                      decoration:
                          const InputDecoration(labelText: 'No. Handphone'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Tutup dialog
                  },
                  child: const Text('Batal'),
                ),
                Container(
                  margin: const EdgeInsets.only(
                      right: 10), // Memberikan jarak ke kanan
                  child: ElevatedButton(
                    onPressed: isLoading ? null : addCustomerWithValidation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(30), // Membuat tombol bulat
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Tambah',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditCustomerDialog(QueryDocumentSnapshot customer) {
    nameController.text = customer['name'];
    locationController.text = customer['location'];
    phoneController.text = customer['phone'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Mitra'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nama Mitra'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Lokasi'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'No. Handphone'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _updateCustomer(customer.id);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Background hijau
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8), // Membuat tombol lebih rapi
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12), // Padding tombol
              ),
              child: const Text(
                'Simpan',
                style: TextStyle(color: Colors.white), // Warna teks putih
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateCustomer(String customerId) async {
    try {
      if (uid == null) return;

      await firestore
          .collection('users')
          .doc(uid)
          .collection('customers')
          .doc(customerId)
          .update({
        'name': nameController.text.trim(),
        'location': locationController.text.trim(),
        'phone': phoneController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data pelanggan berhasil diperbarui')),
      );

      _fetchCustomers(); // Perbarui daftar pelanggan
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui data pelanggan: $e')),
      );
    }
  }

  Future<void> _deleteCustomer(String customerId) async {
    try {
      if (uid == null) return;

      await firestore
          .collection('users')
          .doc(uid)
          .collection('customers')
          .doc(customerId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data pelanggan berhasil dihapus')),
      );

      _fetchCustomers(); // Perbarui daftar pelanggan
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus data pelanggan: $e')),
      );
    }
  }

  Future<void> _togglePaymentStatus(String customerId, bool newStatus) async {
    try {
      await firestore
          .collection('users')
          .doc(uid)
          .collection('customers')
          .doc(customerId)
          .update({'isPaid': newStatus});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus
                ? 'Pelanggan telah membayar'
                : 'Pembayaran pelanggan dibatalkan',
          ),
          backgroundColor: newStatus ? Colors.green : Colors.red,
        ),
      );

      _fetchCustomers(); // Refresh data pelanggan
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui status pembayaran: $e')),
      );
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Pelanggan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Sudah Membayar'),
                onTap: () {
                  Navigator.pop(context);
                  _applyPaymentFilter(
                      true); // Tampilkan hanya yang sudah membayar
                },
              ),
              ListTile(
                leading: const Icon(Icons.circle_outlined, color: Colors.red),
                title: const Text('Belum Membayar'),
                onTap: () {
                  Navigator.pop(context);
                  _applyPaymentFilter(
                      false); // Tampilkan hanya yang belum membayar
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetFilters(); // Tampilkan semua pelanggan
              },
              child: const Text('Tampilkan Semua'),
            ),
          ],
        );
      },
    );
  }

  void _applyPaymentFilter(bool isPaid) {
    setState(() {
      filteredCustomers = allCustomers?.where((customer) {
        return customer['isPaid'] == isPaid;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      filteredCustomers = allCustomers; // Tampilkan semua pelanggan
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Mitra - Mitra'),
      //   backgroundColor: Colors.green,
      // ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight, // Menempatkan tombol di kanan bawah
        child: Padding(
          padding: const EdgeInsets.only(
              right: 16.0, bottom: 16.0), // Jarak dari tepi
          child: InkWell(
            onTap: () {
              // Fungsi yang dijalankan saat tombol ditekan
              _showAddCustomerDialog();
            },
            onHover: (hovering) {
              setState(() {
                _isHovered = hovering;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 56, // Tinggi tombol tetap
              width: _isHovered ? 140 : 56, // Lebar berubah saat hover
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(28), // Membuat tombol bulat
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, color: Colors.white), // Ikon "+"
                  if (_isHovered)
                    const SizedBox(width: 8), // Jarak antara ikon dan teks
                  if (_isHovered)
                    const Text(
                      'Tambah Mitra',
                      style: TextStyle(color: Colors.white),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // Posisi tombol di kanan bawah

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: _filterCustomers,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: Colors.green),
                      labelText: 'Cari Nama Mitra',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list,
                      color: Colors.black), // Tombol filter
                  onPressed: _showFilterDialog, // Memanggil dialog filter
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Daftar pelanggan
            Expanded(
              child: filteredCustomers == null
                  ? const Center(child: CircularProgressIndicator())
                  : filteredCustomers!.isEmpty
                      ? const Center(
                          child: Text('Belum ada pelanggan yang ditambahkan.'),
                        )
                      : ListView.builder(
                          itemCount: filteredCustomers!.length,
                          itemBuilder: (context, index) {
                            final customer = filteredCustomers![index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: customer['isPaid'] == true
                                      ? Colors.green
                                      : Colors
                                          .red, // Warna berdasarkan status pembayaran
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(customer['name']),
                                subtitle: Text(
                                    '${customer['location']} \n${customer['phone']}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        (customer['isPaid'] ??
                                                false) // Default value jika `isPaid` null
                                            ? Icons.check_circle
                                            : Icons.circle_outlined,
                                        color: (customer['isPaid'] ?? false)
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                      onPressed: () async {
                                        await _togglePaymentStatus(customer.id,
                                            !(customer['isPaid'] ?? false));
                                      },
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (value) async {
                                        if (value == 'edit') {
                                          _showEditCustomerDialog(customer);
                                        } else if (value == 'delete') {
                                          _deleteCustomer(customer.id);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Edit'),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
