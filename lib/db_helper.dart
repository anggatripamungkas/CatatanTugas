import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'tugas.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;

  factory DBHelper() => _instance;

  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tugas.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          '''
          CREATE TABLE tugas(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tugas TEXT,
            mataKuliah TEXT,
            isSelesai INTEGER
          )
          ''',
        );
      },
    );
  }

  Future<int> insertTugas(Tugas tugas) async {
    final db = await database;
    return await db.insert('tugas', tugas.toMap());
  }

  Future<List<Tugas>> getAllTugas() async {
    final db = await database;
    final result = await db.query('tugas');
    return result.map((e) => Tugas.fromMap(e)).toList();
  }

  Future<int> updateTugas(Tugas tugas) async {
    final db = await database;
    return await db.update(
      'tugas',
      tugas.toMap(),
      where: 'id = ?',
      whereArgs: [tugas.id],
    );
  }

  Future<int> deleteTugas(int id) async {
    final db = await database;
    return await db.delete(
      'tugas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
