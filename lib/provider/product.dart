import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './../models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite;
  Product(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.price,
      @required this.imageUrl,
      this.isFavourite = false});

  Future<void> toggleFavouriteState(
      bool value, String token, String userId) async {
    final url = Uri.parse(
      "https://flutter-update-c1af9-default-rtdb.firebaseio.com/userFavourites/$userId/$id.json?auth=$token",
    );
    isFavourite = value;
    notifyListeners();
    try {
      final response = await http.put(url, body: json.encode(value));
      if (response.statusCode >= 400) {
        isFavourite = !value;
        notifyListeners();
        throw HttpException("Couldn't toggle the favourite");
      }
    } catch (e) {
      isFavourite = !value;
      notifyListeners();
      throw HttpException("Couldn't toggle the favourite");
    }
  }
}
