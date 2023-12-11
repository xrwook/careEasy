
## 1. Flutter의 UI 구조
- Flutter는 모두 위젯으로 이루어져 있다.
- 텍스트나 버튼 혹은 레이아웃 등 UI 가 관련된 무엇을 만들던 UI가 위젯으로 생성 (위젯 트리)

![image](https://flutter-ko.dev/assets/ui/layout/sample-flutter-layout-46c76f6ab08f94fa4204469dbcf6548a968052af102ae5a1ae3c78bc24e0d915.png)

- Row Column Container 이 3가지 위젯이 위젯 트리를 구성
  - 보이는 위젯들을 제어하고, 제한하며, 정렬시킴
  - 마지막 지점은 항상 눈에 보이는 UI요소로 되어있음 (Text, Icon 등..)
  - Row는 가로로 하위 위젯을 생성
  - Columnd은 세로로 하위 위젯을 생성
  - Container는  자식 위젯들을 커스터마이징할 수 있는 위젯 클래스(여백, 간격, 테두리, 배경색 등)  


  
----
## 2. Flutter 위젯 생성 및 위젯 데이터 변경 적용
  - StatelessWidget, StatefulWidget, State 
  
  ### 2.1 StatelessWidget
    ```dart
    import 'package:flutter/material.dart';

    class MyApp extends StatelessWidget {
      @override
      Widget build(BuildContext context){
        return MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: const MyHomePage(title: 'Flutter Demo Home Page'),
        )
      }
    }
    ```
  - StatelessWidget을 클래스에 상속 받아 사용하기위해 build()함수를 override해서 사용
  - bulid() 함수를 통해서 위젯을 생성
  - Flutter는 State를 통해서 위젯을 변경, State이 없다면 위젯을 변경할 수가 없음
  - StatelessWidget은 State이 없는 위젯을 생성하기 때문에 위젯의 데이터를 변경할 수 없음
  - StatelessWidget
    - 변경 가능한 상태가 필요하지 않는 위젯
    - State 이 없는 Widget을 정의할 때 사용한다.
    - 생명주기가 존재하지 않으며 bulid 함수 한번만 실행된다.  
    
----

  ### 2.2 StatefulWidget , State  
  - StatefulWidget은 StatelessWidget과 반대로 State을 가진 위젯을 생성하기 때문에 State에 따라 위젯을 변경함
  - StatefulWidget사용할때 State는 기본적으로 동시에 같이 사용해야함

  
    ```dart
    class MyHomePage extends StatefulWidget {
      const MyHomePage({super.key, required this.title});
      final String title;

      @override
      State<MyHomePage> createState() => _MyHomePageState();
    }

    class _MyHomePageState extends State<MyHomePage> {
      int _counter = 1;

      void _incrementCounter() {
        setState(() {
          _counter++;
        });
      }

      @override
      Widget build(BuildContext context) {
        return Container();
      }
    }
    ```
  - State은 한마디로 Data라고 정의할 수 있음
  - StatefulWidget 
    - 변할 수 있는 스텟이다. state에 대한 configration을 설정한다. 
    - 클래스내의 필드는 항상 final 로 표시된다.
    - State 에 따른 UI 변화가 필요할 때 사용한다. 
    - State 과 같이 사용된다. 
  - State
    - 위젯이 빌드될때 동기적으로 읽을 수 있음
    - 위젯의 생명주기 동안 변경될 수 있는 정보 
    - StatefulWidget 의 생명 주기를 가짐
  - 성능을 위해 StatefulWidget, State분리
    - 속성 또는 부모 위젯이 바뀌게 되면 StatefulWidget 바뀌게 되는데, 이 과정에서 위젯이  재생성하는데 StatefulWidget이 라이프사이클을  가지고 있으면 라이프사이클을 다시 복구하는데 꽤나 많은 성능이 필요함
      - State가 라이프사이클을 관리하면 생명주기가 위젯과 함께 폐기되었다가 다시 재생성 되지 않음
      - State 자체는 폐기되지 않아서 데이터 변경에 대한 응답으로 필요할 때  언제든지 위젯을 만들 수 있음 

  

----

