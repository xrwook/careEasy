import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';
import 'package:logger/logger.dart';

class MarkerMapPage extends StatefulWidget {
  const MarkerMapPage({super.key});

  @override
  MarkerMapPageState createState() => MarkerMapPageState();
}

class MarkerMapPageState extends State<MarkerMapPage> {
  static const MODE_ADD = 0xF1;
  static const MODE_REMOVE = 0xF2;
  static const MODE_NONE = 0xF3;
  int _currentMode = MODE_NONE;
  var logger = Logger(printer: PrettyPrinter());
  final Completer<NaverMapController> _controller = Completer();
  final List<Marker> _markers = [];
//4  19 23 25 
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OverlayImage.fromAssetImage(
        assetName: 'assets/marker/marker_green.png',
        devicePixelRatio: window.devicePixelRatio,
      ).then((image) {
        setState(() {
          _currentMode = MODE_ADD;
          _markers.clear();
          _markers.add(Marker( 
            markerId: 'id',
            position: const LatLng(37.5540, 126.9369),
            captionText: "커스텀 아이콘xx",
            captionColor: Colors.indigo,
            captionTextSize: 20.0,
            alpha: 0.8,
            captionOffset: 30,
            icon: image,
            anchor: AnchorPoint(0.5, 1),
            width: 45,
            height: 45,
            infoWindow: '인포 윈도우',
            minZoom: 1,
            onMarkerTab: onMarkerTap
          ));
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        body: Column(
          children: <Widget>[
            _controlPanel(),
            _naverMap(),
          ],
        ),
      ),
    );
  }

  _controlPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // 추가
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _currentMode = MODE_ADD;
                MODE_REMOVE;
                logger.e("_currentMode == ", error: _currentMode);
              }),
              child: Container(
                decoration: BoxDecoration(
                  color: _currentMode == MODE_ADD ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.black)
                ),
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(right: 8),
                child: Text(
                  '추가',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _currentMode == MODE_ADD ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),

          // 삭제
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentMode = MODE_REMOVE),
              child: Container(
                decoration: BoxDecoration(
                  color: _currentMode == MODE_REMOVE ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.black)
                ),
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(right: 8),
                child: Text(
                  '삭제',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _currentMode == MODE_REMOVE ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),

          // none
          GestureDetector(
            onTap: () => setState(() => _currentMode = MODE_NONE),
            child: Container(
              decoration: BoxDecoration(
                color: _currentMode == MODE_NONE ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.black)
              ),
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.clear,
                color: _currentMode == MODE_NONE ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _naverMap() {
    return Expanded(
      child: Stack(
        children: <Widget>[
          NaverMap(
            onMapCreated: _onMapCreated,
            onMapTap: _onMapTap,
            markers: _markers,
            initLocationTrackingMode: LocationTrackingMode.Follow,
          ),
        ],
      ),
    );
  }

  void _onMapCreated(NaverMapController controller) {
    _controller.complete(controller);
  }

  void _onMapTap(LatLng latLng) {
    OverlayImage.fromAssetImage(
      assetName: 'assets/marker/marker_black.png',
      devicePixelRatio: window.devicePixelRatio,
    ).then((image) {
      _markers.add(Marker(
        markerId: DateTime.now().toIso8601String(),
        position: latLng,
        infoWindow: '테스트',
        icon: image,
        onMarkerTab: onMarkerTap,
      ));
    });
    setState(() {});
  }

  void onMarkerTap(Marker? marker, Map<String, int?> iconSize) {
    int pos = _markers.indexWhere((m) => m.markerId == marker!.markerId);
    setState(() {
      _markers[pos].captionText = '선택됨';
    });
    if (_currentMode == MODE_REMOVE) {
      setState(() {
        _markers.removeWhere((m) => m.markerId == marker!.markerId);
      });
    }
  }
} 

