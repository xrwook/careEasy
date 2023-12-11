## flutter_webview

---

### 1. webview_flutter 패키지 설치

```dart
  flutter pub add webview_flutter
```
&nbsp;
### 2. Android설정

- 패키지 설치 후 바로 실행 시 에러발생

  ```bash
  One or more plugins require a higher Android SDK version.
  Fix this issue by adding the following to D:\project\flutter\testPjt\test\android\app\build.gradle:
  android {
    compileSdkVersion 32
    ...
  }
  ```

- `android\app\build.gradle` compileSdkVersion 32, targetSdkVersion 32, minSdkVersion 19 로 변경

  ```gradle
  android {
      compileSdkVersion 32
      ...
      defaultConfig {
        minSdkVersion 19
        targetSdkVersion 32
      }
      ...
  ```

- http 연결 및 설정
  - `android\app\src\main\AndroidManifest.xml`
    ```xml
      <application
        ...
        android:usesCleartextTraffic="true"> 
    ```
  - `ios\Runner\Info.plist`

     ```plist
      <dict>
        ...
        <key>io.flutter.embedded_views_preview</key>
        <string>YES</string>
        <key>NSAppTransportSecurity</key>
        <dict>
          <key>NSAllowsArbitraryLoads</key>
          <true/>
          <key>NSAllowsArbitraryLoadsInWebContent</key>
          <true/>
        </dict>
      </dict>
     ```  
&nbsp;
### 3. 사용법
``` dart
  import 'package:flutter/material.dart';
  import 'package:webview_flutter/webview_flutter.dart';

  class WebViewExampleState extends State<WebViewExample> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter WebView example'),
      ),
      body: Builder(builder: (BuildContext context) {
        return const WebView(
          initialUrl: 'http://192.168.0.221:3000/mylist',
          javascriptMode: JavascriptMode.unrestricted, //javaScript 사용 가능하게끔
          gestureNavigationEnabled: true // 뒤로가기 스와이프 가능하게끔
          userAgent: "random", //userAgent 설정
        );
      }),
    );
  }
}
```

&nbsp;

### 4. App과 webView 데이터 전달

  1. javascript channel  
  - React to Flutter

    ```Flutter```
    ```dart
      @override
      Widget build(BuildContext context) { 
        return Scaffold(
          appBar: AppBar(
            title: const Text('Flutter WebView example'),
          ),
          body: Builder(builder: (BuildContext context) {
            return WebView(
              initialUrl: 'http://192.168.0.221:3000/mylist',
              javascriptMode: JavascriptMode.unrestricted,
              gestureNavigationEnabled: true,
              javascriptChannels: <JavascriptChannel>{
                _reactToFlutter(context),
              },
            );
          }),
        );
      }

      //JavascriptChannel 생성
      JavascriptChannel _reactToFlutter(BuildContext context) {
        return JavascriptChannel(
          name: 'reactToFlutter',
          onMessageReceived: (JavascriptMessage message) {
            print("reactToFlutter 메시지 : ${message.message}");
          }
        );
      }
    ```  

    ```React```  

    ```javascript
    const MyList () => {
      return (
        <Button 
          variant="outlined"
          onClick={() => {
            //flutter 에서 JavascriptChannel명과 동일한 이름으로 설정
            window.reactToFlutter.postMessage("Flutter으로 데이터 전달") 
          }}
        >
          Send Flutter
        </Button>
      )
    }
    ```

  - Flutter to React  
    ```Flutter```

    ```dart
      import 'dart:async';
      ...
      class WebViewExampleState extends State<WebViewExample> {
        final Completer<WebViewController> _controller = Completer<WebViewController>();
        late WebViewController _webViewController;
        String passData = "ReactJS testData";

        ...

          onPressed: () {
            //javascript 호출
            _webViewController.runJavaScriptReturningResultReturningResult('window.flutter_to_react("$passData")');
          },
        ...

        body: Builder(builder: (BuildContext context) {
          return WebView(
            initialUrl: 'https://web.careeasy.com/mylist',
            javascriptMode: JavascriptMode.unrestricted,
            gestureNavigationEnabled: true,
            javascriptChannels: <JavascriptChannel>{
              _reactToFlutter(context),
            },
            onWebViewCreated: (WebViewController webViewController) {
              _webViewController = webViewController;
              _controller.complete(webViewController);
            },
            onProgress: (int progress) {
              print("WebView is loading (progress : $progress%)");
            },
          );
        }

    ```

    ```React```

    ```javascript
      window.flutter_to_react = (data) => {
        alert(data);
        console.log(data)
      }
    ```
