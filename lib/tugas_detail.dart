import 'package:flutter/material.dart';
import 'tugas.dart';

class TugasDetailPage extends StatelessWidget {
  final Tugas tugas;

  const TugasDetailPage({super.key, required this.tugas});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Detail Tugas'),
        elevation: 4.0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color.fromARGB(255, 0, 242, 255),
                width: 3.0,
              ),
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.grey[300],  // Set the background color to grey
        width: double.infinity,  // Ensure the container takes full width
        height: MediaQuery.of(context).size.height,  // Ensure it takes full height
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
            child: Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mata Kuliah
                    Row(
                      children: [
                        const Text(
                          'Mata Kuliah : ',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            tugas.mataKuliah,
                            style: const TextStyle(
                              fontSize: 20.0,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    const Divider(
                      color: Colors.black,
                      thickness: 2.0,
                    ),
                    const SizedBox(height: 20.0),

                    // Tugas
                    Row(
                      children: [
                        const Text(
                          'Tugas : ',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            tugas.tugas,
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.normal,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    const Divider(
                      color: Colors.black,
                      thickness: 2.0,
                    ),
                    const SizedBox(height: 20.0),

                    // Status
                    Row(
                      children: [
                        const Text(
                          'Status : ',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Chip(
                          label: Text(
                            tugas.isSelesai ? 'Selesai' : 'Belum Selesai',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: tugas.isSelesai ? Colors.green : Colors.red,
                            ),
                          ),
                          backgroundColor:
                              tugas.isSelesai ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
