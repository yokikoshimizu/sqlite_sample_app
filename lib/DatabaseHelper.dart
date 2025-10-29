import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dog_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if(_database != null) return _database!;
    _database = await _initDB('my_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
    CREATE TABLE dogs (
      id $idType,
      name $textType,
      age $integerType
    )
    ''');
  }

  Future<int> create(Dog dog) async {
    final db = await instance.database;
    // 'dogs'テーブルにMap形式で挿入
    final id = await db.insert('dogs', dog.toMap());
    return id; // 挿入された行のIDを返す
  }

  //c
  Future<List<Dog>> readAllDogs() async {
    final db = await instance.database;
    final result = await db.query('dogs');

    return result.map((json) => Dog.fromMap(json)).toList();
  }

  //d
  Future<int> update(Dog dog) async {
    final db = await instance.database;
    return db.update(
      'dogs',
      dog.toMap(),
      where: 'id = ?',
      whereArgs: [dog.id],
    );
  }

  //e
  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'dogs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}