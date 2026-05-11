class AppConstants {
  static const appName = 'Wanderlog';

  static const Map<String, String> itemTypeLabels = {
    'TRANSPORT': '交通',
    'ACCOMMODATION': '住宿',
    'DINING': '餐饮',
    'ATTRACTION': '景点',
    'SHOPPING': '购物',
    'OTHER': '其他',
  };

  static const Map<String, String> transportTypeLabels = {
    'WALK': '步行',
    'BUS': '公交',
    'SUBWAY': '地铁',
    'TAXI': '出租车',
    'RIDE_HAIL': '网约车',
    'SELF_DRIVE': '自驾',
    'BIKE': '骑行',
    'FLIGHT': '飞机',
    'TRAIN': '高铁',
  };

  static const Map<String, String> tripStatusLabels = {
    'PLANNING': '规划中',
    'IN_PROGRESS': '行程中',
    'COMPLETED': '已完成',
    'CANCELLED': '已取消',
  };

  static const Map<String, String> checklistCategories = {
    'DOCUMENT': '证件',
    'LUGGAGE': '行李',
    'ELECTRONICS': '电子设备',
    'CLOTHING': '衣物',
    'TOILETRY': '洗漱用品',
    'MEDICAL': '医疗',
    'OTHER': '其他',
  };

  static const Map<String, String> photoTypes = {
    'SCENERY': '风景',
    'FOOD': '美食',
    'PORTRAIT': '人物',
    'ACTIVITY': '活动',
    'TRANSPORT': '交通',
    'OTHER': '其他',
  };

  static const Map<String, String> journalMoods = {
    'EXCITED': '😆 兴奋',
    'HAPPY': '😊 开心',
    'CALM': '😌 平静',
    'TIRED': '😫 疲惫',
    'DISAPPOINTED': '😞 失望',
    'GRATEFUL': '🥰 感恩',
  };

  static const Map<String, String> journalWeathers = {
    'SUNNY': '☀️ 晴天',
    'CLOUDY': '⛅ 多云',
    'RAINY': '🌧️ 雨天',
    'SNOWY': '❄️ 雪天',
    'WINDY': '💨 大风',
    'FOGGY': '🌫️ 雾天',
  };
}
