import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:logger/logger.dart';
import 'package:image_picker/image_picker.dart';
import 'popup/camera_popup.dart';
import 'popup/naver_map.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:careeasy/provider/user_info_provider.dart';
import 'package:provider/provider.dart';

class WebViewExample extends StatefulWidget {
  const WebViewExample({super.key});

  @override 
  WebViewExampleState createState() => WebViewExampleState();
}

class WebViewExampleState extends State<WebViewExample> {


  @override
  void initState() {
    _initWebViewController();
    super.initState();
    // if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  late TextEditingController textController;
  late final WebViewController _webViewController;
  var logger = Logger(printer: PrettyPrinter());
  String passData = "ReactJS testData";
  bool commonBackButton = false;
  List<XFile>? imageList = [];
  String currentUrl = "";
  bool offstage = false;

    void _initWebViewController() {
      const String _webUrl = "http://172.30.1.9:9000/mylist";
      _webViewController = WebViewController()
        ..loadRequest(Uri.parse(_webUrl))
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..enableZoom(false)
        ..addJavaScriptChannel("cameraPopup", onMessageReceived: _cameraPopup)
        ..addJavaScriptChannel("naverMapPopup", onMessageReceived: _naverMapPopup)
        ..addJavaScriptChannel("reactChangeBackEvent", onMessageReceived: _reactChangeBackEvent)
        ;

        // ..setBackgroundColor(const Color(0x00000000))
        // ..loadRequest(Uri.parse(_webUrl));
  }

  // _webViewController.loadRequest(Uri.parse("http://172.30.1.9:9000/mylist"));
  //   _webViewController.enableZoom(false); 
  //   _webViewController.addJavaScriptChannel(name, onMessageReceived: onMessageReceived)
  
  
  @override
  Widget build(BuildContext context) { 
    return Scaffold(
      appBar: AppBar(
        title: Text(context.watch<UserInfoProvider>().name ?? "xxxxxx"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            if(!commonBackButton){
              _goBack();
            } else {
              var backButtonEvent = 'window.backButtonEvent("${!commonBackButton}")';
              _webViewController.runJavaScriptReturningResult(backButtonEvent);
            }
          },
        ), 
        actions: [
          IconButton(
            onPressed: () {
              _webViewController.runJavaScriptReturningResult('window.flutter_to_react("$passData")');
            },
            icon: const Icon(
              Icons.favorite,
              color: Colors.pink,
              size: 24.0
            )
          ),
        ],
      ),
      body: Builder(builder: (BuildContext context) {
        return (
          // WillPopScope(
          //   onWillPop: () {
          //     if(!commonBackButton){
          //       return _goBack();
          //     } else {
          //       var backButtonEvent = 'window.backButtonEvent("${!commonBackButton}")';
          //       // _webViewController.runJavaScriptReturningResult(backButtonEvent);
          //       _webViewController.runJavaScriptReturningResult(backButtonEvent);
          //       return Future.value(false);
          //     }
          //   },
          //   child: Scaffold(
          //     body: WebViewWidget(controller: _webViewController),
          //   ),
          // )
          PopScope(
            canPop: true,
            onPopInvoked: (didPop) {
              // _goBack();
              logger.d("onPopInvoked, didPop: $didPop");
              if(!commonBackButton){
                _goBack();
              } else {
                 var backButtonEvent = 'window.backButtonEvent("${!commonBackButton}")';
                 _webViewController.runJavaScriptReturningResult(backButtonEvent);
                Future.value(false);
              }
            }, 
            child: Scaffold(
              body: WebViewWidget(controller: _webViewController),
            ),
          )
        );
      }),
    );
  }

  void _cameraPopup(JavaScriptMessage message) {
    logger.d(message.message);
    logger.e("cameraPopup open");
    showCameraPopup();
  }

  // void _passData (JavaScriptMessage message) {
  //   logger.e(message);
  // }


  void _naverMapPopup (JavaScriptMessage message) {
    showNaverMapPopup(_webViewController);
  }


  void _reactChangeBackEvent (JavaScriptMessage message) {
    var val = message.message;
    commonBackButton = val.toLowerCase() == 'true';
  }

  // late Timer timer;
  // void startTimer() {
  //   timer = Timer.periodic(const Duration(seconds: 1), (t) {
  //     logger.d("oooooooooooooooooooooooooooooooooooooooo imageList  =======> $imageList");
  //   });
  // }
  // void stopTimer() {
  //   logger.d("oooooooooooooooooooooooooooooooooooooooo commonBackButton  =======> $commonBackButton");
  //   timer.cancel();
  // }

  late Timer timer;
  final jsonEncoder = const JsonEncoder();
  void startTimer() {
    // timer = Timer.periodic(const Duration(seconds: 5), (t) async {
    //   HashMap location = await getCurrentLocation();
    //   logger.e(location);
    //   var currentLocation = 'window.currentLocation("${jsonEncoder.convert(location)}")';
    //   _webViewController.runJavaScriptReturningResult(currentLocation);
    // });
  }
  void stopTimer() {
    timer.cancel();
  }

  Future<bool> _goBack() async{
    var canGoBack = await _webViewController.canGoBack();
    if(canGoBack){
      _webViewController.goBack();
      return Future.value(false);
    }else{
      Navigator.pop(context);
      return Future.value(false);
    }
  }


  void showCameraPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return CameraPopupWidget(imageCallback: (list) => imageStateChange(list));
      }
    );
  }

  void imageStateChange(list) {
    setState(() {
      imageList = list;
      if(imageList!.isNotEmpty){
        sendImage(imageList!);
      }
    });
  }

  void sendImage(List<XFile> imageList) async {
    List<String> imageStrList = [];
    for (var element in imageList) {
      final bytes = File(element.path).readAsBytesSync();
      imageStrList.add(base64Encode(bytes));
    }
    String images = imageStrList.join("__careeasy__");
    var sendData = 'window.SnedBase64Encode("$images")';
    await _webViewController.runJavaScriptReturningResult(sendData);
  }

  void showNaverMapPopup(WebViewController webViewController) {
    showGeneralDialog(
      barrierDismissible: false,
      context: context,
      pageBuilder: (_,__,___) {
        // return  Offstage(
        //   offstage: offstage,
        //   child: NaverMapPopup(webViewController, isOffstage: (isOffstage) => setState(() {
        //     offstage = isOffstage;
        //   })),
        // );
        return const NaverMapPopup();
      }
    );
  }

  // Future<HashMap> getCurrentLocation() async {
  //   Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  //   HashMap location = HashMap();
  //   location["latitude"] = position.latitude;
  //   location["longitude"] = position.longitude;
  //   return location;
  // }

} 

//https://stackoverflow.com/questions/71392829/flutter-edit-or-delete-popup-of-webview  https://humorpick.com/bbs/board.php?bo_table=humor&wr_id=136716
