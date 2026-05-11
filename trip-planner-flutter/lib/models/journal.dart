class Journal {
  final int id;
  final int dayId;
  final int tripId;
  final String content;
  final String? mood;
  final String? weather;
  final String? imageUrls;
  final String? createTime;
  final String? updateTime;

  Journal({
    required this.id, required this.dayId, required this.tripId,
    required this.content, this.mood, this.weather,
    this.imageUrls, this.createTime, this.updateTime,
  });

  factory Journal.fromJson(Map<String, dynamic> json) => Journal(
    id: json['id'] as int,
    dayId: json['dayId'] as int,
    tripId: json['tripId'] as int,
    content: (json['content'] as String?) ?? '',
    mood: json['mood'] as String?,
    weather: json['weather'] as String?,
    imageUrls: json['imageUrls'] as String?,
    createTime: json['createTime'] as String?,
    updateTime: json['updateTime'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'dayId': dayId, 'tripId': tripId,
    'content': content, 'mood': mood, 'weather': weather,
    'imageUrls': imageUrls,
  };
}

class JournalReq {
  final String content;
  final String? mood;
  final String? weather;
  final String? imageUrls;

  JournalReq({required this.content, this.mood, this.weather, this.imageUrls});

  Map<String, dynamic> toJson() => {
    'content': content,
    if (mood != null) 'mood': mood,
    if (weather != null) 'weather': weather,
    if (imageUrls != null) 'imageUrls': imageUrls,
  };
}
