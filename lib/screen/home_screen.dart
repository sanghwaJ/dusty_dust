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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      drawer: MainDrawer(
        selectedRegion: region,
        onRegionTap: (String region) {
          setState(() {
            this.region = region;
          });
          // region을 선택하면, 화면 닫힘 (뒤로가기)
          Navigator.of(context).pop();
        },
      ),
      body: FutureBuilder<Map<ItemCode, List<StatModel>>>(
          future: fetchData(),
          builder: (context, snapshot) {
            // 에러 발생
            if (snapshot.hasError) {
              return Center(
                child: Text('에러가 있습니다.'),
              );
            }

            // 데이터가 없을 때, 로딩바
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            Map<ItemCode, List<StatModel>> stats = snapshot.data!;
            StatModel pm10RecentStat = stats[ItemCode.PM10]![0];

            final status = DataUtils.getStatusFromItemCodeAndValue(
              value: pm10RecentStat.seoul,
              itemCode: ItemCode.PM10,
            );

            final ssModel = stats.keys.map((key) {
              final value = stats[key]!;
              final stat = value[0];

              return StatAndStatusModel(
                itemCode: key,
                status: DataUtils.getStatusFromItemCodeAndValue(
                  value: stat.getLevelFromRegion(region), // 지역
                  itemCode: key,
                ),
                stat: stat,
              );
            }).toList();

            return CustomScrollView(
              slivers: [
                MainAppBar(
                  status: status,
                  stat: pm10RecentStat,
                  region: region,
                ),
                // SliverToBoxAdapter => slivers안에 일반 위젯을 넣을 수 있음
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CategoryCard(
                        region: region,
                        models: ssModel,
                      ),
                      const SizedBox(height: 16.0),
                      HourlyCard(),
                    ],
                  ),
                ),
              ],
            );
          }),
    );
  }
}
