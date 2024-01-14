import 'dart:convert';
import 'package:http/http.dart' as http;

void fetchData() async {
  for (int i = 1; i < 70; i++) {
    final response = await http.get(
        Uri.parse('https://api.pokemontcg.io/v2/cards?page=' + i.toString()));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<Map<String, dynamic>> cards = List.from(data['data']);

      print(cards.length);
      print(cards[0]['name']);
    } else {
      throw Exception('Failed to load data');
    }
  }
}
