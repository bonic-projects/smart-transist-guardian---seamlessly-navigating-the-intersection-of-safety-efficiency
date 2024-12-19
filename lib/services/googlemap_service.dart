import 'package:http/http.dart' as http;
import 'dart:convert';

class GooglePlacesService {
  final String apiKey = 'AIzaSyDrLw2JhRLRX6hYF6HyoYZkLtY4XVPGoPQ';

  Future<List<String>> getSuggestions(String query) async {
    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$apiKey'));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<String> suggestions = [];
      for (var prediction in data['predictions']) {
        suggestions.add(prediction['description']);
      }
      return suggestions;
    } else {
      throw Exception('Failed to load suggestions');
    }
  }
}
