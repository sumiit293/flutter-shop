import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './../screens/edit_product_screen.dart';
import './../provider/products.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;

  UserProductItem(this.id, this.title, this.imageUrl);

  Future<void> _deleteProduct(BuildContext context, scafold, String id) async {
    print("called");
    try {
      await Provider.of<Products>(context, listen: false).deleteProduct(id);
    } catch (_) {
      print("Fails..");
      scafold.showSnackBar(SnackBar(
        content: Text("Deleting failed"),
        duration: Duration(milliseconds: 5),
      ));
    }
  }

  Widget build(BuildContext context) {
    final scafold = Scaffold.of(context);
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      trailing: Container(
        width: 100,
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(EditProductScreen.routeName, arguments: id);
              },
              color: Theme.of(context).primaryColor,
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _deleteProduct(context, scafold, id);
              },
              color: Theme.of(context).errorColor,
            )
          ],
        ),
      ),
    );
  }
}
