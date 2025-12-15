import 'package:claimflow_ai/models/user.dart';

class Claim {
  final String id;
  final String claimNumber;
  final String type;
  final String status;
  final double amount;
  final String description;
  final User claimant;
  final User? assignedAdjuster;
  final DateTime incidentDate;
  final double? fraudScore;
  final String? aiSummary;
  final List<String>? aiRecommendations;
  final DateTime createdAt;
  final DateTime updatedAt;

  Claim({
    required this.id,
    required this.claimNumber,
    required this.type,
    required this.status,
    required this.amount,
    required this.description,
    required this.claimant,
    this.assignedAdjuster,
    required this.incidentDate,
    this.fraudScore,
    this.aiSummary,
    this.aiRecommendations,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'claimNumber': claimNumber,
    'type': type,
    'status': status,
    'amount': amount,
    'description': description,
    'claimant': claimant.toJson(),
    'assignedAdjuster': assignedAdjuster?.toJson(),
    'incidentDate': incidentDate.toIso8601String(),
    'fraudScore': fraudScore,
    'aiSummary': aiSummary,
    'aiRecommendations': aiRecommendations,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Claim.fromJson(Map<String, dynamic> json) => Claim(
    id: json['id'] as String,
    claimNumber: json['claimNumber'] as String,
    type: json['type'] as String,
    status: json['status'] as String,
    amount: (json['amount'] as num).toDouble(),
    description: json['description'] as String,
    claimant: User.fromJson(json['claimant'] as Map<String, dynamic>),
    assignedAdjuster: json['assignedAdjuster'] != null
        ? User.fromJson(json['assignedAdjuster'] as Map<String, dynamic>)
        : null,
    incidentDate: DateTime.parse(json['incidentDate'] as String),
    fraudScore: json['fraudScore'] != null ? (json['fraudScore'] as num).toDouble() : null,
    aiSummary: json['aiSummary'] as String?,
    aiRecommendations: (json['aiRecommendations'] as List<dynamic>?)?.cast<String>(),
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  Claim copyWith({
    String? id,
    String? claimNumber,
    String? type,
    String? status,
    double? amount,
    String? description,
    User? claimant,
    User? assignedAdjuster,
    DateTime? incidentDate,
    double? fraudScore,
    String? aiSummary,
    List<String>? aiRecommendations,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Claim(
    id: id ?? this.id,
    claimNumber: claimNumber ?? this.claimNumber,
    type: type ?? this.type,
    status: status ?? this.status,
    amount: amount ?? this.amount,
    description: description ?? this.description,
    claimant: claimant ?? this.claimant,
    assignedAdjuster: assignedAdjuster ?? this.assignedAdjuster,
    incidentDate: incidentDate ?? this.incidentDate,
    fraudScore: fraudScore ?? this.fraudScore,
    aiSummary: aiSummary ?? this.aiSummary,
    aiRecommendations: aiRecommendations ?? this.aiRecommendations,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
