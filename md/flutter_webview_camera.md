[asdasd](https://risha-lee.tistory.com/41)

webview 카메라, 앨범에서 이미지  웹뷰로 가져오기

```AndroidManifest``` permission 추가
```xml
  <manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.test">
    <!-- Permissions options for the `storage` group -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/><!-- Permissions options for the `camera` group -->
    <uses-permission android:name="android.permission.CAMERA"/>
    <!-- Permissions options for the `microphone` or `speech` group -->
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <application
      ...
```

- Android X 대응을 위해 설정
1. ```gradle.properties```
```properties
  android.useAndroidX=true
  android.enableJetifier=true
```

2.