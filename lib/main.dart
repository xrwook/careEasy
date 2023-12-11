import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:careeasy/careeasy.dart';
import 'package:provider/provider.dart';
import 'package:careeasy/provider/user_info_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

void main() => runApp(const MyApp());
final logger = Logger(printer: PrettyPrinter());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => UserInfoProvider(),
        child: const MaterialApp(
          title: "careeasy",
          home: careeasy(),
        ));
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var username = TextEditingController(); // id 입력 저장
  var password = TextEditingController(); // pw 입력 저장

  static final storage =
      FlutterSecureStorage(); // FlutterSecureStorage를 storage로 저장
  dynamic userInfo = ''; // storage에 있는 유저 정보를 저장

  //flutter_secure_storage 사용을 위한 초기화 작업
  @override
  void initState() {
    super.initState();

    // 비동기로 flutter secure storage 정보를 불러오는 작업
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _asyncMethod();
    });
  }

  _asyncMethod() async {
    // read 함수로 key값에 맞는 정보를 불러오고 데이터타입은 String 타입
    // 데이터가 없을때는 null을 반환
    userInfo = await storage.read(key: 'login');

    // user의 정보가 있다면 로그인 후 들어가는 첫 페이지로 넘어가게 합니다.
    if (userInfo != null) {
      Navigator.pushNamed(context, '/main');
    } else {
      logger.d('로그인이 필요합니다');
    }
  }

  // 로그인 버튼 누르면 실행
  loginAction(accountName, password) async {
    try {
      var dio = Dio();
      var param = {'account_name': '$accountName', 'password': '$password'};

      Response response = await dio.post('로그인 API URL', data: param);

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.data['user_id'].toString());
        // 직렬화를 이용하여 데이터를 입출력하기 위해 model.dart에 Login 정의 참고
        var val = jsonEncode(Login('$accountName', '$password', '$jsonBody'));

        await storage.write(
          key: 'login',
          value: val,
        );
        logger.d('접속 성공!');
        return true;
      } else {
        logger.d('error');
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 아이디 입력 영역
          TextField(
            controller: username,
            decoration: const InputDecoration(
              labelText: 'Username',
            ),
          ),
          // 비밀번호 입력 영역
          TextField(
            controller: password,
            decoration: const InputDecoration(
              labelText: 'Password',
            ),
          ),
          // 로그인 버튼
          ElevatedButton(
            onPressed: () async {
              if (await loginAction(username.text, password.text) == true) {
                logger.d('로그인 성공');
                Navigator.pushNamed(context, '/service'); // 로그인 이후 서비스 화면으로 이동
              } else {
                logger.d('로그인 실패');
              }
            },
            child: const Text('로그인 하기'),
          ),
        ],
      ),
    );
  }
}

class Login {
  final String accountName;
  final String password;
  final String user_id;

  Login(this.accountName, this.password, this.user_id);

  Login.fromJson(Map<String, dynamic> json)
      : accountName = json['accountName'],
        password = json['password'],
        user_id = json['user_id'];

  Map<String, dynamic> toJson() => {
        'accountName': accountName,
        'password': password,
        'user_id': user_id,
      };
}
