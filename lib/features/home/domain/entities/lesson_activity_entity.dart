// lib/features/home/domain/entities/lesson_activity_entity.dart
enum LessonActivityType {
video,
quiz,
writing,
speaking,
flashcards,
grammar,
wordle,
reading,
listening,
}

class LessonActivityEntity {
final String id;
final String title;
final String description;
final LessonActivityType type;
final String? content;
final String? videoUrl;
final String? audioUrl;
final String? imageUrl;
final int duration; // in minutes
final int xpReward;
final bool isCompleted;
final bool isRequired;
final Map<String, dynamic>? metadata;

const LessonActivityEntity({
required this.id,
required this.title,
required this.description,
required this.type,
this.content,
this.videoUrl,
this.audioUrl,
this.imageUrl,
this.duration = 0,
this.xpReward = 0,
this.isCompleted = false,
this.isRequired = true,
this.metadata,
});

factory LessonActivityEntity.fromJson(Map<String, dynamic> json) {
return LessonActivityEntity(
id: json['_id'] ?? json['id'] ?? '',
title: json['title'] ?? '',
description: json['description'] ?? '',
type: _parseActivityType(json['type']),
content: json['content'],
videoUrl: json['videoUrl'],
audioUrl: json['audioUrl'],
imageUrl: json['imageUrl'],
duration: json['duration'] ?? 0,
xpReward: json['xpReward'] ?? 0,
isCompleted: json['isCompleted'] ?? false,
isRequired: json['isRequired'] ?? true,
metadata: json['metadata'],
);
}

static LessonActivityType _parseActivityType(String? type) {
switch (type?.toLowerCase()) {
case 'video': return LessonActivityType.video;
case 'quiz': return LessonActivityType.quiz;
case 'writing': return LessonActivityType.writing;
case 'speaking': return LessonActivityType.speaking;
case 'flashcards': return LessonActivityType.flashcards;
case 'grammar': return LessonActivityType.grammar;
case 'wordle': return LessonActivityType.wordle;
case 'reading': return LessonActivityType.reading;
case 'listening': return LessonActivityType.listening;
default: return LessonActivityType.video;
}
}

Map<String, dynamic> toJson() {
return {
'id': id,
'title': title,
'description': description,
'type': type.name,
'content': content,
'videoUrl': videoUrl,
'audioUrl': audioUrl,
'imageUrl': imageUrl,
'duration': duration,
'xpReward': xpReward,
'isCompleted': isCompleted,
'isRequired': isRequired,
'metadata': metadata,
};
}

LessonActivityEntity copyWith({
String? id,
String? title,
String? description,
LessonActivityType? type,
String? content,
String? videoUrl,
String? audioUrl,
String? imageUrl,
int? duration,
int? xpReward,
bool? isCompleted,
bool? isRequired,
Map<String, dynamic>? metadata,
}) {
return LessonActivityEntity(
id: id ?? this.id,
title: title ?? this.title,
description: description ?? this.description,
type: type ?? this.type,
content: content ?? this.content,
videoUrl: videoUrl ?? this.videoUrl,
audioUrl: audioUrl ?? this.audioUrl,
imageUrl: imageUrl ?? this.imageUrl,
duration: duration ?? this.duration,
xpReward: xpReward ?? this.xpReward,
isCompleted: isCompleted ?? this.isCompleted,
isRequired: isRequired ?? this.isRequired,
metadata: metadata ?? this.metadata,
);
}
}