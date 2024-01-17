import 'package:flutter/material.dart';
import 'utils/database.dart';
import 'showGallery.dart';

class DeckManager extends StatefulWidget {
  @override
  _DeckManagerState createState() => _DeckManagerState();
}

class _DeckManagerState extends State<DeckManager> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  late Future<List<Map<String, dynamic>>> decks;

  @override
  void initState() {
    super.initState();
    refreshDecks();
  }

  Future<void> refreshDecks() async {
    setState(() {
      decks = dbHelper.getDecks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Deck Manager'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: decks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No decks available'),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final deck = snapshot.data![index];
                return Dismissible(
                  key: UniqueKey(),
                  onDismissed: (direction) async {
                    await dbHelper.deleteDeck(deck['id']);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Deck deleted: ${deck['name']}'),
                      ),
                    );
                    refreshDecks();
                  },
                  background: Container(
                    color: Colors.red,
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20.0),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DeckDetailsScreen(deck),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4,
                      child: ListTile(
                        title: Text('${deck['name']}'),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Dodaj nowy deck
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddDeckDialog(
                onDeckAdded: () {
                  refreshDecks();
                },
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class DeckDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> deck;

  DeckDetailsScreen(this.deck);

  @override
  _DeckDetailsScreenState createState() => _DeckDetailsScreenState();
}

class _DeckDetailsScreenState extends State<DeckDetailsScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  late Future<List<Map<String, dynamic>>> deckCards;

  @override
  void initState() {
    super.initState();
    refreshDeckCards();
  }

  Future<void> refreshDeckCards() async {
    setState(() {
      deckCards = dbHelper.getMyCardsForDeck(widget.deck['id']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.deck['name']} Details'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: deckCards,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No cards in the deck'),
            );
          } else {
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.7,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final card = snapshot.data![index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CardDetailsScreen(card),
                      ),
                    ).then((value) {
                      // Po powrocie z ekranu szczegółów, odśwież deck
                      refreshDeckCards();
                    });
                  },
                  child: Card(
                    elevation: 4,
                    child: Column(
                      children: [
                        Image.network(
                          '${card['images_large']}',
                          width: double.infinity,
                          height: 170,
                          fit: BoxFit.cover,
                        ),
                        ListTile(
                          title: Text('${card['name']}'),
                          subtitle: Text('ID: ${card['id']}'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Dodaj nową kartę do decka
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddCardToDeckDialog(
                deckId: widget.deck['id'],
                onCardAdded: () {
                  refreshDeckCards();
                },
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddCardToDeckDialog extends StatefulWidget {
  final String deckId;
  final VoidCallback onCardAdded;

  const AddCardToDeckDialog(
      {Key? key, required this.deckId, required this.onCardAdded})
      : super(key: key);

  @override
  _AddCardToDeckDialogState createState() => _AddCardToDeckDialogState();
}

class _AddCardToDeckDialogState extends State<AddCardToDeckDialog> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  late Future<List<Map<String, dynamic>>> availableCards;

  @override
  void initState() {
    super.initState();
    refreshAvailableCards();
  }

  Future<void> refreshAvailableCards() async {
    setState(() {
      availableCards = dbHelper.getMyCardsNotInDeck(widget.deckId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Card to Deck'),
      content: FutureBuilder<List<Map<String, dynamic>>>(
        future: availableCards,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No available cards'),
            );
          } else {
            return Container(
              width: double.maxFinite,
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final card = snapshot.data![index];
                  return ListTile(
                    title: Text('${card['name']}'),
                    subtitle: Text('ID: ${card['id']}'),
                    onTap: () async {
                      // Dodaj kartę do decka
                      await dbHelper.addCardToDeck(card['id'], widget.deckId);
                      Navigator.of(context).pop();
                      widget.onCardAdded();
                    },
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}

class AddDeckDialog extends StatefulWidget {
  final VoidCallback onDeckAdded;

  const AddDeckDialog({Key? key, required this.onDeckAdded}) : super(key: key);

  @override
  _AddDeckDialogState createState() => _AddDeckDialogState();
}

class _AddDeckDialogState extends State<AddDeckDialog> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New Deck'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Deck Name'),
          ),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(labelText: 'Description'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            // Dodaj nowy deck do bazy danych
            final dbHelper = DatabaseHelper();
            await dbHelper.addDeck(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: nameController.text,
              description: descriptionController.text,
            );
            Navigator.of(context).pop();
            widget.onDeckAdded();
          },
          child: Text('Add Deck'),
        ),
      ],
    );
  }
}
