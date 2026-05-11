import 'item.dart';
import 'transport.dart';

class Day {
  final int id;
  final int tripId;
  final int dayNumber;
  final String? date;
  final String? notes;
  final int? itemCount;

  Day({
    required this.id, required this.tripId, required this.dayNumber,
    this.date, this.notes, this.itemCount,
  });

  factory Day.fromJson(Map<String, dynamic> json) => Day(
    id: json['id'] as int,
    tripId: json['tripId'] as int,
    dayNumber: json['dayNumber'] as int,
    date: json['date'] as String?,
    notes: json['notes'] as String?,
    itemCount: json['itemCount'] as int?,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'tripId': tripId, 'dayNumber': dayNumber,
    'date': date, 'notes': notes, 'itemCount': itemCount,
  };
}

class DayDetail {
  final int id;
  final int tripId;
  final int dayNumber;
  final String? date;
  final String? notes;
  final List<TripItem> items;
  final List<Transport> transports;

  DayDetail({
    required this.id, required this.tripId, required this.dayNumber,
    this.date, this.notes, required this.items, required this.transports,
  });

  factory DayDetail.fromJson(Map<String, dynamic> json) => DayDetail(
    id: json['id'] as int,
    tripId: json['tripId'] as int,
    dayNumber: json['dayNumber'] as int,
    date: json['date'] as String?,
    notes: json['notes'] as String?,
    items: (json['items'] as List<dynamic>?)
        ?.map((e) => TripItem.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    transports: (json['transports'] as List<dynamic>?)
        ?.map((e) => Transport.fromJson(e as Map<String, dynamic>)).toList() ?? [],
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'tripId': tripId, 'dayNumber': dayNumber,
    'date': date, 'notes': notes,
    'items': items.map((e) => e.toJson()).toList(),
    'transports': transports.map((e) => e.toJson()).toList(),
  };
}

class DayCreateReq {
  final String? date;
  final String? notes;
  DayCreateReq({this.date, this.notes});
  Map<String, dynamic> toJson() => {
    if (date != null) 'date': date,
    if (notes != null) 'notes': notes,
  };
}
