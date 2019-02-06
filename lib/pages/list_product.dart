import 'package:flutter/material.dart';

import './product_edit.dart';
import '../models/product.dart';
import 'package:scoped_model/scoped_model.dart';
import '../scoped-model/main.dart';

class ListProductPage extends StatefulWidget {
  final MainModel mainModel;
  ListProductPage(this.mainModel);
  @override
  State<StatefulWidget> createState() => _ListProductPage();
}

class _ListProductPage extends State<ListProductPage> {

  @override
  void initState() {
    widget.mainModel.fetchData();
    super.initState();
  }

  Widget _buildIconButton(
      BuildContext context, int index, MainModel productModel) {
    return IconButton(
      icon: Icon(Icons.edit),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (BuildContext context) {
            productModel.selectProduct(productModel.allProducts[index].id);
            return ProductEditPage();
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel productModel) {
        List<Product> _products = productModel.allProducts;
        return ListView.builder(
          itemCount: _products.length,
          itemBuilder: (BuildContext context, int index) {
            return Dismissible(
              key: Key(_products[index].title),
              onDismissed: (DismissDirection dismissDirection) {
                if (dismissDirection == DismissDirection.endToStart) {
                  productModel.selectProduct(productModel.allProducts[index].id);
                  productModel.deleteProduct();
                }
              },
              background: Container(
                color: Colors.red,
              ),
              child: Column(children: <Widget>[
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(_products[index].image),
                  ),
                  title: Text(_products[index].title),
                  subtitle: Text('\$${_products[index].price}'),
                  trailing: _buildIconButton(context, index, productModel),
                ),
                Divider(),
              ]),
            );
          },
        );
      },
    );
  }
}
