class TripItem {
  final int id;
  final int dayId;
  final int tripId;
  final String itemType;
  final String title;
  final String? description;
  final String? startTime;
  final String? endTime;
  final String? location;
  final double? cost;
  final String? itemDetails;
  final double? sortOrder;
  final String? imageUrl;

  TripItem({
    required this.id, required this.dayId, required this.tripId,
    required this.itemType, required this.title,
    this.description, this.startTime, this.endTime,
    this.location, this.cost, this.itemDetails,
    this.sortOrder, this.imageUrl,
  });

  factory TripItem.fromJson(Map<String, dynamic> json) => TripItem(
    id: json['id'] as int,
    dayId: json['dayId'] as int,
    tripId: json['tripId'] as int,
    itemType: (json['itemType'] as String?) ?? 'OTHER',
    title: json['title'] as String,
    description: json['description'] as String?,
    startTime: json['startTime'] as String?,
    endTime: json['endTime'] as String?,
    location: json['location'] as String?,
    cost: (json['cost'] as num?)?.toDouble(),
    itemDetails: json['itemDetails'] as String?,
    sortOrder: (json['sortOrder'] as num?)?.toDouble(),
    imageUrl: json['imageUrl'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'dayId': dayId, 'tripId': tripId,
    'itemType': itemType, 'title': title,
    'description': description, 'startTime': startTime,
    'endTime': endTime, 'location': location,
    'cost': cost, 'itemDetails': itemDetails,
    'sortOrder': sortOrder, 'imageUrl': imageUrl,
  };
}

class ItemCreateReq {
  final String itemType;
  final String title;
  final String? description;
  final String? startTime;
  final String? endTime;
  final String? location;
  final double? cost;
  final String? itemDetails;
  final double? sortOrder;

  ItemCreateReq({
    required this.itemType, required this.title,
    this.description, this.startTime, this.endTime,
    this.location, this.cost, this.itemDetails, this.sortOrder,
  });

  Map<String, dynamic> toJson() => {
    'itemType': itemType, 'title': title,
    if (description != null) 'description': description,
    if (startTime != null) 'startTime': startTime,
    if (endTime != null) 'endTime': endTime,
    if (location != null) 'location': location,
    if (cost != null) 'cost': cost,
    if (itemDetails != null) 'itemDetails': itemDetails,
    if (sortOrder != null) 'sortOrder': sortOrder,
  };
}

class ItemUpdateReq {
  final String? title;
  final String? description;
  final String? startTime;
  final String? endTime;
  final String? location;
  final double? cost;
  final String? itemDetails;

  ItemUpdateReq({this.title, this.description, this.startTime, this.endTime, this.location, this.cost, this.itemDetails});

  Map<String, dynamic> toJson() => {
    if (title != null) 'title': title,
    if (description != null) 'description': description,
    if (startTime != null) 'startTime': startTime,
    if (endTime != null) 'endTime': endTime,
    if (location != null) 'location': location,
    if (cost != null) 'cost': cost,
    if (itemDetails != null) 'itemDetails': itemDetails,
  };
}

class ItemMoveReq {
  final int targetDayId;
  final double? sortOrder;
  ItemMoveReq({required this.targetDayId, this.sortOrder});
  Map<String, dynamic> toJson() => {
    'targetDayId': targetDayId,
    if (sortOrder != null) 'sortOrder': sortOrder,
  };
}

class SortItem {
  final int id;
  final double sortOrder;
  SortItem({required this.id, required this.sortOrder});
  Map<String, dynamic> toJson() => {'id': id, 'sortOrder': sortOrder};
}

class ItemSortReq {
  final List<SortItem> items;
  ItemSortReq({required this.items});
  Map<String, dynamic> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
  };
}

class TimeEntry {
  final int id;
  final String? startTime;
  final String? endTime;
  TimeEntry({required this.id, this.startTime, this.endTime});
  Map<String, dynamic> toJson() => {
    'id': id,
    if (startTime != null) 'startTime': startTime,
    if (endTime != null) 'endTime': endTime,
  };
}

class ItemBatchTimeUpdateReq {
  final List<TimeEntry> items;
  ItemBatchTimeUpdateReq({required this.items});
  Map<String, dynamic> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
  };
}
