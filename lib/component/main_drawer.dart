import 'package:flutter/material.dart';

import '../const/regions.dart';

typedef OnRegionTap = void Function(String region);

class MainDrawer extends StatelessWidget {
  final OnRegionTap onRegionTap;
  final String selectedRegion;
  final Color darkColor;
  final Color lightColor;

  const MainDrawer({
    required this.onRegionTap,
    required this.selectedRegion,
    required this.darkColor,
    required this.lightColor,
    Key? key,
  }) : super(key: key);

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
          ...regions
              .map(
                (e) => ListTile(
                  tileColor: Colors.white,
                  // 선택이 된 상태에서 배경색
                  selectedTileColor: lightColor,
                  // 선택이 된 상태에서 글자색
                  selectedColor: Colors.black,
                  // 선택된 상태 조절
                  selected: e == selectedRegion,
                  // ListTile + onTap => 클릭 애니메이션
                  onTap: () {
                    // onTap을 했을 떄, 어떤 region을 받는지 알 수 있음
                    onRegionTap(e);
                  },
                  title: Text(
                    e,
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}
