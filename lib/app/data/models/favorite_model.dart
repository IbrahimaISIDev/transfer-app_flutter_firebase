// favorite_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteModel {
  final String id;
  final String userId;
  final String recipientPhone;
  final String? recipientFullName;
  final DateTime createdAt;

  FavoriteModel({
    required this.id,
    required this.userId,
    required this.recipientPhone,
    this.recipientFullName,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'recipientPhone': recipientPhone,
    'recipientFullName': recipientFullName,
    'createdAt': createdAt,
  };

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id'],
      userId: json['userId'],
      recipientPhone: json['recipientPhone'],
      recipientFullName: json['recipientFullName'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }
}