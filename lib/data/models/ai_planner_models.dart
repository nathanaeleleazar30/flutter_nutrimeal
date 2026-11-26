import 'package:flutter/material.dart';
import '../../controllers/menu_controller.dart';

class AiPlannerRequest {
  final String eventType;
  final int pax;
  final int budget;
  final String tastePreference;
  final DateTime? eventDate;

  AiPlannerRequest({
    required this.eventType,
    required this.pax,
    required this.budget,
    this.tastePreference = 'Semua',
    this.eventDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'event_type': eventType,
      'pax': pax,
      'budget': budget,
      'taste_preference': tastePreference,
      'date': eventDate?.toIso8601String(),
    };
  }
}

class AiPlannedItem {
  final MenuItem meal;
  int quantity;
  final int unitPrice;
  int get totalPrice => quantity * unitPrice;

  AiPlannedItem({
    required this.meal,
    required this.quantity,
    required this.unitPrice,
  });

  factory AiPlannedItem.fromJson(Map<String, dynamic> json, {String? baseUrl}) {
    final mealJson = json['meal'] as Map<String, dynamic>? ?? {};
    final parsedMeal = MenuItem.fromJson(mealJson, baseUrl: baseUrl);
    final qty = int.tryParse(json['quantity']?.toString() ?? '1') ?? 1;
    final unitPrc =
        int.tryParse(json['unit_price']?.toString() ?? '${parsedMeal.price}') ??
        parsedMeal.price;

    return AiPlannedItem(meal: parsedMeal, quantity: qty, unitPrice: unitPrc);
  }

  AiPlannedItem copyWith({MenuItem? meal, int? quantity, int? unitPrice}) {
    return AiPlannedItem(
      meal: meal ?? this.meal,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }
}

class AiPlannedPackage {
  final String id;
  final String name;
  final String tier;
  final String tagline;
  final String badge;
  final Color badgeColor;
  int totalCost;
  int pricePerPax;
  int budgetRemaining;
  final int avgCalories;
  final List<AiPlannedItem> items;

  AiPlannedPackage({
    required this.id,
    required this.name,
    required this.tier,
    required this.tagline,
    required this.badge,
    required this.badgeColor,
    required this.totalCost,
    required this.pricePerPax,
    required this.budgetRemaining,
    required this.avgCalories,
    required this.items,
  });

  factory AiPlannedPackage.fromJson(
    Map<String, dynamic> json, {
    String? baseUrl,
    int totalBudget = 0,
    int pax = 1,
  }) {
    final rawColor = json['badge_color']?.toString() ?? '#10B981';
    Color parsedColor = const Color(0xFF10B981);
    try {
      final hex = rawColor.replaceAll('#', '');
      if (hex.length == 6) {
        parsedColor = Color(int.parse('FF$hex', radix: 16));
      }
    } catch (_) {}

    final rawItems = (json['items'] as List<dynamic>?) ?? [];
    final parsedItems = rawItems
        .map(
          (it) => AiPlannedItem.fromJson(
            it as Map<String, dynamic>,
            baseUrl: baseUrl,
          ),
        )
        .toList();

    final totCost = int.tryParse(json['total_cost']?.toString() ?? '0') ?? 0;
    final prcPax = int.tryParse(json['price_per_pax']?.toString() ?? '0') ?? 0;
    final bRem =
        int.tryParse(json['budget_remaining']?.toString() ?? '0') ??
        (totalBudget - totCost);
    final cals = int.tryParse(json['avg_calories']?.toString() ?? '450') ?? 450;

    return AiPlannedPackage(
      id: json['id']?.toString() ?? 'pkg-opt',
      name: json['name']?.toString() ?? 'Paket Pilihan AI',
      tier: json['tier']?.toString() ?? 'seimbang',
      tagline:
          json['tagline']?.toString() ??
          'Kombinasi menu katering sehat optimal',
      badge: json['badge']?.toString() ?? 'Rekomendasi AI',
      badgeColor: parsedColor,
      totalCost: totCost,
      pricePerPax: prcPax,
      budgetRemaining: bRem > 0 ? bRem : 0,
      avgCalories: cals,
      items: parsedItems,
    );
  }

  void recalculate(int totalBudget, int pax) {
    totalCost = items.fold(0, (sum, it) => sum + it.totalPrice);
    pricePerPax = pax > 0 ? (totalCost / pax).round() : totalCost;
    budgetRemaining = totalBudget - totalCost;
  }
}
