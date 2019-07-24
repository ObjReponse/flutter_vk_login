import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_vk_login/flutter_vk_login.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static final FlutterVkLogin vkSignIn = new FlutterVkLogin();

  String _message = 'Log in/out by pressing the buttons below.';

  Future<Null> _login() async {
    print('i will login to vk');
    try {
      final VkLoginResult result = await vkSignIn.logIn(['email']);

      switch (result.status) {
        case VKLoginStatus.loggedIn:
          final VKAccessToken accessToken = result.token;
          _showMessage('''
         Logged in!
         
         Token: ${accessToken.token}
         User id: ${accessToken.userId}
         Expires: ${accessToken.expiresIn}
         Permissions: ${accessToken.scope}
         ''');
          break;
        case VKLoginStatus.cancelledByUser:
          _showMessage('Login cancelled by the user.');
          break;
        case VKLoginStatus.error:
          _showMessage('Something went wrong with the login process.\n'
              'Here\'s the error VK gave us: ${result.errorMessage}');
          break;
      }
    } catch (e) {
      print('bad login to vk, err: \n $e');
    }
  }

  Future<Null> _logOut() async {
    await vkSignIn.logOut();
    _showMessage('Logged out.');
  }

  void _showMessage(String message) {
    setState(() {
      _message = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Plugin example app'),
        ),
        body: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(_message),
              new RaisedButton(
                onPressed: _login,
                child: new Text('Log in'),
              ),
              new RaisedButton(
                onPressed: _logOut,
                child: new Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
