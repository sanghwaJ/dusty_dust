import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dusty_dust/main.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TestScreen'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ValueListenableBuilder<Box>(
            // generic을 추가해줘야 자동완성이 잘 됨
            // Hive.box(testBox)의 값이 변경될 때마다 listening, 아래의 builder 함수 실행 (stream과 비슷) => 상태 관리에 장점이 있음
            valueListenable: Hive.box(testBox).listenable(),
            builder: (context, box, widget) {
              return Column(
                children: box.values
                    .map(
                      (e) => Text(e.toString()),
                    )
                    .toList(),
              );
            },
          ),
          Text(
            'TestScreen',
            textAlign: TextAlign.center,
          ),
          ElevatedButton(
            onPressed: () {
              final box = Hive.box(testBox);
              print('keys : ${box.keys.toList()}');
              print('values : ${box.values.toList()}');
            },
            child: Text(
              '박스 프린트!',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final box = Hive.box(testBox);
              /**
               * NoSQL의 특징
               * String, int, boolean, list, map 등 value에 타입 상관없이 모두 insert 가능
               * key 값은 자동 정렬
               */
              box.add('테스트'); // 데이터 add
              box.put(100, '테스트100'); // 데이터 생성 및 업데이트
            },
            child: Text(
              '데이터 넣기',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final box = Hive.box(testBox);
              print(box.get(100)); // key 값이 100인 것을 가져오기
              print(box.getAt(3)); // 3번째 인텍스의 값을 가져오기
            },
            child: Text(
              '특정 값 가져오기',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final box = Hive.box(testBox);
              box.delete(100); // key 값이 100인 것을 삭제
              box.deleteAt(2); // 2번째 인덱스의 값을 삭제
            },
            child: Text(
              '삭제하기',
            ),
          ),
        ],
      ),
    );
  }
}
