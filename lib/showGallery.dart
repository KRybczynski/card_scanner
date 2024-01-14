import 'package:flutter/material.dart';
import 'utils/database.dart';

class ShowGallery extends StatefulWidget {
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
    galleryCards = dbHelper.getMyCards();
  }

  Future<void> initDatabase() async {
    await dbHelper.initDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Card Gallery'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: galleryCards,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No cards in the gallery'),
            );
          } else {
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Liczba kolumn w rzędzie
                crossAxisSpacing: 8, // Odstęp między kolumnami
                mainAxisSpacing: 8, // Odstęp między rzędami
                childAspectRatio:
                    0.7, // Dostosuj proporcję szerokości do wysokości
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
                    );
                  },
                  child: Card(
                    elevation: 4,
                    child: Column(
                      children: [
                        Image.network(
                          '${card['images_large']}',
                          width: double.infinity,
                          height: 200, // Dostosuj wysokość zdjęcia
                          fit: BoxFit.cover,
                        ),
                        ListTile(
                          title: Text('${card['name']}'),
                          subtitle: Text('ID: ${card['id']}'),
                          // Dodaj więcej szczegółów lub dostosuj ListTile według potrzeb
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

  CardDetailsScreen(this.card);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${card['name']} Details'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Wyświetl całe zdjęcie karty, zajmując 80% szerokości ekranu
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Image.network(
                '${card['images_large']}',
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 16.0),
            ListTile(
              title: Text('${card['name']}'),
              subtitle: Text('ID: ${card['id']}'),
            ),
            ListTile(
              title: Text('Supertype'),
              subtitle: Text('${card['supertype']}'),
            ),
            ListTile(
              title: Text('HP'),
              subtitle: Text('${card['hp']}'),
            ),
            ListTile(
              title: Text('Types'),
              subtitle: Text('${card['types']}'),
            ),
            ListTile(
              title: Text('Number'),
              subtitle: Text('${card['number']}'),
            ),
            ListTile(
              title: Text('Set Printed Total'),
              subtitle: Text('${card['set_printedTotal']}'),
            ),
            // Dodaj pozostałe informacje o karcie
          ],
        ),
      ),
    );
  }
}
