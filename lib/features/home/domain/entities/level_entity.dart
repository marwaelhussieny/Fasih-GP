// lib/features/home/domain/entities/level_entity.dart
class LevelEntity {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final int order;
  final int requiredXP;
  final bool isCompleted;
  final bool isUnlocked;
  final List<String> lessonIds;
  final Map<String, dynamic>? metadata;

  const LevelEntity({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.order,
    required this.requiredXP,
    this.isCompleted = false,
    this.isUnlocked = false,
    this.lessonIds = const [],
    this.metadata,
  });

  factory LevelEntity.fromJson(Map<String, dynamic> json) {
    return LevelEntity(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image'] ?? json['imageUrl'],
      order: json['order'] ?? 0,
      requiredXP: json['requiredXP'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      isUnlocked: json['isUnlocked'] ?? false,
      lessonIds: List<String>.from(json['lessons'] ?? []),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'order': order,
      'requiredXP': requiredXP,
      'isCompleted': isCompleted,
      'isUnlocked': isUnlocked,
      'lessonIds': lessonIds,
      'metadata': metadata,
    };
  }

  LevelEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    int? order,
    int? requiredXP,
    bool? isCompleted,
    bool? isUnlocked,
    List<String>? lessonIds,
    Map<String, dynamic>? metadata,
  }) {
    return LevelEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      order: order ?? this.order,
      requiredXP: requiredXP ?? this.requiredXP,
      isCompleted: isCompleted ?? this.isCompleted,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      lessonIds: lessonIds ?? this.lessonIds,
      metadata: metadata ?? this.metadata,
    );
  }
}