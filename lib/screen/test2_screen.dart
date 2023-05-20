import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../main.dart';

class Test2Screen extends StatelessWidget {
  const Test2Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test2Screen'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ValueListenableBuilder은 TestScreen에서 Test2Screen으로 넘어가도 상태가 유지됨
          // Global 상태 관리 => 화면과 화면 사이에 데이터를 보내줄 필요가 없어짐
          ValueListenableBuilder<Box>(
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
            'Test2Screen',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
