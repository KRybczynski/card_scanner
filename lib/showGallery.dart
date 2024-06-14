import 'package:flutter/material.dart';
import 'utils/database.dart';
import 'package:url_launcher/url_launcher.dart';

class ShowGallery extends StatefulWidget {
  const ShowGallery({super.key});

  @override
  _ShowGalleryState createState() => _ShowGalleryState();
}

class _ShowGalleryState extends State<ShowGallery> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  late Future<List<Map<String, dynamic>>> galleryCards;

  @override
  void initState() {
    super.initState();
    initDatabase();
    // Pobieranie kart po każdej zmianie stanu
    refreshGallery();
  }

  Future<void> initDatabase() async {
    await dbHelper.initDatabase();
  }

  // Nowa metoda do odświeżania zawartości galerii
  Future<void> refreshGallery() async {
    setState(() {
      galleryCards = dbHelper.getMyCards();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Gallery'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: galleryCards,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No cards in the gallery'),
            );
          } else {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                      // Po powrocie z ekranu szczegółów, odśwież galerię
                      refreshGallery();
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
    );
  }
}

class CardDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> card;

  const CardDetailsScreen(this.card, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${card['name']} Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // Dodaj logikę usuwania karty
              deleteCard(context, card);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Wyświetl całe zdjęcie karty, zajmując 80% szerokości ekranu
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Image.network(
                '${card['images_large']}',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16.0),
            ListTile(
              title: Text('${card['name']}'),
              subtitle: Text('ID: ${card['id']}'),
            ),
            ListTile(
              title: const Text('Supertype'),
              subtitle: Text('${card['supertype']}'),
            ),
            ListTile(
              title: const Text('HP'),
              subtitle: Text('${card['hp']}'),
            ),
            ListTile(
              title: const Text('Types'),
              subtitle: Text('${card['types']}'),
            ),
            ListTile(
              title: const Text('Number'),
              subtitle: Text('${card['number']}'),
            ),
            ListTile(
              title: const Text('Printed Total'),
              subtitle: Text('${card['set_printedTotal']}'),
            ),
            ListTile(
              title: const Text('Average Sell Price'),
              subtitle: Text('${card['cardmarket_prices_averageSellPrice']}'),
            ),
            ListTile(
              title: const Text('Cardmarket URL'),
              subtitle: GestureDetector(
                onTap: () async {
                  final String url = card['cardmarket_url'];
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
                child: Text(
                  '${card['cardmarket_url']}',
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blue, // Kolor linku
                  ),
                ),
              ),
            ),
            // Dodaj pozostałe informacje o karcie
          ],
        ),
      ),
    );
  }

  Future<void> deleteCard(
      BuildContext context, Map<String, dynamic> card) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.getDatabase();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Card'),
          content: const Text(
              'Are you sure you want to delete this card from your collection?'),
          actions: [
            TextButton(
              onPressed: () async {
                // Usuń kartę
                await dbHelper.getDatabase();
                await dbHelper.deleteMyCard(card['id']);
                Navigator.of(context).pop(); // Zamknij aktualny ekran
                Navigator.of(context).pop(); // Wróć do ekranu galerii
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }
}
