import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DatabaseHelper {
  Database? _database;

  Future<void> deleteAllCards() async {
    if (_database == null) {
      _database = await initDatabase();
    }
    await _database?.delete('cards');
  }

  Future<Database> getDatabase() async {
    if (_database == null) {
      _database = await initDatabase();
    }
    return _database!;
  }

  Future<List<Map<String, dynamic>>> getDecks() async {
    if (_database == null) {
      _database = await initDatabase();
    }
    return await _database!.rawQuery('SELECT * FROM decks');
  }

  Future<Database> initDatabase() async {
    print('-----------------------Initialize--------------------------------');

    return openDatabase(
      join(await getDatabasesPath(), 'your_database.db'), version: 3,
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
            images_large TEXT,
            cardmarket_prices_averageSellPrice TEXT NULL,
            cardmarket_url TEXT NULL
          )
        ''');
        // Add the creation of my_cards table if it doesn't exist
        await db.execute('''
          CREATE TABLE IF NOT EXISTS my_cards (
            id TEXT PRIMARY KEY,
            name TEXT,
            supertype TEXT,
            hp TEXT,
            types TEXT,
            number TEXT,
            set_printedTotal TEXT,
            images_large TEXT,
            cardmarket_prices_averageSellPrice TEXT NULL,
            cardmarket_url TEXT NULL,
            deck_id TEXT,  -- Nowe pole przechowujące id decka
            FOREIGN KEY (deck_id) REFERENCES decks(id)  -- Klucz obcy do powiązania z tabelą decks
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS decks (
            id TEXT PRIMARY KEY,
            name TEXT,
            description TEXT
          )
        ''');
      },
      // version: 2,
    );
  }

  // Future<void> initDatabaseMy() async {
  //   await _database?.execute('''
  //         CREATE TABLE IF NOT EXISTS my_cards (
  //           id TEXT PRIMARY KEY,
  //           name TEXT,
  //           supertype TEXT,
  //           hp TEXT,
  //           types TEXT,
  //           number TEXT,
  //           set_printedTotal TEXT,
  //           images_large TEXT
  //         )
  //       ''');
  // }

  Future<void> addCard({
    required String name,
    required String number,
    required String printedTotal,
    String? deckId,
  }) async {
    if (_database == null) {
      _database = await initDatabase();
    }
    await _database?.transaction((txn) async {
      List<Map<String, dynamic>> result = await txn.rawQuery(
        'SELECT * FROM cards WHERE name = ? AND number = ? AND set_printedTotal = ?',
        [name, number, printedTotal],
      );

      if (result.isNotEmpty) {
        await txn.rawInsert(
          'INSERT OR REPLACE INTO my_cards(id, name, supertype, hp, types, number, set_printedTotal, images_large, cardmarket_prices_averageSellPrice, cardmarket_url, deck_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [
            result[0]['id'],
            result[0]['name'],
            result[0]['supertype'],
            result[0]['hp'],
            result[0]['types'],
            result[0]['number'],
            result[0]['set_printedTotal'],
            result[0]['images_large'],
            result[0]['cardmarket_prices_averageSellPrice'],
            result[0]['cardmarket_url'],
            deckId, // Przypisanie decka do karty
          ],
        );
      }
    });
  }

  Future<void> addDeck({
    required String id,
    required String name,
    required String description,
  }) async {
    if (_database == null) {
      _database = await initDatabase();
    }
    await _database?.insert(
      'decks',
      {'id': id, 'name': name, 'description': description},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteDeck(String deckId) async {
    if (_database == null) {
      _database = await initDatabase();
    }
    await _database?.delete('decks', where: 'id = ?', whereArgs: [deckId]);
  }

  Future<void> insertCards(List<Map<String, dynamic>> cards) async {
    if (_database == null) {
      _database = await initDatabase();
    }

    await _database?.transaction((txn) async {
      for (final card in cards) {
        final id = card['id'];
        final name = card['name'];
        final supertype = card['supertype'];
        final hp = card['hp'];
        final types = json.encode(card['types']);
        final number = card['number'];
        final setPrintedTotal = card['set']['printedTotal'];
        final imagesLarge = card['images']['large'];

        // Sprawdzenie warunkowe przed dostępem do atrybutów cardmarket
        final cardmarketPricesAverageSellPrice =
            card['cardmarket']['prices']['averageSellPrice'] ?? null;
        final cardmarketUrl = card['cardmarket']['url'] ?? null;

        await txn.rawInsert(
          'INSERT OR REPLACE INTO cards(id, name, supertype, hp, types, number, set_printedTotal, images_large, cardmarket_prices_averageSellPrice, cardmarket_url) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [
            id,
            name,
            supertype,
            hp,
            types,
            number,
            setPrintedTotal,
            imagesLarge,
            cardmarketPricesAverageSellPrice,
            cardmarketUrl,
          ],
        );
      }
    });
  }

  Future<List<Map<String, dynamic>>> getCards() async {
    if (_database == null) {
      _database = await initDatabase();
    }
    return await _database!.rawQuery('SELECT * FROM cards');
  }

  Future<List<Map<String, dynamic>>> getMyCards() async {
    if (_database == null) {
      _database = await initDatabase();
    }
    return await _database!.rawQuery('SELECT * FROM my_cards');
  }

  Future<List<Map<String, dynamic>>> getMyCardsForDeck(String deckId) async {
    if (_database == null) {
      _database = await initDatabase();
    }
    return await _database!
        .rawQuery('SELECT * FROM my_cards WHERE deck_id = ?', [deckId]);
  }

  Future<List<Map<String, dynamic>>> getMyCardsNotInDeck(String deckId) async {
    if (_database == null) {
      _database = await initDatabase();
    }
    return await _database!.rawQuery(
        'SELECT * FROM my_cards WHERE deck_id IS NULL OR deck_id != ?',
        [deckId]);
  }

  Future<void> addCardToDeck(String cardId, String deckId) async {
    if (_database == null) {
      _database = await initDatabase();
    }
    await _database?.rawUpdate(
        'UPDATE my_cards SET deck_id = ? WHERE id = ?', [deckId, cardId]);
  }

  Future<void> deleteMyCard(String cardId) async {
    if (_database == null) {
      _database = await initDatabase();
    }

    await _database?.delete(
      'my_cards',
      where: 'id = ?',
      whereArgs: [cardId],
    );
  }

  Future<void> syncCardsWithApi() async {
    Fluttertoast.showToast(msg: 'Starting synchronization...');

    const totalPages = 69;

    for (int page = 1; page <= totalPages; page++) {
      try {
        final List<Map<String, dynamic>> cards = await fetchData(page);
        await insertCards(cards);
        print('Synchronized page $page of $totalPages');
      } catch (e) {
        print('Error synchronizing page $page: $e');
      }
    }

    // Fluttertoast.showToast(msg: 'Synchronization completed.');
  }

  Future<List<Map<String, dynamic>>> fetchData(int page) async {
    try {
      final response = await http
          .get(Uri.parse('https://api.pokemontcg.io/v2/cards?page=$page'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<Map<String, dynamic>> cards =
            List<Map<String, dynamic>>.from(data['data'] ?? []);

        // Sprawdź czy karty mają atrybuty 'prices' i 'url', jeśli nie, ustaw wartości domyślne
        cards.forEach((card) {
          card['cardmarket'] ??= {};
          card['cardmarket']['prices'] ??= {};
          card['cardmarket']['url'] ??= '';
        });

        return cards;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
      throw Exception('Failed to load data');
    }
  }
}
