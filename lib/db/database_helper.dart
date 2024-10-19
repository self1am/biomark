import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _db;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  initDB() async {
    String path = join(await getDatabasesPath(), 'biomark_local.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE RecoveryInfo (
        id INTEGER PRIMARY KEY,
        userId TEXT,
        fullName TEXT,
        dateOfBirth TEXT,
        mothersMaidenName TEXT,
        childhoodBestFriend TEXT,
        childhoodPet TEXT,
        customQuestion TEXT,
        customAnswer TEXT
      )
    ''');
  }

  Future<int> insertRecoveryInfo(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('RecoveryInfo', _hashSensitiveData(row));
  }

  Future<Map<String, dynamic>?> getRecoveryInfo(String userId) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'RecoveryInfo',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Map<String, dynamic> _hashSensitiveData(Map<String, dynamic> data) {
    var sensitiveFields = ['mothersMaidenName', 'childhoodBestFriend', 'childhoodPet', 'customAnswer'];
    for (var field in sensitiveFields) {
      if (data.containsKey(field)) {
        data[field] = _hash(data[field]);
      }
    }
    return data;
  }

  String _hash(String input) {
    var bytes = utf8.encode(input);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }
}