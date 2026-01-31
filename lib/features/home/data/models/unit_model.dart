// lib/features/home/data/models/unit_model.dart - NEW FILE
class UnitModel {
  final String id;
  final String title;
  final String description;
  final String levelId;
  final int order;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UnitModel({
    required this.id,
    required this.title,
    required this.description,
    required this.levelId,
    required this.order,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      levelId: json['levelId'] as String,
      order: json['order'] as int,
      isPublished: json['isPublished'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'levelId': levelId,
      'order': order,
      'isPublished': isPublished,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// lib/features/home/domain/entities/unit_entity.dart - NEW FILE
class UnitEntity {
  final String id;
  final String title;
  final String description;
  final String levelId;
  final int order;
  final bool isPublished;
  final bool isCompleted;
  final double progress;

  const UnitEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.levelId,
    required this.order,
    required this.isPublished,
    this.isCompleted = false,
    this.progress = 0.0,
  });

  UnitEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? levelId,
    int? order,
    bool? isPublished,
    bool? isCompleted,
    double? progress,
  }) {
    return UnitEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      levelId: levelId ?? this.levelId,
      order: order ?? this.order,
      isPublished: isPublished ?? this.isPublished,
      isCompleted: isCompleted ?? this.isCompleted,
      progress: progress ?? this.progress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'levelId': levelId,
      'order': order,
      'isPublished': isPublished,
      'isCompleted': isCompleted,
      'progress': progress,
    };
  }

  factory UnitEntity.fromJson(Map<String, dynamic> json) {
    return UnitEntity(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      levelId: json['levelId'] as String? ?? '',
      order: json['order'] as int? ?? 0,
      isPublished: json['isPublished'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
    );
  }
}