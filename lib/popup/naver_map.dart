// ignore_for_file: implementation_imports

import 'dart:async';
import 'dart:ui';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';
import 'package:logger/logger.dart';
import 'dart:io';
import 'package:webview_flutter/webview_flutter.dart';

class NaverMapPopup extends StatefulWidget {
  const NaverMapPopup({super.key});

  // const NaverMapPopup(this.webViewController, {super.key, required this.isVisible});
  // final WebViewController webViewController;
  // final isVisible isVisible;
  
  @override
  NaverMapPopupWidget createState() => NaverMapPopupWidget();
}

// typedef isVisible = void Function(bool isVisible);

class NaverMapPopupWidget extends State<NaverMapPopup> {
  final logger = Logger(printer: PrettyPrinter());
  final Completer<NaverMapController> _controller = Completer();
  final List<Marker> _markers = [];
  bool isVisible = false;
  bool completerCheck = true;
  late WebViewController _webViewController;
  String markerInfo = "";
  String appBarTitle = "naver map";

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getMarkerInfo();
    });
    super.initState();
    // if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(appBarTitle),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () {
              // logger.e("isVisible ===> ", isVisible);
              if(!isVisible){
                Navigator.of(context).pop(true);
              } else {
                setState(() {
                  appBarTitle = "naver map";
                  isVisible = false;
                });
              }
            },
          ),
        ),
        body: Column(
          children: <Widget>[
            Visibility(
              maintainState: true,
              child: _naverMap(),
              visible: !isVisible,
            ),
            Visibility(
              child: _detailWebview(),
              visible: isVisible,
            ),
          ],
        ),
      ),
    );
  }


  /// naverMap 위젯
  _naverMap() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height-AppBar().preferredSize.height-MediaQuery.of(context).viewPadding.top,
      child: NaverMap(
        onMapCreated: _onMapCreated,
        onMapTap: _onMapTap,
        markers: _markers,
        locationButtonEnable: true,
        initLocationTrackingMode: LocationTrackingMode.Follow,
      )
    );
  }

  /// webview 위젯
  _detailWebview() {
    return Expanded(
      child: Stack(
        children: <Widget>[
          Text("xxxxx"),
          // WebView(
          //   initialUrl: 'http://192.168.1.7:3000/markerinfo',
          //   javascriptMode: JavascriptMode.unrestricted,
          //   zoomEnabled: false,
          //   gestureNavigationEnabled: true,
          //   // javascriptChannels: <JavascriptChannel>{
          //   // },
          //   onWebViewCreated: (WebViewController webViewController) {
          //     _webViewController = webViewController;
          //   },
          //   onPageFinished: (url) {
          //     logger.d("onPageFinished", url);
          //     _webViewController.runJavaScriptReturningResult(markerInfo);
          //   },
          // ),
        ],
      )
    );
  }

  void _onMapCreated(NaverMapController controller) {
    if(completerCheck){
      _controller.complete(controller);
    }
    completerCheck = false;
  }

  /// 지도 터시시 
  void _onMapTap(LatLng latLng) {
  }

  /// Marker 클릭시 webview 데이터 전송
  void onMarkerTap(Marker? marker, Map<String, int?> iconSize) {
    final Map<String, dynamic> json = <String, dynamic>{};
    void addIfPresent(String fieldName, dynamic value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }
    LatLng? ll =  marker?.position;
    addIfPresent('latitude', ll?.latitude);
    addIfPresent('longitude', ll?.longitude);
    addIfPresent('markerId', marker?.markerId);
    addIfPresent('infoWindow', marker?.infoWindow);
    addIfPresent('captionText', marker?.captionText);

    logger.d(json);
    String str = convert.jsonEncode(json);
    final jstr = str.replaceAll('"', "&#34;");
    var naverMarkInfo = "window.naverMarkInfo('$jstr')";
    setState(() {
      appBarTitle = "xx webview xx";
      isVisible = true;
    });
    markerInfo = naverMarkInfo;
  }


  /// api이용하여 네이버지도에 Marker찍기
  void getMarkerInfo() async {
    final queryParameters  = {
      "page": "3",
      "perPage": "15",
      "serviceKey": "DmnAXyEQIVQV1zI9veVPIiOa3xU0FMPIB4I3054uQ5rrRr9ouwgUHm2Ki/+mRrQiio/yNLfM5/OxToHBqP39OA=="
    };
    final url = Uri.https('api.odcloud.kr', '/api/15041301/v1/uddi:3ecd8bc2-34ea-4860-a788-bf2578754ad9', queryParameters);
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var res = convert.jsonDecode(response.body) as Map<String, dynamic>;
      OverlayImage.fromAssetImage(
        assetName: 'assets/marker/marker_green.png',
        devicePixelRatio: window.devicePixelRatio,
      ).then((image) {
        setState(() {
          for (var element in res["data"]) { 
            LatLng latLng = LatLng(double.parse(element["위도"]), double.parse(element["경도"]));
            _markers.add(customMarker (image, latLng, element["역명"], element["역명"]));
          }
          // _markers.add(customMarker (image, const LatLng(37.5540, 126.9369), "xr", "xr-friends"));
        });
      });
    } else {
      logger.e('Request failed with status: ${response.statusCode}.');
    }
  }

  Marker customMarker (OverlayImage image, LatLng latlng, String capText, String winfowInfo) {
    return Marker(
      markerId: DateTime.now().toIso8601String(),
      position: latlng,
      captionText: capText,
      captionColor: Colors.indigo,
      captionTextSize: 20.0,
      alpha: 0.8,
      captionOffset: 30,
      icon: image,
      anchor: AnchorPoint(0.5, 1),
      width: 45,
      height: 45,
      infoWindow: winfowInfo,
      minZoom: 1,
      onMarkerTab: onMarkerTap
    );
  }


} 