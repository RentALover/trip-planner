class ChecklistItem {
  final int id;
  final int tripId;
  final String title;
  final String category;
  final bool isChecked;
  final int? sortOrder;

  ChecklistItem({
    required this.id, required this.tripId, required this.title,
    required this.category, required this.isChecked, this.sortOrder,
  });

  factory ChecklistItem.fromJson(Map<String, dynamic> json) => ChecklistItem(
    id: json['id'] as int,
    tripId: json['tripId'] as int,
    title: json['title'] as String,
    category: (json['category'] as String?) ?? 'OTHER',
    isChecked: json['isChecked'] == 1 || json['isChecked'] == true,
    sortOrder: json['sortOrder'] as int?,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'tripId': tripId, 'title': title,
    'category': category, 'isChecked': isChecked,
    'sortOrder': sortOrder,
  };
}

class ChecklistItemReq {
  final String title;
  final String? category;
  ChecklistItemReq({required this.title, this.category});
  Map<String, dynamic> toJson() => {
    'title': title,
    if (category != null) 'category': category,
  };
}
