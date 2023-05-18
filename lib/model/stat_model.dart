enum ItemCode {
  // 미세먼지
  PM10,
  // 초미세먼지
  PM25,
  // 이산화질소
  NO2,
  // 오존
  O3,
  // 일산화탄소
  CO,
  // 이황산가스
  SO2,
}

class StatModel {
  final double daegu;
  final double chungnam;
  final double incheon;
  final double daejeon;
  final double gyeongbuk;
  final double sejong;
  final double gwangju;
  final double jeonbuk;
  final double gangwon;
  final double ulsan;
  final double jeonnam;
  final double seoul;
  final double busan;
  final double jeju;
  final double chungbuk;
  final double gyeongnam;
  final double gyeonggi;
  final DateTime dataTime;
  final ItemCode itemCode;

  // constructor => 인스턴스화 할 때, json으로부터 StatModel 형태로 만들어 줌
  StatModel.fromJson({required Map<String, dynamic> json})
      // null인 경우 0
      : daegu = double.parse(json['daegu'] ?? '0'),
        chungnam = double.parse(json['chungnam'] ?? '0'),
        incheon = double.parse(json['incheon'] ?? '0'),
        daejeon = double.parse(json['daejeon'] ?? '0'),
        gyeongbuk = double.parse(json['gyeongbuk'] ?? '0'),
        sejong = double.parse(json['sejong'] ?? '0'),
        gwangju = double.parse(json['gwangju'] ?? '0'),
        jeonbuk = double.parse(json['jeonbuk'] ?? '0'),
        gangwon = double.parse(json['gangwon'] ?? '0'),
        ulsan = double.parse(json['ulsan'] ?? '0'),
        jeonnam = double.parse(json['jeonnam'] ?? '0'),
        seoul = double.parse(json['seoul'] ?? '0'),
        busan = double.parse(json['busan'] ?? '0'),
        jeju = double.parse(json['jeju'] ?? '0'),
        chungbuk = double.parse(json['chungbuk'] ?? '0'),
        gyeongnam = double.parse(json['gyeongnam'] ?? '0'),
        gyeonggi = double.parse(json['gyeonggi'] ?? '0'),
        dataTime = DateTime.parse(json['dataTime']),
        itemCode = parseItemCode(json['itemCode']);

  // static으로 선언해주어야 constructor에서 사용이 가능
  static ItemCode parseItemCode(String raw) {
    if (raw == 'PM2.5') {
      return ItemCode.PM25;
    }

    /**
  * ENUM
  * ItemCode.CO.toString() => 'ItemCode.CO'
  * ItemCode.NO2.name => 'NO2'
  * ItemCode.values.firstWhere => ItemCode의 모든 데이터 중 첫번째 값
  */
    return ItemCode.values.firstWhere((element) => element.name == raw);
  }

  double getLevelFromRegion(String region) {
    if (region == '서울') {
      return seoul;
    } else if (region == '경기') {
      return gyeonggi;
    } else if (region == '인천') {
      return incheon;
    } else if (region == '충남') {
      return chungnam;
    } else if (region == '충북') {
      return chungbuk;
    } else if (region == '전남') {
      return chungnam;
    } else if (region == '전북') {
      return chungbuk;
    } else if (region == '광주') {
      return gwangju;
    } else if (region == '경남') {
      return gyeongnam;
    } else if (region == '경북') {
      return gyeongbuk;
    } else if (region == '강원') {
      return gangwon;
    } else if (region == '대전') {
      return daejeon;
    } else if (region == '대구') {
      return daegu;
    } else if (region == '울산') {
      return ulsan;
    } else if (region == '부산') {
      return busan;
    } else if (region == '세종') {
      return sejong;
    } else if (region == '제주') {
      return jeju;
    } else {
      throw Exception('알 수 없는 지역입니다.');
    }
  }
}
