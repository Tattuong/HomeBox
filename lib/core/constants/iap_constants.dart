class IapConstants {
  IapConstants._();

  static const String productPrefix = 'hb';

  static const String remoteConfigUrl = 'https://api2.blwsmartware.net/R233.json';

  static const String applicationId = 'com.homeboxmng.homebox';

  static const Duration configTimeout = Duration(seconds: 10);

  static const List<String> coinPackIds = [
    'hb_pack_1',
    'hb_pack_2',
    'hb_pack_3',
    'hb_pack_4',
    'hb_pack_5',
    'hb_pack_6',
    'hb_pack_7',
    'hb_pack_8',
    'hb_pack_9',
    'hb_pack_10',
  ];

  static const String removeAdsProductId = 'hb_remove_ads';

  static List<String> get allProductIds => [...coinPackIds, removeAdsProductId];

  static const List<int> coinPackAmounts = [
    50, 100, 200, 350, 500, 750, 1000, 1500, 2200, 3000,
  ];

  static int coinsForProduct(String productId) {
    final index = coinPackIds.indexOf(productId);
    if (index < 0) return 0;
    return coinPackAmounts[index];
  }

  static bool isRemoveAdsProduct(String productId) => productId == removeAdsProductId;

  static const int dailyLoginReward = 10;
  static const int taskCompleteReward = 5;
  static const int maxTaskRewardsPerDay = 20;
  static const int goalMilestoneReward = 8;
  static const int maxGoalRewardsPerDay = 5;
  static const int streakReward = 15;
  static const int maxStreakRewardsPerDay = 1;

  static const int freeItemLimit = 10;
  static const int premiumItemLimit = 200;

  static const int freePhotosPerItem = 3;
  static const int freePhotosTotal = 30;
  static const int premiumPhotosPerItem = 10;
  static const int premiumPhotosTotal = 500;

  static const int firstPurchaseBonusPercent = 50;
  static const int weeklyDealBonusPercent = 30;
  static const int bestValuePackIndex = 4;

  static const List<(int, int)> spinPrizes = [
    (5, 35),
    (10, 28),
    (15, 18),
    (25, 12),
    (50, 5),
    (100, 2),
  ];

  static int weeklyHotDealPackIndex() {
    final week = DateTime.now().difference(DateTime(DateTime.now().year)).inDays ~/ 7;
    return week % coinPackIds.length;
  }

  static int bonusCoinsForPack(int packIndex, {required bool isFirstPurchase, required bool isHotDeal}) {
    final base = packIndex >= 0 && packIndex < coinPackAmounts.length ? coinPackAmounts[packIndex] : 0;
    var bonus = 0;
    if (isFirstPurchase) bonus += (base * firstPurchaseBonusPercent / 100).round();
    if (isHotDeal) bonus += (base * weeklyDealBonusPercent / 100).round();
    return bonus;
  }

  static int totalCoinsForPurchase(String productId, {required bool isFirstPurchase}) {
    final index = coinPackIds.indexOf(productId);
    if (index < 0) return 0;
    final base = coinPackAmounts[index];
    final isHotDeal = index == weeklyHotDealPackIndex();
    return base + bonusCoinsForPack(index, isFirstPurchase: isFirstPurchase, isHotDeal: isHotDeal);
  }
}
