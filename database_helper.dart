// lib/database/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'folder_model.dart';  // Assuming folder_model.dart is in the same directory
import 'card_model.dart';    // Assuming card_model.dart is in the same directory

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('card_organizer.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Open the database, creating it if it doesn't exist
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Create the database tables
  Future _createDB(Database db, int version) async {
    // Create Folders table
    await db.execute('''
      CREATE TABLE Folders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL
      );
    ''');

    // Create Cards table
    await db.execute('''
      CREATE TABLE Cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        suit TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        folderId INTEGER NOT NULL,
        FOREIGN KEY (folderId) REFERENCES Folders(id) ON DELETE CASCADE
      );
    ''');
  }

  // ------------------- Folder CRUD Operations -------------------

  // Create a folder
  Future<int> createFolder(FolderModel folder) async {
    final db = await instance.database;
    return await db.insert('Folders', folder.toMap());
  }

  // Get all folders
  Future<List<FolderModel>> getFolders() async {
    final db = await instance.database;
    final result = await db.query('Folders', orderBy: 'name ASC');
    return result.map((json) => FolderModel.fromMap(json)).toList();
  }

  // Update a folder
  Future<int> updateFolder(FolderModel folder) async {
    final db = await instance.database;
    return await db.update(
      'Folders',
      folder.toMap(),
      where: 'id = ?',
      whereArgs: [folder.id],
    );
  }

  // Delete a folder
  Future<int> deleteFolder(int id) async {
    final db = await instance.database;
    return await db.delete(
      'Folders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ------------------- Card CRUD Operations -------------------

  // Create a card
  Future<int> createCard(CardModel card) async {
    final db = await instance.database;
    return await db.insert('Cards', card.toMap());
  }

  // Get all cards in a folder
  Future<List<CardModel>> getCardsInFolder(int folderId) async {
    final db = await instance.database;
    final result = await db.query(
      'Cards',
      where: 'folderId = ?',
      whereArgs: [folderId],
      orderBy: 'name ASC'
    );
    return result.map((json) => CardModel.fromMap(json)).toList();
  }

  // Update a card
  Future<int> updateCard(CardModel card) async {
    final db = await instance.database;
    return await db.update(
      'Cards',
      card.toMap(),
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  // Delete a card
  Future<int> deleteCard(int id) async {
    final db = await instance.database;
    return await db.delete(
      'Cards',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get card count in a folder
  Future<int> getCardCountInFolder(int folderId) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM Cards WHERE folderId = ?',
      [folderId]
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Close the database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
