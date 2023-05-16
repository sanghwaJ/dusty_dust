import 'package:dusty_dust/component/main_card.dart';
import 'package:flutter/material.dart';

import '../const/colors.dart';
import 'card_title.dart';
import 'main_stat.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Card를 사용하면, 화면에 맞게 약간의 margin이 들어감
    return SizedBox(
      height: 160,
      child: MainCard(
        // LayoutBuilder => height와 width의 min, max 설정을 줄 수 있는 constraint를 사용할 수 있음
        child: LayoutBuilder(builder: (context, constraint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardTitle(
                title: '종류별 통계',
              ),
              // Scroll이 가능한 위젯을 Column 안에서 사용할 때는 Expanded를 사용해야 함
              Expanded(
                child: ListView(
                  // ListView + Axis.horizontal => 스크롤이 가능한 Row
                  scrollDirection: Axis.horizontal,
                  // PageScrollPhysics => 살짝만 스크롤해도 다음 위젯으로 이동됨
                  physics: PageScrollPhysics(),
                  children: List.generate(
                    20,
                    (index) => MainStat(
                      category: '미세먼지$index',
                      imgPath: 'asset/img/best.png',
                      level: '최고',
                      stat: '0㎍/㎥ ',
                      width: constraint.maxWidth / 3,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
