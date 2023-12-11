// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:logger/logger.dart';
// import 'dart:async';
// import 'package:flutter/foundation.dart';

// //https://inappwebview.dev/docs/webview/in-app-webview
// // https://stackoverflow.com/questions/71954294/flutter-inappwebview-loads-the-page-but-doesnt-show-the-content
// class InAppWebViewPage extends StatefulWidget {
//   const InAppWebViewPage({super.key});

//   @override
//   InAppWebViewPageState createState() => InAppWebViewPageState();
// }

// class InAppWebViewPageState extends State<InAppWebViewPage> {
//   final GlobalKey webViewKey = GlobalKey();

//   InAppWebViewController? webViewController;
//   InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
//     crossPlatform: InAppWebViewOptions(
//       useShouldOverrideUrlLoading: true,
//       mediaPlaybackRequiresUserGesture: false,
//     ),
//     android: AndroidInAppWebViewOptions(
//       useHybridComposition: true,
//       domStorageEnabled: true,
//       databaseEnabled: true,
//       clearSessionCache: true,
//       thirdPartyCookiesEnabled: true,
//       mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW
//     ),
//     ios: IOSInAppWebViewOptions(
//       allowsInlineMediaPlayback: true,
//     )
//   );

  

//   late PullToRefreshController pullToRefreshController;
//   double progress = 0;
//   final urlController = TextEditingController();
//   var logger = Logger(printer: PrettyPrinter());

//   @override
//   void initState() {
//     super.initState();

//     pullToRefreshController = PullToRefreshController(
//       options: PullToRefreshOptions(
//         color: Colors.blue,
//       ),
//       onRefresh: () async {
//         if (Platform.isAndroid) {
//           webViewController?.reload();
//         } else if (Platform.isIOS) {
//           webViewController?.loadUrl(urlRequest: URLRequest(url: await webViewController?.getUrl()));
//         }
//       },
//     );

//     WidgetsFlutterBinding.ensureInitialized();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(title: const Text("InAppWebViewa")),
//         body: SafeArea(
//           child: Column(children: <Widget>[
//             Expanded(
//               child: Stack(
//                 children: [
//                   InAppWebView(
//                     key: webViewKey,
//                     // initialUrlRequest: URLRequest(url: Uri.parse("https://www.w3schools.com/tags/tryit.asp?filename=tryhtml5_input_type_file")),
//                     initialUrlRequest: URLRequest(url: Uri.parse("http://192.168.1.7:3000/mylist")),
//                     // initialUrlRequest: URLRequest(url: Uri.parse("https://web.careeasy.com/mylist")),
//                     initialOptions: options,
//                     pullToRefreshController: pullToRefreshController,
//                     onWebViewCreated: (controller) {
//                       webViewController = controller;
//                     },
//                     onLoadStart: (controller, url) {
//                       setState(() {
                        
//                       });
//                     },
//                     androidOnPermissionRequest: (controller, origin, resources) async {
//                       return PermissionRequestResponse(
//                         resources: resources,
//                         action: PermissionRequestResponseAction.GRANT
//                       );
//                     },
//                     onLoadStop: (controller, url) async {
//                       pullToRefreshController.endRefreshing();
//                       setState(() {
//                       });


//                       var webMessageChannel = await controller.createWebMessageChannel();
//                       var port1 = webMessageChannel!.port1;
//                       var port2 = webMessageChannel.port2;

//                       await port1.setWebMessageCallback((message) async {
//                         logger.e("Message coming from the JavaScript side: $message");
//                         await port1.postMessage(WebMessage(data: message! + " and back"));
//                       });

//                         // transfer port2 to the webpage to initialize the communication
//                         await controller.postWebMessage(
//                           message:
//                             WebMessage(data: "capturePort", ports: [port2]),
//                             targetOrigin: Uri.parse("*")
//                         );




//                     },
//                     onLoadError: (controller, url, code, message) {
//                       pullToRefreshController.endRefreshing();
//                     },
//                     onProgressChanged: (controller, progress) {
//                       if (progress == 100) {
//                         pullToRefreshController.endRefreshing();
//                       }
//                       setState(() {
//                         this.progress = progress / 100;
//                       });
//                     },
//                     onUpdateVisitedHistory: (controller, url, androidIsReload) {
//                       setState(() {
//                       });
//                     },
//                     onConsoleMessage: (controller, consoleMessage) {
//                       logger.d("REACT Console ::  ${consoleMessage.message} " );
//                     },
//                   ),
//                   progress < 1.0 ? LinearProgressIndicator(value: progress) : Container(),
//                 ],
//               ),
//             ),
//           ]
//         )
//       )
//     );
//   }
// }
