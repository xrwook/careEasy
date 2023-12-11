import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:careeasy/second.dart';
import 'package:careeasy/webview.dart';
import 'package:careeasy/mapWebview.dart';
import 'package:careeasy/permission.dart';
import 'package:careeasy/naver_map_plugin_example/map_main.dart';
import 'package:careeasy/flutter_provider.dart';
import 'package:careeasy/provider/test_provider.dart';
import 'package:careeasy/provider/user_info_provider.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;


class careeasy extends StatefulWidget {
  const careeasy({super.key});

  @override 
  careeasyState createState() => careeasyState();
}

class careeasyState extends State<careeasy> {
  
  @override
  void initState() {
    super.initState();
  }

  var permissionState = false;
  final logger = Logger(printer: PrettyPrinter());

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("careeasy"),
        backgroundColor: Colors.amber[700],
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30.0, 40.0, 0.0, 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:  [
            const Text(
              "NAME",
              style: TextStyle(
                color: Colors.amber,
                letterSpacing: 2.0
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Text(
              context.watch<UserInfoProvider>().name ?? "WOOK",
              style: const TextStyle(
                color: Colors.cyan,
                letterSpacing: 2.0,
                fontSize: 28.0,
                fontWeight: FontWeight.bold
              ),
            ),
            ElevatedButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SecondRoute()),
                );
              }, 
              child: const Text("page move")
            ),
            ElevatedButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return  ChangeNotifierProvider(
                      create: (context) => CountProvider(),
                      child: const WebViewExample(),
                    );
                  }),
                );
              }, 
              child: const Text("webview_flutter_test")
            ),
            ElevatedButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    // return  ChangeNotifierProvider(
                    //   create: (context) => CountProvider(),
                    //   child: const ProviderTest(),
                    // );
                    return MultiProvider(
                      providers: [
                        ChangeNotifierProvider(
                          create: (context) => CountProvider(),
                        ),
                        // ChangeNotifierProvider(
                        //   create: (context) => UserInfoProvider(),
                        // )
                      ],
                      child: const ProviderTest(),
                    );
                  }),
                );
              }, 
              child: const Text(" provider 상태관리")
            ),
            ElevatedButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyAppMap()),
                );
              }, 
              child: const Text("xxxxxxxxxxxxxx ")
            ),
            ElevatedButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MapWebView()),
                );
              },
              child: const Text("지도 웹뷰")
            ),
            ElevatedButton(
              onPressed: (){
                postTest().then((value) {
                  Map<String, dynamic> res = jsonDecode(value);
                  logger.d("==============");
                  logger.e(res["headers"]);
                });
              },
              child: const Text("POST TEST")
            ),
            const UserPermission(),
          ],
        ),
      ),
    );
  }

  Future postTest() async {
    Map<String, dynamic> param = {};
    final url = Uri.https("httpbin.org", "/post", param);
    var response = await http.post(url);
    late var resData;
    if (response.statusCode == 200) {
      resData = response.body;
      logger.d(resData);
    }else{
      logger.e('Request failed with status: ${response.statusCode}.');
    }
    List coursename = [];
    coursename..add(response.statusCode)..add(resData)..add(response.headers);

    return resData;
  }


  Future<bool> requestCameraPermission(BuildContext context) async {
    // PermissionStatus status = await Permission.storage.request();
    Map<Permission, PermissionStatus> statuses = await [Permission.camera, Permission.storage].request();
    // var status = await requestCameraPermission(context);
    if (!mounted) return false;
    if (statuses[Permission.camera]!.isGranted == false ||
      statuses[Permission.storage]!.isGranted == false) {
      // 허용이 안된 경우
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: const Text("권한 설정을 확인해주세요."),
            actions: [
              ElevatedButton(
                onPressed: () {
                  openAppSettings(); // 앱 설정으로 이동
                },
                child: const Text('설정하기')
              ),
            ],
          );
        }
      );
      logger.d("permission denied by user");
      return false;
    }
    logger.d("permission ok");
    return true;
  }
}
