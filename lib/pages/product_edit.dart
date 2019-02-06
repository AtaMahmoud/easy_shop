import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../scoped-model/main.dart';
import '../models/product.dart';

class ProductEditPage extends StatefulWidget {
  @override
  _ProductEditPageState createState() => _ProductEditPageState();
}

class _ProductEditPageState extends State<ProductEditPage> {
  final Map<String, dynamic> _formData = {
    'title': null,
    'description': null,
    'price': null,
    'imageUrl': 'assets/food.jpg'
  };
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _submitForm(
      Function addProduct, Function updateProduct, Function setSelectProduct,
      [int selectedProductIndex]) {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();

    if (selectedProductIndex == -1) {
      addProduct(
        _formData['title'],
        _formData['description'],
        _formData['price'],
        _formData['imageUrl'],
      ).then((bool sucess) {
        if (!sucess) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Something went wrong!'),
                  content: Text('Try again later!'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Okay'),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                );
              });
        } else {
          Navigator.pushReplacementNamed(context, '/products')
              .then((_) => setSelectProduct(null));
        }
      });
    } else {
      updateProduct(_formData['title'], _formData['description'],
              _formData['price'], _formData['imageUrl'])
          .then((_) {
        Navigator.pushReplacementNamed(context, '/products')
            .then((_) => setSelectProduct(null));
      });
    }
  }

  Widget _buildTitleFormField(Product product) {
    return TextFormField(
      initialValue: product == null ? '' : product.title,
      validator: (String value) {
        if (value.isEmpty || value.length < 5) {
          return 'Title is required and should be 5+ character length';
        }
      },
      decoration: InputDecoration(labelText: 'Product Title'),
      onSaved: (String value) {
        _formData['title'] = value;
      },
    );
  }

  Widget _buildDescriptionFormField(Product product) {
    return TextFormField(
        initialValue: product == null ? '' : product.description,
        maxLines: 4,
        validator: (String value) {
          if (value.isEmpty || value.length < 10) {
            return 'Description is required and should be 10+ character';
          }
        },
        decoration: InputDecoration(labelText: 'Product Description'),
        onSaved: (String value) {
          _formData['description'] = value;
        });
  }

  Widget _buildPriceFormField(Product product) {
    return TextFormField(
        initialValue: product == null ? '' : product.price.toString(),
        validator: (String value) {
          if (value.isEmpty ||
              !RegExp(r'^(?:[1-9]\d*|0)?(?:[.,]\d+)?').hasMatch(value)) {
            return 'Price is required and should be number';
          }
        },
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: 'Product Price'),
        onSaved: (String value) {
          _formData['price'] = double.parse(value);
        });
  }

  Widget _buildSubmitButton(MainModel productModel) {
    return productModel.isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : RaisedButton(
            child: Text("Save"),
            color: Theme.of(context).accentColor,
            textColor: Colors.white,
            onPressed: () => _submitForm(
                productModel.addProduct,
                productModel.updateProduct,
                productModel.selectProduct,
                productModel.selectedProductIndex),
          );
  }

  Widget _buildPageContent(BuildContext context, MainModel productModel) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth =
        deviceWidth > 550 ? deviceWidth * .65 : deviceWidth * .95;
    final targetPadding = deviceWidth - targetWidth;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        margin: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
            children: <Widget>[
              _buildTitleFormField(productModel.selectedProduct),
              _buildDescriptionFormField(productModel.selectedProduct),
              _buildPriceFormField(productModel.selectedProduct),
              SizedBox(
                height: 10.0,
              ),
              _buildSubmitButton(productModel),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel productModel) {
        final Widget pageContent = _buildPageContent(context, productModel);

        return productModel.selectedProductIndex == -1
            ? pageContent
            : Scaffold(
                appBar: AppBar(
                  title: Text('Edit Product'),
                ),
                body: pageContent,
              );
      },
    );
  }
}
