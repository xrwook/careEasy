import 'package:flutter/material.dart';

class UserInfoProvider extends ChangeNotifier {

  String? _name;
  String? _age;
  String? _email;
  bool? _isLogin;

  String? get name => _name;
  String? get age => _age;
  String? get email => _email;
  bool? get isLogin => _isLogin;
  


  void userInfo(String name, String age, String email, bool isLogin) {
    _name = name;
    _age = age;
    _email = email;
    _isLogin = isLogin;
    notifyListeners();
  }
}