class Trip {
  final int id;
  final String tripName;
  final String destination;
  final String? startDate;
  final String? endDate;
  final int? numPeople;
  final String? notes;
  final String status;
  final double? totalBudget;
  final String? coverImageUrl;
  final int? daysCount;
  final String? createTime;
  final String? updateTime;

  Trip({
    required this.id, required this.tripName, required this.destination,
    this.startDate, this.endDate, this.numPeople, this.notes,
    required this.status, this.totalBudget, this.coverImageUrl,
    this.daysCount, this.createTime, this.updateTime,
  });

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
    id: json['id'] as int,
    tripName: json['tripName'] as String,
    destination: json['destination'] as String,
    startDate: json['startDate'] as String?,
    endDate: json['endDate'] as String?,
    numPeople: json['numPeople'] as int?,
    notes: json['notes'] as String?,
    status: (json['status'] as String?) ?? 'PLANNING',
    totalBudget: (json['totalBudget'] as num?)?.toDouble(),
    coverImageUrl: json['coverImageUrl'] as String?,
    daysCount: json['daysCount'] as int?,
    createTime: json['createTime'] as String?,
    updateTime: json['updateTime'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'tripName': tripName, 'destination': destination,
    'startDate': startDate, 'endDate': endDate, 'numPeople': numPeople,
    'notes': notes, 'status': status, 'totalBudget': totalBudget,
    'coverImageUrl': coverImageUrl, 'daysCount': daysCount,
  };
}

class TripCreateReq {
  final String tripName;
  final String destination;
  final String? startDate;
  final String? endDate;
  final int? numPeople;
  final String? notes;
  final double? totalBudget;

  TripCreateReq({
    required this.tripName, required this.destination,
    this.startDate, this.endDate, this.numPeople, this.notes, this.totalBudget,
  });

  Map<String, dynamic> toJson() => {
    'tripName': tripName, 'destination': destination,
    if (startDate != null) 'startDate': startDate,
    if (endDate != null) 'endDate': endDate,
    if (numPeople != null) 'numPeople': numPeople,
    if (notes != null) 'notes': notes,
    if (totalBudget != null) 'totalBudget': totalBudget,
  };
}

class TripUpdateReq {
  final String? tripName;
  final String? destination;
  final String? startDate;
  final String? endDate;
  final int? numPeople;
  final String? notes;
  final double? totalBudget;

  TripUpdateReq({this.tripName, this.destination, this.startDate, this.endDate, this.numPeople, this.notes, this.totalBudget});

  Map<String, dynamic> toJson() => {
    if (tripName != null) 'tripName': tripName,
    if (destination != null) 'destination': destination,
    if (startDate != null) 'startDate': startDate,
    if (endDate != null) 'endDate': endDate,
    if (numPeople != null) 'numPeople': numPeople,
    if (notes != null) 'notes': notes,
    if (totalBudget != null) 'totalBudget': totalBudget,
  };
}

class PageResult<T> {
  final int total;
  final int page;
  final int size;
  final List<T> records;

  PageResult({required this.total, required this.page, required this.size, required this.records});

  factory PageResult.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromItem) {
    return PageResult(
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      size: (json['size'] as num?)?.toInt() ?? 10,
      records: (json['records'] as List<dynamic>?)
          ?.map((e) => fromItem(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}
