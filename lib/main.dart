import 'package:flutter/material.dart';
//import 'package:flutter/rendering.dart';
import 'package:scoped_model/scoped_model.dart';
import 'pages/products.dart';
import 'pages/products_admin.dart';
import 'pages/product.dart';
import 'pages/auth.dart';
import './models/product.dart';
import './scoped-model/main.dart';

main() {
  // debugPaintBaselinesEnabled=true;
  //debugPaintSizeEnabled=true;
  // debugPaintPointersEnabled=true;
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final MainModel _mainModel = MainModel();
  @override
  void initState() {
    _mainModel.autoAuth();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainModel>(
      model: _mainModel,
      child: MaterialApp(
        //debugShowMaterialGrid: true,
        theme: ThemeData(
            primarySwatch: Colors.deepOrange,
            brightness: Brightness.light,
            accentColor: Colors.deepPurple),
        //home: AuthPage(),
        routes: {
          '/': (BuildContext context) => ScopedModelDescendant<MainModel>(
                builder: (BuildContext context, Widget child, MainModel mode) {
                  return _mainModel.user == null
                      ? AuthPage()
                      : ProductsPage(_mainModel);
                },
              ),
          '/products': (BuildContext context) => ProductsPage(_mainModel),
          '/admin': (BuildContext context) => ProductsAdmin(_mainModel),
        },
        onGenerateRoute: (RouteSettings settings) {
          List<String> pathNames = settings.name.split('/');
          if (pathNames[0] != '') return null;
          if (pathNames[1] == 'product') {
            String productId = pathNames[2];
            Product product =
                _mainModel.allProducts.firstWhere((Product product) {
              return product.id == productId;
            });
            return MaterialPageRoute<bool>(
                builder: (BuildContext context) => ProductPage(product));
          }
          return null;
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
              builder: (BuildContext context) => ProductsPage(_mainModel));
        },
      ),
    );
  }
}
