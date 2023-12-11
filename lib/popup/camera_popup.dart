import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class CameraPopupWidget extends StatefulWidget {
  const CameraPopupWidget({super.key, required this.imageCallback});
  final CustomCallback imageCallback;

  @override
  State<CameraPopupWidget> createState() => CameraPopupWidgetState();
}

typedef CustomCallback = void Function(List<XFile> imageFileList);

class CameraPopupWidgetState extends State<CameraPopupWidget> {

  @override
  void initState() {
    super.initState();
  }

  List<XFile>? _imageFileList;
  void _setImageFileListFromFile(XFile? value) {
    _imageFileList = value == null ? null : <XFile>[value];
  }

  dynamic _pickImageError;
  String? _retrieveDataError;
  final ImagePicker _picker = ImagePicker();
  var logger = Logger(printer: PrettyPrinter());
  double maxWidth = 1000;
  double maxHeight = 1000;
  int quality = 100;

  Future<void> _onImageButtonPressed(ImageSource source, {BuildContext? context, bool isMultiImage = false}) async {
    if (isMultiImage) {
      try {
        final List<XFile> pickedFileList = await _picker.pickMultiImage(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          imageQuality: quality,
        );
        setState(() {
          _imageFileList = pickedFileList;
        });
      } catch (e) {
        setState(() {
          _pickImageError = e;
        });
      }
    } else {
      try {
        final XFile? pickedFile = await _picker.pickImage(
          source: source,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          imageQuality: quality,
        );
        setState(() {
          _setImageFileListFromFile(pickedFile);
        });
      } catch (e) {
        setState(() {
          logger.e(e);
          _pickImageError = e;
        });
      }
    }
  }

  Widget _previewImages() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_imageFileList != null) {
      return SizedBox(
        height: 200,
        width: 200,
        child: ListView.builder(
          key: UniqueKey(),
          itemBuilder: (BuildContext context, int index) {
            return Semantics(
              label: '선택된 이미지 없음',
              child: kIsWeb ? Image.network(_imageFileList![index].path) : Image.file(File(_imageFileList![index].path)),
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

  Widget _defaultWidget() {
    /// FutureBuilder => UI부터 그리고 데이터는 나중에
    return FutureBuilder<void>(
      future: retrieveLostData(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return const Text(
              'You have not yet picked an image.',
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

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        if (response.files == null) {
          _setImageFileListFromFile(response.file);
        } else {
          _imageFileList = response.files;
        }
      });
    } else {
      _retrieveDataError = response.exception!.code;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20.0),
        ),
      ),
      insetPadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.only(
        top: 10.0,
      ),
      title: const Text("이미지 추가",style: TextStyle(fontSize: 24.0)),
      content: SizedBox(
        height: 400,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("카메라/이미지", textAlign: TextAlign.center,)
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.30,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                      child: const Text("카메라"), 
                      onPressed: () {
                        _onImageButtonPressed(ImageSource.camera, context: context);
                        // Navigator.of(context).pop();
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.30,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                      child: const Text("이미지"),
                      onPressed: () {
                        _onImageButtonPressed(ImageSource.gallery, context: context, isMultiImage: true);
                        // Navigator.of(context).pop();
                        // widget.imageList(_imageFileList);
                      }, 
                    )
                  ),
                ]
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: !kIsWeb && defaultTargetPlatform == TargetPlatform.android ? _defaultWidget() : _previewImages(),
              ),
              Container(
                width: double.infinity,
                height: 60,
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    widget.imageCallback(_imageFileList!);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom( backgroundColor: Colors.black),
                  child: const Text("웹뷰로 사진 보내기"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Text? _getRetrieveErrorWidget() {
    logger.e("result ====>", error: _retrieveDataError);
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }
}
