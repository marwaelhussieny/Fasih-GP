// lib/features/community/data/models/community_model.dart

import 'package:flutter/material.dart'; // Only for IconData, in a real app this might be separated

class Community {
  final String id;
  final String name;
  final String description;
  final String imageUrl; // Placeholder for community image/icon
  final int memberCount;
  final IconData? icon; // Optional icon for display
  final Color? color; // Optional color for display

  Community({
    required this.id,
    required this.name,
    this.description = '',
    this.imageUrl = '',
    this.memberCount = 0,
    this.icon,
    this.color,
  });

  // Factory constructor for creating a Community from a JSON map (e.g., from Firestore)
  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      memberCount: json['memberCount'] as int? ?? 0,
      // Note: IconData and Color cannot be directly serialized/deserialized from JSON
      // In a real app, you might store icon codes/color hex strings and convert them.
      // For now, these will be handled in the presentation layer for dummy data.
    );
  }

  // Method for converting a Community object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'memberCount': memberCount,
    };
  }
}
