class Transport {
  final int id;
  final int dayId;
  final int tripId;
  final int? fromItemId;
  final int? toItemId;
  final String transportType;
  final String? departureTime;
  final int? estimatedDuration;
  final double? cost;
  final String? transportNumber;
  final String? departureStation;
  final String? arrivalStation;
  final String? routeInfo;
  final String? notes;
  final double? sortOrder;

  Transport({
    required this.id, required this.dayId, required this.tripId,
    this.fromItemId, this.toItemId, required this.transportType,
    this.departureTime, this.estimatedDuration, this.cost,
    this.transportNumber, this.departureStation, this.arrivalStation,
    this.routeInfo, this.notes, this.sortOrder,
  });

  factory Transport.fromJson(Map<String, dynamic> json) => Transport(
    id: json['id'] as int,
    dayId: json['dayId'] as int,
    tripId: json['tripId'] as int,
    fromItemId: json['fromItemId'] as int?,
    toItemId: json['toItemId'] as int?,
    transportType: (json['transportType'] as String?) ?? 'WALK',
    departureTime: json['departureTime'] as String?,
    estimatedDuration: json['estimatedDuration'] as int?,
    cost: (json['cost'] as num?)?.toDouble(),
    transportNumber: json['transportNumber'] as String?,
    departureStation: json['departureStation'] as String?,
    arrivalStation: json['arrivalStation'] as String?,
    routeInfo: json['routeInfo'] as String?,
    notes: json['notes'] as String?,
    sortOrder: (json['sortOrder'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'dayId': dayId, 'tripId': tripId,
    'fromItemId': fromItemId, 'toItemId': toItemId,
    'transportType': transportType, 'departureTime': departureTime,
    'estimatedDuration': estimatedDuration, 'cost': cost,
    'transportNumber': transportNumber, 'departureStation': departureStation,
    'arrivalStation': arrivalStation, 'routeInfo': routeInfo,
    'notes': notes, 'sortOrder': sortOrder,
  };
}

class TransportCreateReq {
  final int fromItemId;
  final int toItemId;
  final String transportType;
  final String? departureTime;
  final int? estimatedDuration;
  final double? cost;
  final String? transportNumber;
  final String? departureStation;
  final String? arrivalStation;
  final String? routeInfo;
  final String? notes;

  TransportCreateReq({
    required this.fromItemId, required this.toItemId,
    required this.transportType, this.departureTime,
    this.estimatedDuration, this.cost, this.transportNumber,
    this.departureStation, this.arrivalStation,
    this.routeInfo, this.notes,
  });

  Map<String, dynamic> toJson() => {
    'fromItemId': fromItemId, 'toItemId': toItemId,
    'transportType': transportType,
    if (departureTime != null) 'departureTime': departureTime,
    if (estimatedDuration != null) 'estimatedDuration': estimatedDuration,
    if (cost != null) 'cost': cost,
    if (transportNumber != null) 'transportNumber': transportNumber,
    if (departureStation != null) 'departureStation': departureStation,
    if (arrivalStation != null) 'arrivalStation': arrivalStation,
    if (routeInfo != null) 'routeInfo': routeInfo,
    if (notes != null) 'notes': notes,
  };
}

class TransportUpdateReq {
  final String? transportType;
  final String? departureTime;
  final int? estimatedDuration;
  final double? cost;
  final String? transportNumber;
  final String? departureStation;
  final String? arrivalStation;
  final String? routeInfo;
  final String? notes;

  TransportUpdateReq({this.transportType, this.departureTime, this.estimatedDuration, this.cost, this.transportNumber, this.departureStation, this.arrivalStation, this.routeInfo, this.notes});

  Map<String, dynamic> toJson() => {
    if (transportType != null) 'transportType': transportType,
    if (departureTime != null) 'departureTime': departureTime,
    if (estimatedDuration != null) 'estimatedDuration': estimatedDuration,
    if (cost != null) 'cost': cost,
    if (transportNumber != null) 'transportNumber': transportNumber,
    if (departureStation != null) 'departureStation': departureStation,
    if (arrivalStation != null) 'arrivalStation': arrivalStation,
    if (routeInfo != null) 'routeInfo': routeInfo,
    if (notes != null) 'notes': notes,
  };
}

class TransportLookupResult {
  final String? departureStation;
  final String? arrivalStation;
  final String? departureTime;
  final String? arrivalTime;
  final int? durationMinutes;
  final String? routeInfo;

  TransportLookupResult({this.departureStation, this.arrivalStation, this.departureTime, this.arrivalTime, this.durationMinutes, this.routeInfo});

  factory TransportLookupResult.fromJson(Map<String, dynamic> json) => TransportLookupResult(
    departureStation: json['departureStation'] as String?,
    arrivalStation: json['arrivalStation'] as String?,
    departureTime: json['departureTime'] as String?,
    arrivalTime: json['arrivalTime'] as String?,
    durationMinutes: json['durationMinutes'] as int?,
    routeInfo: json['routeInfo'] as String?,
  );
}
