import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';


class UserPermission extends StatefulWidget {
  const UserPermission({super.key});

  @override
  UserPermissionState createState() => UserPermissionState();
}

class UserPermissionState extends State<UserPermission> {
  final logger = Logger(printer: PrettyPrinter());
  var permissionState = false;
  
  Future<bool> requestCameraPermission(BuildContext context) async {
    // PermissionStatus status = await Permission.storage.request();
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera, 
      Permission.storage, 
      Permission.location,
    ].request();
    // var status = await requestCameraPermission(context);
    if (!mounted) return false;
    if (statuses[Permission.camera]!.isGranted == false ||
      statuses[Permission.storage]!.isGranted == false ||
      statuses[Permission.location]!.isGranted == false) {
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


  @override
  Widget build(BuildContext context) {
    return (permissionState == false ? ElevatedButton(
      onPressed: () async {
        var status = await requestCameraPermission(context);
        setState(() {
          permissionState = status;
        });
      },
      child: const Text("권한 획득")
    ) : const Text('권한있음'));
  }
}