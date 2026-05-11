class DailyForecast {
  final String date;
  final int weatherCode;
  final String? weatherDesc;
  final double tempMax;
  final double tempMin;
  final int? precipitationProbability;
  final String? icon;

  DailyForecast({
    required this.date, required this.weatherCode, this.weatherDesc,
    required this.tempMax, required this.tempMin,
    this.precipitationProbability, this.icon,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) => DailyForecast(
    date: json['date'] as String,
    weatherCode: (json['weatherCode'] as num?)?.toInt() ?? 0,
    weatherDesc: json['weatherDesc'] as String?,
    tempMax: (json['tempMax'] as num).toDouble(),
    tempMin: (json['tempMin'] as num).toDouble(),
    precipitationProbability: json['precipitationProbability'] as int?,
    icon: json['icon'] as String?,
  );
}
