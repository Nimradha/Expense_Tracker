import 'package:flutter/material.dart';

class ExpenseCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final double? budgetLimit;
  final bool isCustom;

  const ExpenseCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.budgetLimit,
    this.isCustom = false,
  });

  // Serialization for SQLite and persistence
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconCode': icon.codePoint,
      'colorValue': color.value,
      'budgetLimit': budgetLimit,
      'isCustom': isCustom ? 1 : 0,
    };
  }

  factory ExpenseCategory.fromMap(Map<String, dynamic> map) {
    return ExpenseCategory(
      id: map['id'] as String,
      name: map['name'] as String,
      icon: IconData(
        map['iconCode'] as int,
        fontFamily: 'MaterialIcons',
      ),
      color: Color(map['colorValue'] as int),
      budgetLimit: map['budgetLimit'] != null
          ? (map['budgetLimit'] as num).toDouble()
          : null,
      isCustom: (map['isCustom'] as int?) == 1,
    );
  }

  ExpenseCategory copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    double? budgetLimit,
    bool? isCustom,
  }) {
    return ExpenseCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      budgetLimit: budgetLimit ?? this.budgetLimit,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  // Predefined default categories
  static const List<ExpenseCategory> defaultCategories = [
    ExpenseCategory(
      id: 'food',
      name: 'Food & Dining',
      icon: Icons.restaurant_rounded,
      color: Color(0xFFF97316), // Orange
      budgetLimit: 400.0,
    ),
    ExpenseCategory(
      id: 'transport',
      name: 'Transportation',
      icon: Icons.directions_subway_rounded,
      color: Color(0xFF3B82F6), // Blue
      budgetLimit: 200.0,
    ),
    ExpenseCategory(
      id: 'shopping',
      name: 'Shopping',
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFFEC4899), // Pink
      budgetLimit: 250.0,
    ),
    ExpenseCategory(
      id: 'bills',
      name: 'Bills & Utilities',
      icon: Icons.receipt_long_rounded,
      color: Color(0xFFEAB308), // Yellow
      budgetLimit: 300.0,
    ),
    ExpenseCategory(
      id: 'entertainment',
      name: 'Entertainment',
      icon: Icons.movie_filter_rounded,
      color: Color(0xFF8B5CF6), // Purple
      budgetLimit: 150.0,
    ),
    ExpenseCategory(
      id: 'health',
      name: 'Healthcare',
      icon: Icons.favorite_rounded,
      color: Color(0xFFEF4444), // Red
      budgetLimit: 150.0,
    ),
    ExpenseCategory(
      id: 'education',
      name: 'Education',
      icon: Icons.school_rounded,
      color: Color(0xFF14B8A6), // Teal
      budgetLimit: 200.0,
    ),
    ExpenseCategory(
      id: 'other',
      name: 'General / Other',
      icon: Icons.category_rounded,
      color: Color(0xFF64748B), // Slate
    ),
  ];

  // Curated icon palette for custom categories
  static const List<IconData> availableIcons = [
    Icons.restaurant_rounded,
    Icons.local_cafe_rounded,
    Icons.shopping_bag_rounded,
    Icons.shopping_cart_rounded,
    Icons.directions_subway_rounded,
    Icons.directions_car_rounded,
    Icons.flight_takeoff_rounded,
    Icons.receipt_long_rounded,
    Icons.movie_filter_rounded,
    Icons.videogame_asset_rounded,
    Icons.favorite_rounded,
    Icons.fitness_center_rounded,
    Icons.spa_rounded,
    Icons.school_rounded,
    Icons.menu_book_rounded,
    Icons.pets_rounded,
    Icons.card_giftcard_rounded,
    Icons.home_rounded,
    Icons.computer_rounded,
    Icons.savings_rounded,
    Icons.bolt_rounded,
    Icons.category_rounded,
  ];

  // Curated color palette for custom categories
  static const List<Color> availableColors = [
    Color(0xFF10B981), // Emerald
    Color(0xFF06B6D4), // Cyan
    Color(0xFF3B82F6), // Blue
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
    Color(0xFFF43F5E), // Rose
    Color(0xFFEF4444), // Red
    Color(0xFFF97316), // Orange
    Color(0xFFEAB308), // Amber / Yellow
    Color(0xFF14B8A6), // Teal
    Color(0xFF64748B), // Slate
  ];

  static ExpenseCategory getById(String id, {List<ExpenseCategory>? customCategories}) {
    if (customCategories != null) {
      final found = customCategories.where((c) => c.id == id).toList();
      if (found.isNotEmpty) return found.first;
    }
    return defaultCategories.firstWhere(
      (cat) => cat.id == id,
      orElse: () => defaultCategories.last,
    );
  }
}
