import 'package:flutter/material.dart';

class TicketCategoryModel {
  final int id;
  final String name;
  final String color; // hex sin #, ej. "7C3AED"
  final String description;

  const TicketCategoryModel({
    required this.id,
    required this.name,
    required this.color,
    required this.description,
  });

  factory TicketCategoryModel.fromJson(Map<String, dynamic> json) {
    return TicketCategoryModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      name:        (json['name'] ?? '').toString(),
      color:       (json['color'] ?? '').toString().replaceAll('#', ''),
      description: (json['description'] ?? '').toString(),
    );
  }

  Color get flutterColor {
    final hex = color.replaceAll('#', '');
    if (hex.length == 6) {
      final value = int.tryParse('FF$hex', radix: 16);
      if (value != null) return Color(value);
    }
    return const Color(0xFF6B7280);
  }
}
