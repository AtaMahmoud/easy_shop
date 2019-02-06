import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import 'dart:async';

import '../models/user.dart';
import '../models/product.dart';
import '../models/auth.dart';

mixin ConnectedProductsModel on Model {
  List<Product> _products = [];
  String _selectedProductId;
  User _authenticatedUser;
  bool _isLoading = false;

  Future<bool> addProduct(
    String title,
    String description,
    double price,
    String image,
  ) async {
    _isLoading = true;
    notifyListeners();
    Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'price': price,
      'image':
          "https://amp.thisisinsider.com/images/5a395a06fcdf1e2d008b461b-750-563.jpg",
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id
    };
    try {
      final http.Response response = await http.post(
          'https://easyshop-fbdf2.firebaseio.com/products.json',
          body: json.encode(productData));

      if (response.statusCode != 200 && response.statusCode != 201) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      Map<String, dynamic> responseData = json.decode(response.body);
      Product newProduct = Product(
          id: responseData['name'],
          title: title,
          description: description,
          price: price,
          image:
              'https://amp.thisisinsider.com/images/5a395a06fcdf1e2d008b461b-750-563.jpg',
          userEmail: _authenticatedUser.email,
          userId: _authenticatedUser.id);
      _products.add(newProduct);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

mixin UserModel on ConnectedProductsModel {
  final String apiKey = 'Your API Key';
  Timer _authTimer;
  User get user {
    return _authenticatedUser;
  }

  Future<Map<String, dynamic>> authenticate(String email, String password,
      [AuthMode mode = AuthMode.Login]) async {
    _isLoading = true;
    notifyListeners();
    Map<String, dynamic> user = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };
    http.Response response;
    if (mode == AuthMode.Login) {
      response = await http.post(
          'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=$apiKey',
          body: json.encode(user),
          headers: {'Content-Type': 'application/json'});
    } else {
      response = await http.post(
          'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=$apiKey',
          body: json.encode(user),
          headers: {'Content-Type': 'application/json'});
    }

    Map<String, dynamic> responseBody = json.decode(response.body);
    bool hasError = true;
    String message = 'Something went wrong';

    if (responseBody.containsKey('idToken')) {
      hasError = false;
      message = 'Authentication Succeded';
      _authenticatedUser = User(
          id: responseBody['localId'],
          email: email,
          token: responseBody['idToken']);
      int tokenExpiryTime = int.parse(responseBody['expiresIn']);
      setAuthTimeOut(tokenExpiryTime);
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.setString('token', responseBody['idToken']);
      sharedPreferences.setString('userEmail', email);
      sharedPreferences.setString('userId', responseBody['localId']);
      DateTime now = DateTime.now();
      final DateTime expiryTime = now.add(Duration(seconds: tokenExpiryTime));
      sharedPreferences.setString('expiryTime', expiryTime.toIso8601String());
    } else if (responseBody['error']['message'] == 'EMAIL_NOT_FOUND') {
      message = 'This email not found';
    } else if (responseBody['error']['message'] == 'INVALID_PASSWORD') {
      message = 'This password is invalid';
    } else if (responseBody['error']['message'] == 'EMAIL_EXISTS') {
      message = 'This email is already exists';
    }
    _isLoading = false;
    notifyListeners();
    return {'Sucess': !hasError, 'Message': message};
  }

  void autoAuth() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    final String token = sharedPreferences.getString('token');
    final expiryTimeString = sharedPreferences.getString('expiryTime');

    if (token != null) {
      final DateTime expiryTime = DateTime.parse(expiryTimeString);
      final DateTime now = DateTime.now();

      if (expiryTime.isBefore(now)) {
        _authenticatedUser = null;
        notifyListeners();
        return;
      }

      final String email = sharedPreferences.getString('userEmail');
      final String id = sharedPreferences.getString('userId');
      _authenticatedUser = User(email: email, id: id, token: token);

      final int tokenLifeSpan = expiryTime.difference(now).inSeconds;
      setAuthTimeOut(tokenLifeSpan);

      notifyListeners();
    }
  }

  void logout() async {
    _authenticatedUser = null;
    _authTimer.cancel();
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.remove('token');
    sharedPreferences.remove('userEmail');
    sharedPreferences.remove('userId');
  }

  void setAuthTimeOut(int time) {
    _authTimer=Timer(Duration(seconds: time), logout);
  }
}

mixin ProductModel on ConnectedProductsModel {
  bool _showFavorites = false;

  String get selProductId {
    return _selectedProductId;
  }

  List<Product> get allProducts {
    return List.from(_products);
  }

  List<Product> get displayProducts {
    if (_showFavorites) {
      return _products.where((Product product) => product.isFavorite).toList();
    }
    return List.from(_products);
  }

  bool get showFavoritesOnly {
    return _showFavorites;
  }

  Product get selectedProduct {
    if (_selectedProductId == null) {
      return null;
    }
    return _products.firstWhere((Product product) {
      return product.id == _selectedProductId;
    });
  }

  int get selectedProductIndex {
    return _products.indexWhere((Product product) {
      return product.id == _selectedProductId;
    });
  }

  Future<Null> fetchData() {
    _isLoading = true;
    notifyListeners();
    return http
        .get(
            'https://easyshop-fbdf2.firebaseio.com/products.json?auth=${_authenticatedUser.token}')
        .then((http.Response response) {
      Map<String, dynamic> fetchedData = json.decode(response.body);
      List<Product> _fetchedProducts = [];

      if (fetchedData == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      fetchedData.forEach((String productId, dynamic productData) {
        Product product = Product(
            id: productId,
            title: productData['title'],
            description: productData['description'],
            image: productData['image'],
            price: productData['price'],
            userEmail: productData['userEmail'],
            userId: productData['userId']);
        _fetchedProducts.add(product);
      });
      _products = _fetchedProducts;
      _isLoading = false;
      notifyListeners();
      _selectedProductId = null;
    });
  }

  void deleteProduct() {
    _isLoading = true;
    final deletedProductId = selectedProduct.id;
    _products.removeAt(selectedProductIndex);
    _selectedProductId = null;
    notifyListeners();

    http
        .delete(
            'https://easyshop-fbdf2.firebaseio.com/products/$deletedProductId.json?auth=${_authenticatedUser.token}')
        .then((http.Response response) {
      _isLoading = false;
      notifyListeners();
      return true;
    }).catchError((Error error) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
    notifyListeners();
  }

  Future<bool> updateProduct(
    String title,
    String description,
    double price,
    String image,
  ) {
    _isLoading = true;
    notifyListeners();
    Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'price': price,
      'image':
          "https://amp.thisisinsider.com/images/5a395a06fcdf1e2d008b461b-750-563.jpg",
      'userEmail': selectedProduct.userEmail,
      'userId': selectedProduct.userId
    };
    return http
        .put(
            'https://easyshop-fbdf2.firebaseio.com/products/${selectedProduct.id}.json?auth=${_authenticatedUser.token}',
            body: json.encode(productData))
        .then((http.Response response) {
      Product updatedProduct = Product(
          id: selectedProduct.id,
          title: title,
          description: description,
          price: price,
          image: image,
          userEmail: selectedProduct.userEmail,
          userId: selectedProduct.userId);
      _products[selectedProductIndex] = updatedProduct;
      _selectedProductId = null;
      _isLoading = false;
      notifyListeners();
      return true;
    }).catchError((Error error) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  void toggleProductFavoriteStatus() {
    final bool isCurrentlyFavorite = selectedProduct.isFavorite;
    final bool newFavoriteStatus = !isCurrentlyFavorite;

    Product product = Product(
        id: selectedProduct.id,
        title: selectedProduct.title,
        description: selectedProduct.description,
        image: selectedProduct.image,
        price: selectedProduct.price,
        userEmail: selectedProduct.userEmail,
        userId: selectedProduct.userId,
        isFavorite: newFavoriteStatus);

    _products[selectedProductIndex] = product;
    notifyListeners();
  }

  void selectProduct(String id) {
    _selectedProductId = id;
    notifyListeners();
  }

  void toggleDisplayMode() {
    _showFavorites = !_showFavorites;
    notifyListeners();
  }
}

mixin UtilityModel on ConnectedProductsModel {
  bool get isLoading {
    return _isLoading;
  }
}
