import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'product.dart';
import './../models/http_exception.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];
  String token;
  String userId;
  Products(this.token, this._items, this.userId);

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favouriteItem {
    return _items.where((prod) => prod.isFavourite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : "";
    try {
      var url = Uri.parse(
        "https://flutter-update-c1af9-default-rtdb.firebaseio.com/products.json?auth=$token&$filterString",
      );
      var url1 = Uri.parse(
        "https://flutter-update-c1af9-default-rtdb.firebaseio.com/userFavourites/$userId.json?auth=$token",
      );
      final res = await http.get(url);
      final exctractedData = json.decode(res.body) as Map<String, dynamic>;
      final List<Product> loadedData = [];
      if (exctractedData == null) {
        return;
      }
      final favouriteResponse = await http.get(url1);
      final favData = json.decode(favouriteResponse.body);
      exctractedData.forEach((prodId, prodData) {
        loadedData.add(Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            imageUrl: prodData['imageUrl'],
            isFavourite: favData == null ? false : favData[prodId] ?? false));
      });
      _items = loadedData;
      notifyListeners();
    } catch (error) {
      throw ("Could not fetch items");
    }
  }

  Future<void> addProduct(Product product) async {
    var url = Uri.parse(
      "https://flutter-update-c1af9-default-rtdb.firebaseio.com/products.json?auth=$token",
    );
    try {
      final res = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': userId
          }));

      final newProduct = Product(
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl,
          id: json.decode(res.body)['name'],
          isFavourite: product.isFavourite);
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw ("Something went wrong !");
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final url = Uri.parse(
      "https://flutter-update-c1af9-default-rtdb.firebaseio.com/products/$id.json?auth=$token",
    );

    try {
      await http.patch(
        url,
        body: json.encode({
          'title': newProduct.title,
          'description': newProduct.description,
          'imageUrl': newProduct.imageUrl,
          'price': newProduct.price,
        }),
      );
      final prodIndex = _items.indexWhere((prod) => prod.id == id);
      if (prodIndex >= 0) {
        _items[prodIndex] = newProduct;
        notifyListeners();
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
      "https://flutter-update-c1af9-default-rtdb.firebaseio.com/products/$id.json?auth=$token",
    );
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    var prod = _items[prodIndex];
    if (prodIndex >= 0) {
      _items.removeAt(prodIndex);
    }
    await http.delete(url).then((response) {
      print(response.statusCode);
      if (response.statusCode >= 400) {
        throw HttpException("Could not delete product");
      }
      prod = null;
    }).catchError((error) {
      print(error);
      _items.insert(prodIndex, prod);
      throw (error);
    });
    notifyListeners();
  }
}
