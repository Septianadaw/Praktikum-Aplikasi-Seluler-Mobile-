class ItemModel {
  final int id;
  final String name;
  final String description;
  final String category;
  final String priority; // 'Rendah', 'Normal', 'Tinggi'
  final bool isFavorite;
  final String iconEmoji;
  final DateTime addedAt;
  final List<String> activityLog;

  ItemModel({
    required this.id,
    required this.name,
    required this.description,
    this.category = 'Lainnya',
    this.priority = 'Normal',
    this.isFavorite = false,
    this.iconEmoji = '📦',
    DateTime? addedAt,
    List<String>? activityLog,
  })  : addedAt = addedAt ?? DateTime.now(),
        activityLog = activityLog ?? [];

  ItemModel copyWith({
    int? id,
    String? name,
    String? description,
    String? category,
    String? priority,
    bool? isFavorite,
    String? iconEmoji,
    DateTime? addedAt,
    List<String>? activityLog,
  }) {
    return ItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isFavorite: isFavorite ?? this.isFavorite,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      addedAt: addedAt ?? this.addedAt,
      activityLog: activityLog ?? this.activityLog,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'priority': priority,
      'isFavorite': isFavorite,
      'iconEmoji': iconEmoji,
      'addedAt': addedAt.toIso8601String(),
      'activityLog': activityLog,
    };
  }

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      category: map['category'] ?? 'Lainnya',
      priority: map['priority'] ?? 'Normal',
      isFavorite: map['isFavorite'] ?? false,
      iconEmoji: map['iconEmoji'] ?? '📦',
      addedAt: map['addedAt'] != null
          ? DateTime.parse(map['addedAt'])
          : DateTime.now(),
      activityLog: map['activityLog'] != null
          ? List<String>.from(map['activityLog'])
          : [],
    );
  }
}