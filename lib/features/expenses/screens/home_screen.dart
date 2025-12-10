import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../providers/expenses_provider.dart';
import '../models/expense_model.dart';
import '../models/category_model.dart';
import '../../auth/providers/auth_provider.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../providers/expenses_provider.dart';
import '../models/expense_model.dart';
import '../models/category_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../../../shared/widgets/lottie_loader.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initial Load - Idempotent check
    // Ideally this should be run once. With Stateless, we can assume
    // that if the list is empty AND not loading, we fetch.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<ExpensesProvider>();
      if (!p.isLoading && p.expenses.isEmpty && p.error == null) {
        // This check is rudimentary, ideally store "isLoaded" flag
        p.loadExpenses(); 
      }
    });

    final expensesProvider = context.watch<ExpensesProvider>();
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('MyExpenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // TODO: Navigate to Profile
              // For now logout to test
              context.read<AuthProvider>().logout();
              context.go('/login');
            },
          )
        ],
      ),
      body: expensesProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Summary Cards
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          title: 'This Month',
                          amount: expensesProvider.totalForMonth,
                          color: Theme.of(context).colorScheme.primary,
                          icon: Icons.calendar_month,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _SummaryCard(
                          title: 'Today',
                          amount: expensesProvider.totalForDay,
                          color: Theme.of(context).colorScheme.secondary,
                          icon: Icons.today,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Filters & Search Bar (Simple version)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search expenses...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.filter_list),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (_) => const FilterBottomSheet(),
                          );
                        },
                      ),
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) {
                      context.read<ExpensesProvider>().setSearchQuery(val);
                    },
                  ),
                ),
                
                const SizedBox(height: 16),

                // List
                Expanded(
                  child: expensesProvider.expenses.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              LottieLoader(
                                assetName: 'empty_state.json',
                                fallback: const Icon(Icons.inbox, size: 100, color: Colors.grey),
                              ),
                              const SizedBox(height: 16),
                              const Text('No expenses found'),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: expensesProvider.groupedExpenses.keys.length,
                          itemBuilder: (context, index) {
                            final dateKey = expensesProvider.groupedExpenses.keys.elementAt(index);
                            final expenses = expensesProvider.groupedExpenses[dateKey]!;
                            final totalForGroup = expenses.fold(0.0, (sum, e) => sum + e.amount);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        DateFormat.yMMMd().format(DateTime.parse(dateKey)),
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      Text(
                                        currencyFormat.format(totalForGroup),
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ...expenses.map((expense) => _ExpenseTile(expense: expense)),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-expense'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Card(
      elevation: 4,
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white70, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              currencyFormat.format(amount),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final Expense expense;

  const _ExpenseTile({required this.expense});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog(
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
      },
      onDismissed: (_) {
         context.read<ExpensesProvider>().deleteExpense(expense.id);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: expense.category.color.withOpacity(0.2),
            child: Icon(expense.category.icon, color: expense.category.color),
          ),
          title: Text(
            expense.description,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(expense.category.name),
          trailing: Text(
            currencyFormat.format(expense.amount),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: expense.category.color,
              fontSize: 16,
            ),
          ),
          onTap: () => context.push('/expense/${expense.id}'), // Detail or Edit
          // Ideally push to /edit-expense or detail. Let's send to Detail.
        ),
      ),
    );
  }
}
