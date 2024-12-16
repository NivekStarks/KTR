import 'package:sqflite/sqflite.dart';  // Importation de sqflite
import 'package:path/path.dart';  // Importation de path pour join
import 'package:path_provider/path_provider.dart';  // Pour obtenir le répertoire de stockage

class DatabaseHelper {
  // Nom de la base de données
  static final _databaseName = "markers.db";
  // Version de la base de données
  static final _databaseVersion = 1;

  // Instance privée de la base de données (Singleton)
  static Database? _database;

  // Constructeur privé pour empêcher l'instanciation directe de la classe
  DatabaseHelper._privateConstructor();

  // L'instance unique de DatabaseHelper
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Cette méthode renvoie une instance de la base de données.
  Future<Database> get database async {
    if (_database != null) {
      return _database!; // Si la base de données est déjà ouverte, la renvoyer
    }
    // Sinon, l'ouvrir
    _database = await _initDatabase();
    return _database!;
  }

  // Initialise la base de données
  Future<Database> _initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    var path = join(dir.path, _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  // Créer la base de données si elle n'existe pas
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE markers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL
      )
    ''');
  }

  // Méthode pour insérer un marqueur
  Future<int> insertMarker(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('markers', row);
  }

  // Méthode pour récupérer tous les marqueurs
  Future<List<Map<String, dynamic>>> getAllMarkers() async {
    Database db = await database;
    return await db.query('markers');
  }

  // Méthode pour fermer la base de données
  Future close() async {
    Database db = await database;
    db.close();
  }
}
