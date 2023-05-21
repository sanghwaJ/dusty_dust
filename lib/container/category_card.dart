import 'package:dusty_dust/component/main_card.dart';
import 'package:dusty_dust/model/stat_model.dart';
import 'package:dusty_dust/utils/data_utils.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../const/colors.dart';
import '../model/stat_and_status_model.dart';
import '../component/card_title.dart';
import '../component/main_stat.dart';

class CategoryCard extends StatelessWidget {
  final String region;
  final Color darkColor;
  final Color lightColor;

  const CategoryCard({
    required this.region,
    required this.darkColor,
    required this.lightColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Card를 사용하면, 화면에 맞게 약간의 margin이 들어감
    return SizedBox(
      height: 160,
      child: MainCard(
        backgroundColor: lightColor,
        // LayoutBuilder => height와 width에 min, max 설정을 줄 수 있는 constraint를 사용할 수 있음
        child: LayoutBuilder(builder: (context, constraint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardTitle(
                title: '종류별 통계',
                backgroundColor: darkColor,
              ),
              // Scroll이 가능한 위젯을 Column 안에서 사용할 때는 Expanded를 사용해야 함
              Expanded(
                child: ListView(
                  // ListView + Axis.horizontal => 스크롤이 가능한 Row
                  scrollDirection: Axis.horizontal,
                  // PageScrollPhysics => 살짝만 스크롤해도 다음 위젯으로 이동됨
                  physics: PageScrollPhysics(),
                  children: ItemCode.values
                      .map(
                        (ItemCode itemCode) => ValueListenableBuilder<Box>(
                          valueListenable:
                              Hive.box<StatModel>(itemCode.name).listenable(),
                          builder: (context, box, widget) {
                            final stat = box.values.last as StatModel;
                            final status =
                                DataUtils.getStatusFromItemCodeAndValue(
                              value: stat.getLevelFromRegion(region),
                              itemCode: itemCode,
                            );

                            return MainStat(
                              category: DataUtils.getItemCodeKrString(
                                itemCode: itemCode,
                              ),
                              imgPath: status.imagePath,
                              level: status.label,
                              stat: '${stat.getLevelFromRegion(
                                region,
                              )}${DataUtils.getUnitFromItemCode(
                                itemCode: itemCode,
                              )}',
                              width: constraint.maxWidth / 3,
                            );
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
