import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userName;
  Timer? _authTimer;

  
  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    } else {
      return null;
    }
  }

  String? get userName {
    return _userName;
  }

  Future<void> logout() async{
    _token = null;
    _userName = null;
    _expiryDate = null;
    if (_authTimer!=null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  // restarts the auto log out timer
  void _restartAutoLogoutTimer(){
    if (_authTimer!=null) {
      _authTimer!.cancel();
    }
    final expiryInSeconds = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: expiryInSeconds-60), logout);
  }


  Future<int> _authenticate(String username, String password) async {
    final uri =
        'http://10.0.2.2:8000/api/v1/login/';
    
    final url = Uri.parse(uri);

    // try the whole block and throw an error within the block
    try {
    
        final response = await http.post(url,
            body: {
              'username': username,
              'password': password,
            }
        );

        
        if (response.statusCode != 200) {
          throw ('Your username and password combination is incorrect.');
        }

        _token = json.decode(response.body)['access'];
        _userName = json.decode(response.body)['username'];
        _expiryDate = DateTime.now().add(Duration(
            hours: 162));

        final prefs = await SharedPreferences.getInstance();
        final userData = json.encode({
          'token': _token,
          'userName': _userName,
          'expiryDate': _expiryDate!.toIso8601String()
        });
        prefs.setString('userData', userData);
        
        String? fireToken = await FirebaseMessaging.instance.getToken();
        
        final tokenUrl = 'http://10.0.2.2:8000/api/v1/receive_token/$fireToken/';

        await http.post(Uri.parse(tokenUrl), headers: {'Authorization': 'Bearer $_token'});

        _restartAutoLogoutTimer();
        notifyListeners();
        return 200;
		
    } catch (error) {
      
      throw (error);
      
    }
  }

  Future<bool> tryAutoLogin() async {
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey('userData')) {
        return false;
      }

      final extractedUserData = json.decode(prefs.getString('userData')!);
      final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
      if (expiryDate.isBefore(DateTime.now())) {
        return false;
      }
      _token = extractedUserData['token'];
      _userName = extractedUserData['userName'];
      _expiryDate = expiryDate;
      notifyListeners();
      _restartAutoLogoutTimer();
      return true;
  }

  Future signUp(String firstName, String lastName, String username, String password, String email) async {
    final uri =
        'http://10.0.2.2:8000/api/v1/register/';
    
    final url = Uri.parse(uri);

    // try the whole block and throw an error within the block
    try {
        final response = await http.post(url,
            body: {
              'first_name': firstName,
              'last_name': lastName,
              'username': username,
              'password': password,
			        'email': email
            }
        );

        if (response.statusCode == 201) {
            return _authenticate(username, password);
            
        }else if(response.statusCode == 409 && json.decode(response.body)['message'].contains('Email')){
            
            throw('The email entered has already been used, please use another email.');
        }else if(response.statusCode == 409 && json.decode(response.body)['message'].contains('Username')){
			      
            throw('Username is not available, please choose another username.');
        }

    } catch(e){
      throw(e);
    }
  }

  Future signIn(String username, String password) async {
    return _authenticate(username, password);
  }

  
}
