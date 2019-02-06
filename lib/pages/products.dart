import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../scoped-model/main.dart';
import '../widgets/products/products.dart';
import '../widgets/ui_elements/logout_list_tile.dart';

class ProductsPage extends StatefulWidget {
  final MainModel mainModel;
  ProductsPage(this.mainModel);

  @override
  State<StatefulWidget> createState() => _ProductsPage();
}

class _ProductsPage extends State<ProductsPage> {
  Widget _buildProductsList() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel mainModel) {
        Widget content = Center(
          child: Text('Products not found!'),
        );
        if (mainModel.displayProducts.length > 0 && !mainModel.isLoading) {
          content = Products();
        } else if (mainModel.isLoading) {
          return Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(onRefresh: mainModel.fetchData,child: content);
      },
    );
  }

  Widget _buildSideDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            automaticallyImplyLeading: false,
            title: Text('Choose'),
          ),
          ListTile(
            leading: Icon(Icons.create),
            title: Text('Manage Product'),
            onTap: () => Navigator.pushNamed(context, '/admin'),
          ),
          Divider(),
          LogoutListTile(),
        ],
      ),
    );
  }

  @override
  void initState() {
    widget.mainModel.fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildSideDrawer(context),
      appBar: AppBar(
        title: Text('Easy List'),
        actions: <Widget>[
          ScopedModelDescendant<MainModel>(builder:
              (BuildContext context, Widget child, MainModel productModel) {
            return IconButton(
              icon: Icon(productModel.showFavoritesOnly
                  ? Icons.favorite
                  : Icons.favorite_border),
              onPressed: () {
                productModel.toggleDisplayMode();
              },
            );
          }),
        ],
      ),
      body: _buildProductsList(),
    );
  }
}
