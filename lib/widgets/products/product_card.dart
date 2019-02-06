import 'package:flutter/material.dart';

import './price_tag.dart';
import './address_tag.dart';
import '../ui_elements/default_title.dart';
import '../../models/product.dart';
import '../../scoped-model/main.dart';
import 'package:scoped_model/scoped_model.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final productIndex;

  ProductCard(this.product, this.productIndex);
  Widget _buildButtonsBar(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel productModel) {
      return ButtonBar(
        alignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.info),
            color: Theme.of(context).accentColor,
            onPressed: () => Navigator.pushNamed<bool>(context,
                '/product/${productModel.allProducts[productIndex].id}'),
          ),
          IconButton(
            icon: Icon(productModel.allProducts[productIndex].isFavorite
                ? Icons.favorite
                : Icons.favorite_border),
            color: Colors.red,
            onPressed: () {
              productModel
                  .selectProduct(productModel.allProducts[productIndex].id);
              productModel.toggleProductFavoriteStatus();
            },
          )
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        FadeInImage(
          image: NetworkImage(product.image),
          fit: BoxFit.cover,
          placeholder: AssetImage('assets/food.jpg'),
        ),
        Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                DefaultTitle(product.title),
                SizedBox(
                  width: 8.0,
                ),
                PriceTag(product.price.toString()),
              ],
            ),
            padding: EdgeInsets.only(top: 10.0)),
        AddressTage('Union Square, San Francisco'),
        Text(product.userEmail),
        _buildButtonsBar(context),
      ],
    ));
  }
}
