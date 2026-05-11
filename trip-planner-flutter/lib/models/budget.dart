class BudgetSummary {
  final double? totalBudget;
  final double? itemTotal;
  final double? transportTotal;
  final double? accommodationTotal;
  final double? diningTotal;
  final double? attractionTotal;
  final double? shoppingTotal;
  final double? otherTotal;
  final double? spentTotal;
  final double? remainingBudget;

  BudgetSummary({
    this.totalBudget, this.itemTotal, this.transportTotal,
    this.accommodationTotal, this.diningTotal, this.attractionTotal,
    this.shoppingTotal, this.otherTotal, this.spentTotal, this.remainingBudget,
  });

  factory BudgetSummary.fromJson(Map<String, dynamic> json) => BudgetSummary(
    totalBudget: (json['totalBudget'] as num?)?.toDouble(),
    itemTotal: (json['itemTotal'] as num?)?.toDouble(),
    transportTotal: (json['transportTotal'] as num?)?.toDouble(),
    accommodationTotal: (json['accommodationTotal'] as num?)?.toDouble(),
    diningTotal: (json['diningTotal'] as num?)?.toDouble(),
    attractionTotal: (json['attractionTotal'] as num?)?.toDouble(),
    shoppingTotal: (json['shoppingTotal'] as num?)?.toDouble(),
    otherTotal: (json['otherTotal'] as num?)?.toDouble(),
    spentTotal: (json['spentTotal'] as num?)?.toDouble(),
    remainingBudget: (json['remainingBudget'] as num?)?.toDouble(),
  );
}

class BudgetByDay {
  final int dayId;
  final int dayNumber;
  final String? date;
  final double? itemCost;
  final double? transportCost;
  final double? dayTotal;

  BudgetByDay({
    required this.dayId, required this.dayNumber, this.date,
    this.itemCost, this.transportCost, this.dayTotal,
  });

  factory BudgetByDay.fromJson(Map<String, dynamic> json) => BudgetByDay(
    dayId: json['dayId'] as int,
    dayNumber: json['dayNumber'] as int,
    date: json['date'] as String?,
    itemCost: (json['itemCost'] as num?)?.toDouble(),
    transportCost: (json['transportCost'] as num?)?.toDouble(),
    dayTotal: (json['dayTotal'] as num?)?.toDouble(),
  );
}

class BudgetByCategory {
  final String category;
  final int count;
  final double? totalCost;
  final double? percentage;

  BudgetByCategory({required this.category, required this.count, this.totalCost, this.percentage});

  factory BudgetByCategory.fromJson(Map<String, dynamic> json) => BudgetByCategory(
    category: json['category'] as String,
    count: (json['count'] as num?)?.toInt() ?? 0,
    totalCost: (json['totalCost'] as num?)?.toDouble(),
    percentage: (json['percentage'] as num?)?.toDouble(),
  );
}
