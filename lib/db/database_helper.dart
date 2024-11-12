import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('user_data.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE security_questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        mothersMaidenName TEXT,
        childhoodFriend TEXT,
        childhoodPet TEXT,
        customQuestion TEXT,
        customAnswer TEXT
      )
    ''');
  }

  Future<void> saveSecurityQuestions(String userId, Map<String, String> data) async {
    final db = await instance.database;
    await db.insert(
      'security_questions',
      {
        'userId': userId,
        'mothersMaidenName': data['mothersMaidenName'],
        'childhoodFriend': data['childhoodFriend'],
        'childhoodPet': data['childhoodPet'],
        'customQuestion': data['customQuestion'],
        'customAnswer': data['customAnswer'],
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, String>?> getSecurityQuestions(String userId) async {
    final db = await instance.database;
    final result = await db.query(
      'security_questions',
      columns: [
        'mothersMaidenName',
        'childhoodFriend',
        'childhoodPet',
        'customQuestion',
        'customAnswer'
      ],
      where: 'userId = ?',
      whereArgs: [userId],
    );

    if (result.isNotEmpty) {
      return {
        'mothersMaidenName': result.first['mothersMaidenName'] as String,
        'childhoodFriend': result.first['childhoodFriend'] as String,
        'childhoodPet': result.first['childhoodPet'] as String,
        'customQuestion': result.first['customQuestion'] as String,
        'customAnswer': result.first['customAnswer'] as String,
      };
    } else {
      return null;
    }
  }
}
