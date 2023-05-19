import 'package:dio/dio.dart';
import 'package:dusty_dust/component/card_title.dart';
import 'package:dusty_dust/component/hourly_card.dart';
import 'package:dusty_dust/component/main_app_bar.dart';
import 'package:dusty_dust/component/main_card.dart';
import 'package:dusty_dust/component/main_drawer.dart';
import 'package:dusty_dust/component/main_stat.dart';
import 'package:dusty_dust/const/colors.dart';
import 'package:dusty_dust/const/status_level.dart';
import 'package:dusty_dust/model/stat_and_status_model.dart';
import 'package:dusty_dust/model/stat_model.dart';
import 'package:dusty_dust/repository/stat_repository.dart';
import 'package:dusty_dust/utils/data_utils.dart';
import 'package:flutter/material.dart';

import '../component/category_card.dart';
import '../const/data.dart';
import '../const/regions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // state가 생성될 때, 딱 한 번 실행
  // @override
  // void initState() {
  //   super.initState();
  //   fetchData();
  // }

  String region = regions[0];
  bool isExpanded = true;
  ScrollController scrollController = ScrollController();

  // initState => 모든 listener들을 등록
  @override
  initState() {
    super.initState();
    scrollController
        .addListener(scrollListener); // 스크롤을 움직일 때마다 scrollListener 실행
  }

  @override
  dispose() {
    // 메모리 관리를 위해 controller는 dispose시 같이 dispose를 해줘야 함
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  // API 요청
  Future<Map<ItemCode, List<StatModel>>> fetchData() async {
    // 모든 카테고리에 대한 리턴을 해주기위해 Map 생성 (stats[ItemCode.PM10]으로 카테고리 목록을 가져올 수 있음)
    Map<ItemCode, List<StatModel>> stats = {};

    // await StatRepository.fetchData => await를 쓰면 이미 응답은 받은 상태, 즉 List<StatModel> 타입
    // StatRepository.fetchData => await를 쓰지 않으면 아직 응답을 받지 않은 상태, 즉 Future<List<StatModel>> 타입
    // 따라서, StatRepository.fetchData는 아래와 같이 Future로 이루어진 리스트에 add 할 수 있음
    List<Future> futures = [];
    for (ItemCode itemCode in ItemCode.values) {
      futures.add(
        // await는 작업이 끝나야만 다음 loop가 실행됨
        // 아래는 await를 사용하지 않기 때문에, 서버에서 응답이 오지 않아도 일단 요청을 보내는 loop가 실행됨
        StatRepository.fetchData(
          itemCode: itemCode,
        ),
      );
    }

    // futures(List<Future>)에 있는 Future들의 요청이 모두 끝날 때까지 await(기다림)
    // 요청이 온 Future들은 순서대로 아래의 results에 들어옴 (요청이 온 순간에는 Future 타입이 아닌 List<StatModel> 타입)
    final results = await Future.wait(futures);

    // 순서대로 stats에 add
    for (int i = 0; i < results.length; i++) {
      final key = ItemCode.values[i];
      final value = results[i];

      stats.addAll({
        key: value,
      });
    }

    return stats;
  }

  scrollListener() {
    // offset => scroll한 정도를 알 수 있음
    bool isExpanded = scrollController.offset <
        500 - kToolbarHeight; // main_app_bar - AppBar의 높이

    if (isExpanded != this.isExpanded) {
      setState(() {
        this.isExpanded = isExpanded;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<ItemCode, List<StatModel>>>(
      future: fetchData(),
      builder: (context, snapshot) {
        // 에러 발생
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('에러가 있습니다.'),
            ),
          );
        }

        // 데이터가 없을 때, 로딩바
        if (!snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        Map<ItemCode, List<StatModel>> stats = snapshot.data!;
        StatModel pm10RecentStat = stats[ItemCode.PM10]![0];

        // 미세먼지 최근 데이터의 현재 상태
        final status = DataUtils.getStatusFromItemCodeAndValue(
          value: pm10RecentStat.seoul,
          itemCode: ItemCode.PM10,
        );

        final ssModel = stats.keys.map((key) {
          // Android Studio는 Map의 key를 통해 value를 가져오는 경우 null 인 가능성을 항상 체크하기 때문에 !를 붙여줘야 함
          final value = stats[key]!;
          final stat = value[0];

          return StatAndStatusModel(
            itemCode: key,
            status: DataUtils.getStatusFromItemCodeAndValue(
              value: stat.getLevelFromRegion(region), // 지역 한글
              itemCode: key,
            ),
            stat: stat,
          );
        }).toList();

        return Scaffold(
          drawer: MainDrawer(
            darkColor: status.darkColor,
            lightColor: status.lightColor,
            selectedRegion: region,
            onRegionTap: (String region) {
              setState(() {
                this.region = region;
              });
              // region을 선택하면, 화면 닫힘 (뒤로가기)
              Navigator.of(context).pop();
            },
          ),
          body: Container(
            // Scaffold에 배경을 주지 않고, status를 받아 아래에 배경을 주도록 함
            color: status.primaryColor,
            child: CustomScrollView(
              controller: scrollController, // CustomScrollView controller 목적
              slivers: [
                MainAppBar(
                  status: status,
                  stat: pm10RecentStat,
                  region: region,
                  dateTime: pm10RecentStat.dataTime,
                  isExpanded: isExpanded,
                ),
                // SliverToBoxAdapter => slivers안에 일반 위젯을 넣을 수 있음
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CategoryCard(
                        region: region,
                        models: ssModel,
                        darkColor: status.darkColor,
                        lightColor: status.lightColor,
                      ),
                      const SizedBox(height: 16.0),
                      // Cascade Operator => 리스트 연결
                      ...stats.keys.map(
                        (itemCode) {
                          // Android Studio는 Map의 key를 통해 value를 가져오는 경우 null 인 가능성을 항상 체크하기 때문에 !를 붙여줘야 함
                          final stat = stats[itemCode]!;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: HourlyCard(
                              darkColor: status.darkColor,
                              lightColor: status.lightColor,
                              category: DataUtils.getItemCodeKrString(
                                itemCode: itemCode,
                              ),
                              stats: stat,
                              region: region,
                            ),
                          );
                        },
                      ).toList(),
                      const SizedBox(height: 16.0),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
