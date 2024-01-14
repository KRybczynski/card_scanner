import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  late Database _database;

  Future<void> deleteAllCards() async {
    await _database.delete('cards');
  }

  Future<Database> getDatabase() async {
    if (_database.isOpen) {
      return _database;
    } else {
      _database = await openDatabase(
        join(await getDatabasesPath(), 'your_database.db'),
        onCreate: (db, version) async {
          // Tworzenie tabeli...
        },
        version: 1,
      );
      return _database;
    }
  }

  Future<void> addCard(String name, String number, String printedTotal) async {
    await _database.transaction((txn) async {
      // Pobierz kartę z tabeli cards na podstawie warunków
      List<Map<String, dynamic>> result = await txn.rawQuery(
          'SELECT * FROM cards WHERE name = ? AND number = ? AND set_printedTotal = ?',
          [name, number, printedTotal]);

      if (result.isNotEmpty) {
        // Skopiuj dane karty do tabeli my_cards
        await txn.rawInsert(
          'INSERT OR REPLACE INTO my_cards(id, name, supertype, hp, types, number, set_printedTotal, images_large) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
          [
            result[0]['id'],
            result[0]['name'],
            result[0]['supertype'],
            result[0]['hp'],
            result[0]['types'],
            result[0]['number'],
            result[0]['set_printedTotal'],
            result[0]['images_large']
          ],
        );
      }
    });
  }

  Future<void> initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'your_database.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS cards (
            id TEXT PRIMARY KEY,
            name TEXT,
            supertype TEXT,
            hp TEXT,
            types TEXT,
            number TEXT,
            set_printedTotal TEXT,
            images_large TEXT
            -- averageSellPrice TEXT,
            -- cardmarket_url TEXT
            -- Dodaj pozostałe pola zgodnie z potrzebami
          )
        ''');
      },
      version: 1,
    );
  }

  Future<void> initDatabaseMy() async {
    // _database = await openDatabase(
    //   join(await getDatabasesPath(), 'your_database.db'),
    //   onCreate: (db, version) async {
    await _database.execute('''
          CREATE TABLE IF NOT EXISTS my_cards (
            id TEXT PRIMARY KEY,
            name TEXT,
            supertype TEXT,
            hp TEXT,
            types TEXT,
            number TEXT,
            set_printedTotal TEXT,
            images_large TEXT
            -- Dodaj pozostałe pola zgodnie z potrzebami
          )
        ''');
  }
  //   version: 2,
  // );

  Future<void> insertCards(List<Map<String, dynamic>> cards) async {
    await _database.transaction((txn) async {
      for (final card in cards) {
        await txn.rawInsert(
          'INSERT OR REPLACE INTO cards(id, name, supertype, hp, types, number, set_printedTotal, images_large) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
          [
            card['id'],
            card['name'],
            card['supertype'],
            card['hp'],
            json.encode(card['types']),
            card['number'],
            card['set']['printedTotal'],
            card['images']['large'],
            // card['cardmarket']['prices']['averageSellPrice'] ?? 0.0,
            // card['cardmarket']['url'] ?? '',
          ],
        );
      }
    });
  }

  Future<List<Map<String, dynamic>>> getCards() async {
    return await _database.rawQuery(
        'SELECT id, name, supertype, hp, types, number, set_printedTotal, images_large FROM cards');
  }

  Future<List<Map<String, dynamic>>> get_my_cards() async {
    return await _database.rawQuery('SELECT * FROM my_cards');
  }
}

Future<List<Map<String, dynamic>>> fetchData(int page) async {
  final response = await http
      .get(Uri.parse('https://api.pokemontcg.io/v2/cards?page=$page'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    final List<Map<String, dynamic>> cards = List.from(data['data']);
    return cards;
  } else {
    throw Exception('Failed to load data');
  }
}
