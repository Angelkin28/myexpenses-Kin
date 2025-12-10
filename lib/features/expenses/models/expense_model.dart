import 'category_model.dart';
import 'package:intl/intl.dart';

class Expense {
  final String id;
  final String? userId;
  final double amount;
  final String description;
  final ExpenseCategory category;
  final String paymentMethod; // 'cash', 'card', 'transfer'
  final DateTime date;
  final DateTime? createdAt;

  Expense({
    required this.id,
    this.userId,
    required this.amount,
    required this.description,
    required this.category,
    required this.paymentMethod,
    required this.date,
    this.createdAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    // Parse category from string key
    // If we stored 'Alimentación' directly, adjust accordingly.
    // I will assume we store the key 'food' etc.
    ExpenseCategory cat = ExpenseCategory.values.firstWhere(
      (e) => e.toString().split('.').last == json['category'],
      orElse: () => ExpenseCategory.others,
    );

    return Expense(
      id: json['id'],
      userId: json['user_id'],
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] ?? '',
      category: cat,
      paymentMethod: json['payment_method'] ?? 'cash',
      date: DateTime.parse(json['expense_date']),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // Don't send ID on create, Supabase generates it.
      // But we might need it for update.
      'amount': amount,
      'description': description,
      'category': category.toString().split('.').last,
      'payment_method': paymentMethod,
      'expense_date': DateFormat('yyyy-MM-dd').format(date),
    };
  }
}
