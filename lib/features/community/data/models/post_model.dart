// lib/features/community/data/models/post_model.dart

class Post {
  final String id;
  final String userId;
  final String username;
  final String userAvatarUrl;
  final String content;
  final DateTime timestamp;
  final int likes;
  final int comments;
  final String? communityId; // Optional: if a post belongs to a specific community

  Post({
    required this.id,
    required this.userId,
    required this.username,
    required this.userAvatarUrl,
    required this.content,
    required this.timestamp,
    this.likes = 0,
    this.comments = 0,
    this.communityId,
  });

  // Factory constructor for creating a Post from a JSON map
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      userAvatarUrl: json['userAvatarUrl'] as String? ?? '',
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String), // Assuming ISO 8601 string
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      communityId: json['communityId'] as String?,
    );
  }

  // Method for converting a Post object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'userAvatarUrl': userAvatarUrl,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'likes': likes,
      'comments': comments,
      'communityId': communityId,
    };
  }
}
