import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:logger/logger.dart';

class MapWebView extends StatefulWidget {
  const MapWebView({super.key});

  @override
  MapWebViewState createState() => MapWebViewState();
}

class MapWebViewState extends State<MapWebView> {

  final Completer<WebViewController> _controller = Completer<WebViewController>();
  late WebViewController _webViewController;
  final logger = Logger(printer: PrettyPrinter());
  String passData = "ReactJS testData";

  @override
  Widget build(BuildContext context) { 
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter WebView example'),
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
        return  TextButton(
          onPressed: () {
            _webViewController.runJavaScriptReturningResult('window.flutter_to_react("$passData")');
          },
          child: const Text("data"),
        );
        // WebView(
        //   initialUrl: 'https://web.careeasy.com/map',
        //   // initialUrl: 'http://192.168.0.221:3000/map',
        //   javascriptMode: JavascriptMode.unrestricted,
        //   gestureNavigationEnabled: true,
        //   javascriptChannels: <JavascriptChannel>{
        //     _reactToFlutter(context),
        //   },
        //   onWebViewCreated: (WebViewController webViewController) {
        //     _webViewController = webViewController;
        //     // _controller.complete(webViewController);
        //   },
        //   onProgress: (int progress) {
        //     logger.d("WebView is loading (progress : $progress%)");
        //   },
        // );
      }),
    );
  }

  // JavascriptChannel _reactToFlutter(BuildContext context) {
  //   return JavascriptChannel(
  //     name: 'reactToFlutter',
  //     onMessageReceived: (JavascriptMessage message) {
  //       logger.d("reactToFlutter 메시지 : ${message.message}");
  //     }
  //   );
  // }

} 