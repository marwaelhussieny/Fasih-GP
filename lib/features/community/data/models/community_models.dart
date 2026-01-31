// lib/features/community/data/models/community_models.dart

class CommunityPost {
  final String id;
  final String createdBy;
  final String content;
  final String category;
  final List<String> likes;
  final List<CommunityComment> comments;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdByName;
  final bool isLiked;

  CommunityPost({
    required this.id,
    required this.createdBy,
    required this.content,
    required this.category,
    required this.likes,
    required this.comments,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.createdByName,
    this.isLiked = false,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['_id'] ?? json['id'] ?? '',
      createdBy: json['createdBy'] is Map
          ? json['createdBy']['_id'] ?? ''
          : json['createdBy'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? '',
      likes: List<String>.from(json['likes'] ?? []),
      comments: (json['comments'] as List<dynamic>?)
          ?.map((c) => CommunityComment.fromJson(c))
          .toList() ?? [],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      createdByName: json['createdBy'] is Map
          ? json['createdBy']['fullName'] ?? json['createdBy']['name']
          : null,
      isLiked: false, // Will be set based on current user
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createdBy': createdBy,
      'content': content,
      'category': category,
    };
  }

  CommunityPost copyWith({
    String? id,
    String? createdBy,
    String? content,
    String? category,
    List<String>? likes,
    List<CommunityComment>? comments,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdByName,
    bool? isLiked,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      content: content ?? this.content,
      category: category ?? this.category,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdByName: createdByName ?? this.createdByName,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  int get likesCount => likes.length;
  int get commentsCount => comments.length;
}

class CommunityComment {
  final String? id;
  final String userId;
  final String userName;
  final String text;
  final DateTime createdAt;

  CommunityComment({
    this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
  });

  factory CommunityComment.fromJson(Map<String, dynamic> json) {
    return CommunityComment(
      id: json['_id'] ?? json['id'],
      userId: json['user'] is Map
          ? json['user']['_id'] ?? ''
          : json['userId'] ?? '',
      userName: json['user'] is Map
          ? json['user']['fullName'] ?? json['user']['name'] ?? 'مستخدم'
          : json['userName'] ?? 'مستخدم',
      text: json['text'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
    };
  }
}

class CommunityCategory {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  CommunityCategory({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CommunityCategory.fromJson(Map<String, dynamic> json) {
    return CommunityCategory(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

class CreatePostRequest {
  final String content;
  final String userId;
  final String category;

  CreatePostRequest({
    required this.content,
    required this.userId,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'userId': userId,
      'category': category,
    };
  }
}

class AddCommentRequest {
  final String text;

  AddCommentRequest({
    required this.text,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
    };
  }
}

class CommunityStats {
  final int totalMembers;
  final int activePosts;
  final int totalInteractions;
  final int savedPosts;

  CommunityStats({
    this.totalMembers = 0,
    this.activePosts = 0,
    this.totalInteractions = 0,
    this.savedPosts = 0,
  });

  factory CommunityStats.fromJson(Map<String, dynamic> json) {
    return CommunityStats(
      totalMembers: json['totalMembers'] ?? 0,
      activePosts: json['activePosts'] ?? 0,
      totalInteractions: json['totalInteractions'] ?? 0,
      savedPosts: json['savedPosts'] ?? 0,
    );
  }
}