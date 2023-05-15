import 'package:dusty_dust/const/colors.dart';
import 'package:flutter/material.dart';

const regions = [
  '서울',
  '경기',
  '인천',
  '충남',
  '충북',
  '전남',
  '전북',
  '경남',
  '경북',
  '강원',
  '대전',
  '대구',
  '울산',
  '부산',
  '제주',
];

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: darkColor,
      child: ListView(
        children: [
          DrawerHeader(
            child: Text(
              '지역 선택',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
              ),
            ),
          ),
          // Cascade Operator => 리스트 연결
          ...regions.map(
            (e) => ListTile(
              tileColor: Colors.white,
              selectedTileColor: lightColor, // 선택이 된 상태에서 배경색
              selectedColor: Colors.black, // 선택이 된 상태에서 글자색
              selected: e == '서울', // 선택된 상태 조절
              onTap: () {}, // ListTile + onTap => 클릭 애니메이션
              title: Text(
                e,
              ),
            ),
          ).toList(),
        ],
      ),
    );
  }
}
