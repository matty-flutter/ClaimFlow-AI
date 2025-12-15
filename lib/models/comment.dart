import 'package:claimflow_ai/models/user.dart';

class Comment {
  final String id;
  final String claimId;
  final User author;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  Comment({
    required this.id,
    required this.claimId,
    required this.author,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'claimId': claimId,
    'author': author.toJson(),
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    id: json['id'] as String,
    claimId: json['claimId'] as String,
    author: User.fromJson(json['author'] as Map<String, dynamic>),
    content: json['content'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  Comment copyWith({
    String? id,
    String? claimId,
    User? author,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Comment(
    id: id ?? this.id,
    claimId: claimId ?? this.claimId,
    author: author ?? this.author,
    content: content ?? this.content,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
