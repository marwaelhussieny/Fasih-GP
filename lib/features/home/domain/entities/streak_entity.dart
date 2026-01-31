// lib/features/home/domain/entities/streak_entity.dart
class StreakEntity {
final String userId;
final int currentStreak;
final int longestStreak;
final DateTime lastActivityDate;
final List<DateTime> streakDates;

const StreakEntity({
required this.userId,
required this.currentStreak,
required this.longestStreak,
required this.lastActivityDate,
this.streakDates = const [],
});

factory StreakEntity.fromJson(Map<String, dynamic> json) {
return StreakEntity(
userId: json['userId'] ?? '',
currentStreak: json['currentStreak'] ?? 0,
longestStreak: json['longestStreak'] ?? 0,
lastActivityDate: DateTime.tryParse(json['lastActivityDate'] ?? '') ?? DateTime.now(),
streakDates: (json['streakDates'] as List<dynamic>?)
    ?.map((date) => DateTime.tryParse(date.toString()) ?? DateTime.now())
    .toList() ?? [],
);
}

Map<String, dynamic> toJson() {
return {
'userId': userId,
'currentStreak': currentStreak,
'longestStreak': longestStreak,
'lastActivityDate': lastActivityDate.toIso8601String(),
'streakDates': streakDates.map((date) => date.toIso8601String()).toList(),
};
}
}
