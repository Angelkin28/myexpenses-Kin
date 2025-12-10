import 'package:flutter/material.dart';

enum ExpenseCategory {
  food,
  transport,
  entertainment,
  health,
  services,
  education,
  others
}

extension CategoryExtension on ExpenseCategory {
  String get name {
    switch (this) {
      case ExpenseCategory.food: return 'Alimentación';
      case ExpenseCategory.transport: return 'Transporte';
      case ExpenseCategory.entertainment: return 'Entretenimiento';
      case ExpenseCategory.health: return 'Salud';
      case ExpenseCategory.services: return 'Servicios';
      case ExpenseCategory.education: return 'Educación';
      case ExpenseCategory.others: return 'Otros';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseCategory.food: return Icons.restaurant;
      case ExpenseCategory.transport: return Icons.directions_bus;
      case ExpenseCategory.entertainment: return Icons.movie;
      case ExpenseCategory.health: return Icons.local_hospital;
      case ExpenseCategory.services: return Icons.lightbulb;
      case ExpenseCategory.education: return Icons.school;
      case ExpenseCategory.others: return Icons.more_horiz;
    }
  }

  Color get color {
    switch (this) {
      case ExpenseCategory.food: return Colors.orange;
      case ExpenseCategory.transport: return Colors.blue;
      case ExpenseCategory.entertainment: return Colors.purple;
      case ExpenseCategory.health: return Colors.red;
      case ExpenseCategory.services: return Colors.yellow[700]!;
      case ExpenseCategory.education: return Colors.green;
      case ExpenseCategory.others: return Colors.grey;
    }
  }

  static ExpenseCategory fromString(String val) {
    return ExpenseCategory.values.firstWhere(
      (e) => e.name == val, // Matches the display name stored in DB?? Or should we store keys?
      // The prompt says "Categorías Predefinidas: Alimentación..." 
      // It's better to store the English key or the Display name. 
      // Given "Las categorías NO se almacenan en BD" is confusing. It usually means the *list of options* is not in a separate table.
      // But the *value* selected must be in the `expenses` table.
      // Let's store the string representation of the Enum value (e.g. 'food') or the display name.
      // To be safe and simple, let's store the Enum Name (key) 'food', 'transport' etc.
      // But the prompt example categories look capitalized. I'll store the Simple English Key 'food' in DB for robustness.
      orElse: () => ExpenseCategory.others,
    );
  }
}
