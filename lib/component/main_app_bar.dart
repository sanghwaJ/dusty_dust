import 'package:flutter/material.dart';

import '../const/colors.dart';

class MainAppBar extends StatelessWidget {
  const MainAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ts = TextStyle(
      color: Colors.white,
      fontSize: 30.0,
    );

    return SliverAppBar(
      expandedHeight: 500,
      backgroundColor: primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: SafeArea(
          child: Container(
            // margin => 컨테이너의 바깥쪽 영역 (바깥쪽 여백의 양)
            // padding => 컨테이너의 안쪽 영역 (안쪽 여백의 양)
            // kToolbarHeight => AppBar 영역의 height
            margin: EdgeInsets.only(top: kToolbarHeight),
            child: Column(
              children: [
                Text(
                  '서울',
                  style: ts.copyWith(
                    fontSize: 40.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  DateTime.now().toString(),
                  style: ts.copyWith(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20.0),
                Image.asset(
                  'asset/img/mediocre.png',
                  width: MediaQuery.of(context).size.width / 2,
                ),
                const SizedBox(height: 20.0),
                Text(
                  '보통',
                  style: ts.copyWith(
                    fontSize: 40.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  '나쁘지 않네요!',
                  style: ts.copyWith(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
