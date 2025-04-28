import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'db_helper.dart';
import 'tugas.dart';
import 'tugas_detail.dart'; // Halaman detail tugas

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan Tugas',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TugasListPage(),
    );
  }
}

class TugasListPage extends StatefulWidget {
  const TugasListPage({super.key});

  @override
  _TugasListPageState createState() => _TugasListPageState();
}

class _TugasListPageState extends State<TugasListPage> {
  final DBHelper _dbHelper = DBHelper();
  List<Tugas> _tugasList = [];
  List<Tugas> _filteredTugasList = [];
  TextEditingController _searchController = TextEditingController();
  String _userName = 'Aang';

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadTugas();
  }

  void _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'Aang';
    });
  }

  void _saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('userName', name);
  }

  void _loadTugas() async {
    final data = await _dbHelper.getAllTugas();
    setState(() {
      _tugasList = data;
      _filteredTugasList = data;
    });
  }

  void _filterTugas(String keyword) {
    if (keyword.isEmpty) {
      setState(() {
        _filteredTugasList = _tugasList;
      });
    } else {
      setState(() {
        _filteredTugasList = _tugasList.where((tugas) {
          final lowerKeyword = keyword.toLowerCase();
          return tugas.mataKuliah.toLowerCase().contains(lowerKeyword) ||
                 tugas.tugas.toLowerCase().contains(lowerKeyword);
        }).toList();
      });
    }
  }

  void _changeUserName() async {
    final TextEditingController nameController = TextEditingController(text: _userName);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ubah Nama'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Nama'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _userName = nameController.text.isEmpty ? 'Aang' : nameController.text;
                  _saveUserName(_userName);
                });
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _addOrUpdateTugas({Tugas? tugas}) async {
    final TextEditingController mataKuliahController =
        TextEditingController(text: tugas != null ? tugas.mataKuliah : '');
    final TextEditingController tugasController =
        TextEditingController(text: tugas != null ? tugas.tugas : '');

    void updateTugasTextCapitalization(TextEditingController controller) {
      String text = controller.text;
      if (text.isNotEmpty) {
        controller.text = text[0].toUpperCase() + text.substring(1);
        controller.selection = TextSelection.collapsed(offset: controller.text.length);
      }
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            tugas == null ? 'Tambah Tugas' : 'Edit Tugas',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22.0),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: mataKuliahController,
                  decoration: const InputDecoration(labelText: 'Mata Kuliah'),
                  textCapitalization: TextCapitalization.words,
                  onChanged: (text) {
                    updateTugasTextCapitalization(mataKuliahController);
                  },
                ),
                TextField(
                  controller: tugasController,
                  decoration: const InputDecoration(labelText: 'Tugas'),
                  textCapitalization: TextCapitalization.words,
                  onChanged: (text) {
                    updateTugasTextCapitalization(tugasController);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final mataKuliahText = mataKuliahController.text;
                final tugasText = tugasController.text;

                if (mataKuliahText.isEmpty || tugasText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Semua field harus diisi')),
                  );
                  return;
                }

                final newTugas = Tugas(
                  id: tugas?.id,
                  tugas: tugasText,
                  mataKuliah: mataKuliahText,
                  isSelesai: tugas?.isSelesai ?? false,
                );

                if (tugas == null) {
                  await _dbHelper.insertTugas(newTugas);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tugas Berhasil Ditambahkan')),
                  );
                } else {
                  await _dbHelper.updateTugas(newTugas);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tugas Berhasil Diperbarui')),
                  );
                }

                _loadTugas();
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _toggleStatus(Tugas tugas) async {
    tugas.isSelesai = !tugas.isSelesai;
    await _dbHelper.updateTugas(tugas);
    _loadTugas();
  }

  void _deleteTugas(int? id, String mataKuliah) async {
    if (id != null) {
      bool? confirmDelete = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Konfirmasi Hapus'),
            content: Text('Apakah Anda yakin ingin menghapus tugas "$mataKuliah"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Hapus'),
              ),
            ],
          );
        },
      );

      if (confirmDelete == true) {
        await _dbHelper.deleteTugas(id);
        _loadTugas();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tugas berhasil dihapus')),
        );
      }
    }
  }

  void _viewDetailTugas(Tugas tugas) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TugasDetailPage(tugas: tugas),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: GestureDetector(
          onTap: _changeUserName,
          child: Text(
            'Catatan Tugas ~ $_userName',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addOrUpdateTugas(),
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[300],
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari tugas atau mata kuliah...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => _filterTugas(value),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredTugasList.length,
                itemBuilder: (context, index) {
                  final tugas = _filteredTugasList[index];
                  return GestureDetector(
                    onTap: () => _viewDetailTugas(tugas),
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 4.0,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tugas.mataKuliah,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  Text(
                                    tugas.tugas,
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Checkbox(
                                  value: tugas.isSelesai,
                                  onChanged: (_) => _toggleStatus(tugas),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _addOrUpdateTugas(tugas: tugas),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteTugas(tugas.id!, tugas.mataKuliah),
                                ),
                              ],
                            ),
                          ],
                        ),
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
