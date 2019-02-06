import 'package:flutter/material.dart';

import '../scoped-model/main.dart';
import './list_product.dart';
import './product_edit.dart';
import '../widgets/ui_elements/logout_list_tile.dart';

class ProductsAdmin extends StatelessWidget {
  final MainModel mainModel;
  ProductsAdmin(this.mainModel);
  Widget _buildSideDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            automaticallyImplyLeading: false,
            title: Text('Choose'),
          ),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text('All Products'),
            onTap: () => Navigator.pushNamed(context, '/products'),
          ),
          Divider(),
          LogoutListTile(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: _buildSideDrawer(context),
        appBar: AppBar(
          title: Text('Easy List'),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.create),
                text: 'Create Product',
              ),
              Tab(
                icon: Icon(Icons.list),
                text: 'List Products',
              ),
            ],
          ),
        ),
        body: Center(
          child: TabBarView(
            children: <Widget>[
              ProductEditPage(),
              ListProductPage(mainModel),
            ],
          ),
        ),
      ),
    );
  }
}
