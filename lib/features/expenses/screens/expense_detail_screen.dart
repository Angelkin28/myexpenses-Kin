import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expense_model.dart';
import '../models/category_model.dart';
import '../providers/expenses_provider.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final String expenseId;

  const ExpenseDetailScreen({super.key, required this.expenseId});

  @override
  Widget build(BuildContext context) {
    // Find expense from provider
    // Note: If navigating directly to a deep link, this might fail if list not loaded.
    // For now assume loaded from Home.
    
    // Using select or watch on the list
    final expense = context.select<ExpensesProvider, Expense?>(
      (p) {
        try {
          return p.expenses.firstWhere((e) => e.id == expenseId);
        } catch (e) {
          return null;
        }
      }
    );

    if (expense == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Details')),
        body: const Center(child: Text('Expense not found')),
      );
    }

    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
               context.push('/edit-expense/$expenseId');
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Expense?'),
                  content: const Text('This action cannot be undone.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                await context.read<ExpensesProvider>().deleteExpense(expenseId);
                if (context.mounted) context.pop();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Header Card
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: expense.category.color.withOpacity(0.2),
                    child: Icon(expense.category.icon, size: 40, color: expense.category.color),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currencyFormat.format(expense.amount),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    expense.description,
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Details Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _DetailRow(label: 'Category', value: expense.category.name),
                    const Divider(),
                    _DetailRow(label: 'Date', value: DateFormat.yMMMd().format(expense.date)),
                    const Divider(),
                    _DetailRow(label: 'Payment Method', value: expense.paymentMethod.toUpperCase()),
                    const Divider(),
                    _DetailRow(
                      label: 'Created At', 
                      value: expense.createdAt != null 
                        ? DateFormat.yMMMd().add_Hm().format(expense.createdAt!) 
                        : 'Unknown'
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
