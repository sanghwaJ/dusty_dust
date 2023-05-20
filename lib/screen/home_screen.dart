import 'package:dio/dio.dart';
import 'package:dusty_dust/component/card_title.dart';
import 'package:dusty_dust/container/hourly_card.dart';
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
import 'package:hive_flutter/hive_flutter.dart';

import '../container/category_card.dart';
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
    // 화면이 초기화가 될 때 fetchData 실행
    fetchData();
  }

  @override
  dispose() {
    // 메모리 관리를 위해 controller는 dispose시 같이 dispose를 해줘야 함
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  // API 요청
  Future<void> fetchData() async {
    try {
      final now = DateTime.now();
      final fetchTime = DateTime(
        now.year,
        now.month,
        now.day,
        now.hour,
      );

      // 만일 현재 시간과 box에 있는 데이터의 시간이 동일하다면, 다시 데이터 요청을 하지 않음
      final box = Hive.box<StatModel>(ItemCode.PM10.name);
      // box가 빈 경우 last를 비교하면 에러가 발생하기 때문에 아래와 같이 분기 처리
      if (box.values.isNotEmpty &&
          (box.values.last as StatModel).dataTime.isAtSameMomentAs(fetchTime)) {
        // isAtSameMomentAs => 동일한 시간인지 비교하는 함수
        return;
      }

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

      // Hive에 데이터 넣기
      for (int i = 0; i < results.length; i++) {
        // key => ItemCode
        final key = ItemCode.values[i];
        // value => List<StatModel>
        final value = results[i];

        // Hive Box 값 가져오기
        final box = Hive.box<StatModel>(key.name);

        for (StatModel stat in value) {
          // key 값은 unique 해야 하는데, 각각의 dataTime은 unique 할 수 밖에 없으므로 key로 지정
          box.put(stat.dataTime.toString(), stat);
        }

        // 24개의 데이터 이후, 중복 데이터 삭제 (최근 데이터만 남기기)
        final allKeys = box.keys.toList();
        if (allKeys.length > 24) {
          // subList => List Slicing(start ~ end)
          final deleteKeys = allKeys.sublist(0, allKeys.length - 24);
          box.deleteAll(deleteKeys);
        }
      }

      /**
       * reduce
       * reduce((누적 결과, 현재 인덱스의 요소) => (누적 결과와 현재 요소를 이용한 연산));
       * reduce 실행 대상과 리턴의 타입이 같아야 함 (아니면 에러 발생)
       */
      /**
       * fold
       * fold(시작할 인덱스, (누적 결과, 현재 인덱스의 요소) => (누적 결과와 현재 요소를 이용한 연산));
       * generic으로 타입을 지정해주면, 원하는 타입으로 리턴할 수 있음 (즉, 실행 대상과 리턴의 타입이 다를 수 있음)
       */
      // hive에서 데이터 가져오기 (FutureBuilder를 대체하여 ValueListenableBuilder로 변경하므로 리턴 값 주석 처리)
      // return ItemCode.values.fold<Map<ItemCode, List<StatModel>>>({},
      //     (previousValue, itemCode) {
      //   final box = Hive.box<StatModel>(itemCode.name);
      //
      //   previousValue.addAll({
      //     itemCode: box.values.toList(),
      //   });
      //
      //   return previousValue;
      // });
    } on DioError catch (e) {
      // Dio에 관련된 에러만 catch (데이터 요청이 안됐을 때)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '인터넷 연결이 원활하지 않습니다.',
          ),
        ),
      );
    }
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
    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box<StatModel>(ItemCode.PM10.name).listenable(),
      builder: (context, box, widget) {
        // recentStat이 last를 비교하기 때문에, box가 빈 값인 경우 에러 방지
        if (box.values.isEmpty) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // 아래의 코드가 StatModel을 나타냄을 정의
        final recentStat = box.values.toList().last
            as StatModel; // PM10(미세먼지 값)의 가장 최근 데이터를 가져옴

        // 미세먼지 최근 데이터의 현재 상태
        final status = DataUtils.getStatusFromItemCodeAndValue(
          value: recentStat.getLevelFromRegion(region),
          itemCode: ItemCode.PM10,
        );

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
            // RefreshIndicator => 스크롤이 가능한 모든 위젯에 적용이 가능, 스크롤을 맨 위로 올릴 때마다 fetchData 실행
            child: RefreshIndicator(
              onRefresh: () async {
                await fetchData();
              },
              child: CustomScrollView(
                controller: scrollController, // CustomScrollView controller 목적
                slivers: [
                  MainAppBar(
                    status: status,
                    stat: recentStat,
                    region: region,
                    dateTime: recentStat.dataTime,
                    isExpanded: isExpanded,
                  ),
                  // SliverToBoxAdapter => slivers안에 일반 위젯을 넣을 수 있음
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CategoryCard(
                          region: region,
                          darkColor: status.darkColor,
                          lightColor: status.lightColor,
                        ),
                        const SizedBox(height: 16.0),
                        // Cascade Operator => 리스트 연결
                        ...ItemCode.values.map(
                          (itemCode) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: HourlyCard(
                                darkColor: status.darkColor,
                                lightColor: status.lightColor,
                                region: region,
                                itemCode: itemCode,
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
          ),
        );
      },
    );
  }
}
