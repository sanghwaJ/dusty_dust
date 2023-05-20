import 'package:dusty_dust/model/stat_model.dart';
import 'package:dusty_dust/screen/home_screen.dart';
import 'package:dusty_dust/screen/test_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

const testBox = 'test';

void main() async {
  /**
   * Hive (NoSQL)
   */
  await Hive.initFlutter();

  // Adapter 등록
  Hive.registerAdapter<StatModel>(StatModelAdapter());
  Hive.registerAdapter<ItemCode>(ItemCodeAdapter());

  // Hive Box Open
  await Hive.openBox(testBox);
  // 각각 itemCode의 Box Open
  for (ItemCode itemCode in ItemCode.values) {
    await Hive.openBox<StatModel>(itemCode.name); // 미세먼지, 오존 등등...
  }

  runApp(
    MaterialApp(
      theme: ThemeData(
        fontFamily: 'sunflower',
      ),
      home: HomeScreen(), // TestScreen()
    ),
  );
}
