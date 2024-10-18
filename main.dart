import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import './folder_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the database
  final database = await initializeDatabase();

  runApp(CardOrganizerApp(database: database));
}

// Method to initialize the SQLite database
Future<Database> initializeDatabase() async {
  return openDatabase(
    join(await getDatabasesPath(), 'card_organizer.db'),
    onCreate: (db, version) {
      return db.execute(
        '''
        CREATE TABLE folders(
          id INTEGER PRIMARY KEY, 
          name TEXT, 
          created_at TEXT
        );
        CREATE TABLE cards(
          id INTEGER PRIMARY KEY, 
          name TEXT, 
          suit TEXT, 
          imageUrl TEXT, 
          folderId INTEGER, 
          FOREIGN KEY (folderId) REFERENCES folders(id)
        );
        '''
      );
    },
    version: 1,
  );
}

class CardOrganizerApp extends StatelessWidget {
  final Database database;
  const CardOrganizerApp({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Organizer App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FolderListScreen(database: database),  // Load FolderListScreen
    );
  }
}
