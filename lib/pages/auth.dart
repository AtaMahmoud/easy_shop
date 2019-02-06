import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../scoped-model/main.dart';
import '../models/auth.dart';


class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

TextEditingController _passwordController = TextEditingController();

class _AuthPageState extends State<AuthPage> {
  AuthMode authMode = AuthMode.Login;
  Map<String, dynamic> _formData = {
    'email': null,
    'password': null,
    'acceptTerms': false,
  };
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget _buildEmailTextField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'E-Mail',
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                .hasMatch(value)) {
          return 'Please enter a vaild email address';
        }
      },
      keyboardType: TextInputType.emailAddress,
      onSaved: (String value) {
        _formData['email'] = value;
      },
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
      controller: _passwordController,
      validator: (String value) {
        if (value.isEmpty || value.length < 6) {
          return 'Password invalid';
        }
      },
      decoration: InputDecoration(
        labelText: 'Password',
        filled: true,
        fillColor: Colors.white,
      ),
      obscureText: true,
      onSaved: (String value) {
        _formData['password'] = value;
      },
    );
  }

  Widget _buildConfirmPasswordTextField() {
    return TextFormField(
      validator: (String value) {
        if (_passwordController.text != value) {
          return "Passwords doesn't match";
        }
      },
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        filled: true,
        fillColor: Colors.white,
      ),
      obscureText: true,
    );
  }

  Widget _buildAcceptSwitch() {
    return SwitchListTile(
      value: _formData['acceptTerms'],
      onChanged: (bool value) {
        setState(() {
          _formData['acceptTerms'] = value;
        });
      },
      title: Text('Accept Terms'),
    );
  }

  void _submitForm(Function authenticate) async {
    if (!_formKey.currentState.validate() || !_formData['acceptTerms']) {
      return;
    }
    _formKey.currentState.save();
    Map<String, dynamic> responseInformation;
    if (authMode == AuthMode.Login) {
      responseInformation =
          await authenticate(_formData['email'], _formData['password']);
    } else {
      responseInformation =
          await authenticate(_formData['email'], _formData['password']);
    }

    if (responseInformation['Sucess']) {
      Navigator.pushReplacementNamed(context, '/products');
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text(responseInformation['Message']),
              actions: <Widget>[
                RaisedButton(
                  color: Theme.of(context).accentColor,
                  child: Text(
                    'Ok',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            );
          });
    }
  }

  Widget _buildLoginButton(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel userModel) {
        return userModel.isLoading
            ? CircularProgressIndicator()
            : RaisedButton(
                child:
                    Text('${authMode == AuthMode.Login ? 'LOGIN' : 'SIGNUP'}'),
                color: Theme.of(context).accentColor,
                textColor: Colors.white,
                onPressed: () => _submitForm(userModel.authenticate),
              );
      },
    );
  }

  DecorationImage _buildBackgroundImage() {
    return DecorationImage(
      fit: BoxFit.cover,
      colorFilter:
          ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.dstATop),
      image: AssetImage('assets/background.jpg'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth =
        deviceWidth > 550.0 ? deviceWidth * 0.65 : deviceWidth * 0.95;
    return Scaffold(
      appBar: AppBar(
        title: Text('${authMode == AuthMode.Login ? 'Login' : 'Signup'}'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: _buildBackgroundImage(),
        ),
        padding: EdgeInsets.all(10.0),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: targetWidth,
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    _buildEmailTextField(),
                    SizedBox(
                      height: 10.0,
                    ),
                    _buildPasswordTextField(),
                    SizedBox(
                      height: 10.0,
                    ),
                    authMode == AuthMode.SignUp
                        ? _buildConfirmPasswordTextField()
                        : Container(),
                    _buildAcceptSwitch(),
                    SizedBox(
                      height: 10.0,
                    ),
                    FlatButton(
                      child: Text(
                          "Switch to ${authMode == AuthMode.Login ? 'SignUp' : 'Login'}"),
                      onPressed: () {
                        setState(() {
                          authMode == AuthMode.Login
                              ? authMode = AuthMode.SignUp
                              : authMode = AuthMode.Login;
                        });
                      },
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    _buildLoginButton(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
