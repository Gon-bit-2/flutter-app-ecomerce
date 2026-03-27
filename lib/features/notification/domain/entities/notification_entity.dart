import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final int id;
  final String title;
  final String body;
  final String type; // ORDER, PAYMENT, SYSTEM, ...
  final Map<String, dynamic>? data; // chứa url redirect, v.v.
  final bool isRead;
  final DateTime? createdAt;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.data,
    this.isRead = false,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, title, body, type, data, isRead, createdAt];
}
