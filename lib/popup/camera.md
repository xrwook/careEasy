# webview_flutter를 이용하여 카메라, 이미지파일 접근

### 1. react에서 카메라 팝업을 호출하기

  ```js
  const openCameraPopup = () => {
    window.cameraPopup.postMessage("openCameraPopup");
  }
  ```

### 2. fluttwe에서 javascriptChannel 등록

  ```dart
  WebView(
    initialUrl: 'https://careeasy-web-service-yc6ivlmbpa-an.a.run.app/mylist',
    javascriptMode: JavascriptMode.unrestricted,
    zoomEnabled: false,
    gestureNavigationEnabled: true,
    javascriptChannels: <JavascriptChannel>{
      _cameraPopup(context),
    },
    onWebViewCreated: (WebViewController webViewController) {
      _webViewController = webViewController;
    },
    onProgress: (int progress) async {
    },
    onPageFinished: (url) {
    },
  ),
  ```

### 3. _cameraPopup, showCameraPopup Function 생성

  ```dart
  //_cameraPopup()
  //JavascriptChannel 메세지 리시버 생성
  JavascriptChannel _cameraPopup(BuildContext context) {
    return JavascriptChannel(
      name: 'cameraPopup',
      onMessageReceived: (JavascriptMessage message) {
        showCameraPopup();
      }
    );
  }

  ...

  //showCameraPopup()
  //showDialog를 이용하여 팝업 생성
  //자식 위젯에서 부모의 state값을 변경하기 위하여 imageStateChange() 전달
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
  ```

### 4. CameraPopupWidget class 생성

* [camera_popup.dart](./camera_popup.dart) 참고

```dart
import 'package:image_picker/image_picker.dart';

class CameraPopupWidget extends StatefulWidget {
  //imageCallback 파라미터 추가
  const CameraPopupWidget({super.key, required this.imageCallback});
  final CustomCallback imageCallback;

  @override
  State<CameraPopupWidget> createState() => CameraPopupWidgetState();
}

//함수를 호출시 CustomCallback 타입의 변수 이름을 Function를 호출하는 함수 이름으로 사용하기위해 추가
typedef CustomCallback = void Function(List<XFile> imageFileList);

class CameraPopupWidgetState extends State<CameraPopupWidget> {

  @override
  Widget build(BuildContext context) {
    ...
    ElevatedButton(
      child: const Text("카메라"), 
      onPressed: () {
        //카메라로 사진찍기
        _onImageButtonPressed(ImageSource.camera, context: context);
      },
    ),
    ...
    ElevatedButton(
      child: const Text("이미지"), 
      onPressed: () {
        //갤러리에서 이미지 가져오기
        _onImageButtonPressed(ImageSource.gallery, context: context);
      },
    ),
    ...
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: !kIsWeb && defaultTargetPlatform == TargetPlatform.android ? _defaultWidget() : _previewImages(),
    ),
    ...
    ElevatedButton(
      onPressed: () {
        //_imageFileList 부모로 데이터 전달 후 팝업 닫기 
        widget.imageCallback(_imageFileList!);
        Navigator.of(context).pop();
      },
      child: const Text("웹뷰로 사진 보내기"),
    ),
  }

  Future<void> _onImageButtonPressed(ImageSource source, {BuildContext? context, bool isMultiImage = false}) async {
    try {
      final List<XFile> pickedFileList = await _picker.pickMultiImage(
        maxWidth: maxWidth, //가로 크기 지정
        maxHeight: maxHeight, //세로 크기 지정
        imageQuality: quality, //이미지 화질 지정
      );
      setState(() {
        _imageFileList = pickedFileList;
      });
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
    } catch (e) {
      setState(() {
        logger.e(e);
        _pickImageError = e;
      });
    }
  }

  //FutureBuilder를 사용하여 UI를 비동기 처리(데이터에 따라 표시할 Widget을 return)
  Widget _defaultWidget() {
    return FutureBuilder<void>(
      future: retrieveLostData(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return const Text(
              '선택된 이미지 없음.',
              textAlign: TextAlign.center,
            );
          case ConnectionState.done:
            return _previewImages();
          default:
            if (snapshot.hasError) {
              return Text(
                'Pick image error: ${snapshot.error}}',
                textAlign: TextAlign.center,
              );
            } else {
              return const Text(
                '선택된 이미지 없음.',
                textAlign: TextAlign.center,
              );
            }
        }
      },
    );
  }

  //이미지 화면에 return
  Widget _previewImages() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    ...
    if (_imageFileList != null) {
      return SizedBox(
        height: 200,
        width: 200,
        child: ListView.builder(
          key: UniqueKey(),
          itemBuilder: (BuildContext context, int index) {
            return Semantics(
              label: 'image_picker_example_picked_image',
              child: Image.file(File(_imageFileList![index].path)),
            );
          },
          itemCount: _imageFileList!.length,
        ),
      );
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return const Text(
        '선택된 이미지 없음.',
        textAlign: TextAlign.center,
      );
    }
  }

}

```

### 5. webview로 이미지 base64변환 후 전달

```dart
  void sendImage(List<XFile> imageList) async {
    List<String> imageStrList = [];
    for (var element in imageList) {
      final bytes = File(element.path).readAsBytesSync();
      imageStrList.add(base64Encode(bytes));
    }
    String images = imageStrList.join("__careeasy__");
    //SnedBase64Encode 이름으로 react에 전달
    var sendData = 'window.SnedBase64Encode("$images")';
    await _webViewController.runJavaScriptReturningResult(sendData);
  }

```

### 6. react에서 이미지 표현

```js
  window.SnedBase64Encode = (data) => {
    const imageList = data.split("__careeasy__");
    setBase64Data(imageList);
  }
  ...
  return (
    <div>
      {base64Data.length !== 0 && base64Data.map(x => {
        return <img src={`data:image/png;base64,${x}`} alt="preview-img" style={{width: "500px", height: "500px"}} />
      })}
    </div>
  )
```