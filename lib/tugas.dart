class Tugas {
  int? id;
  String tugas;
  String mataKuliah;
  bool isSelesai;

  Tugas({
    this.id,
    required this.tugas,
    required this.mataKuliah,
    this.isSelesai = false,
  });

  factory Tugas.fromMap(Map<String, dynamic> map) {
    return Tugas(
      id: map['id'],
      tugas: map['tugas'],
      mataKuliah: map['mataKuliah'],
      isSelesai: map['isSelesai'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tugas': tugas,
      'mataKuliah': mataKuliah,
      'isSelesai': isSelesai ? 1 : 0,
    };
  }
}
