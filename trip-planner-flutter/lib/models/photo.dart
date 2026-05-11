class Photo {
  final int id;
  final int tripId;
  final String url;
  final String? thumbnailUrl;
  final String? location;
  final String? photoType;
  final bool? isFeatured;
  final int? sortOrder;
  final String? createTime;

  Photo({
    required this.id, required this.tripId, required this.url,
    this.thumbnailUrl, this.location, this.photoType,
    this.isFeatured, this.sortOrder, this.createTime,
  });

  factory Photo.fromJson(Map<String, dynamic> json) => Photo(
    id: json['id'] as int,
    tripId: json['tripId'] as int,
    url: json['url'] as String,
    thumbnailUrl: json['thumbnailUrl'] as String?,
    location: json['location'] as String?,
    photoType: json['photoType'] as String?,
    isFeatured: json['isFeatured'] as bool?,
    sortOrder: json['sortOrder'] as int?,
    createTime: json['createTime'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'tripId': tripId, 'url': url,
    'thumbnailUrl': thumbnailUrl, 'location': location,
    'photoType': photoType, 'isFeatured': isFeatured,
    'sortOrder': sortOrder,
  };
}

class PhotoAlbumItem {
  final int id;
  final int tripId;
  final String tripName;
  final String tripDestination;
  final String? tripStartDate;
  final String url;
  final String? thumbnailUrl;
  final String? location;
  final String? photoType;
  final bool? isFeatured;
  final int? sortOrder;
  final String? createTime;

  PhotoAlbumItem({
    required this.id, required this.tripId, required this.tripName,
    required this.tripDestination, this.tripStartDate, required this.url,
    this.thumbnailUrl, this.location, this.photoType,
    this.isFeatured, this.sortOrder, this.createTime,
  });

  factory PhotoAlbumItem.fromJson(Map<String, dynamic> json) => PhotoAlbumItem(
    id: json['id'] as int,
    tripId: json['tripId'] as int,
    tripName: (json['tripName'] as String?) ?? '',
    tripDestination: (json['tripDestination'] as String?) ?? '',
    tripStartDate: json['tripStartDate'] as String?,
    url: json['url'] as String,
    thumbnailUrl: json['thumbnailUrl'] as String?,
    location: json['location'] as String?,
    photoType: json['photoType'] as String?,
    isFeatured: json['isFeatured'] as bool?,
    sortOrder: json['sortOrder'] as int?,
    createTime: json['createTime'] as String?,
  );
}

class PhotoBatchUpdateReq {
  final List<int> ids;
  final String? location;
  final String? photoType;
  final bool? isFeatured;

  PhotoBatchUpdateReq({required this.ids, this.location, this.photoType, this.isFeatured});

  Map<String, dynamic> toJson() => {
    'ids': ids,
    if (location != null) 'location': location,
    if (photoType != null) 'photoType': photoType,
    if (isFeatured != null) 'isFeatured': isFeatured,
  };
}

class BatchDeleteReq {
  final List<int> ids;
  BatchDeleteReq({required this.ids});
  Map<String, dynamic> toJson() => {'ids': ids};
}
