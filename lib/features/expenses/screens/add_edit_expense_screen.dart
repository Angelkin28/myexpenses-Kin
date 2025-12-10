import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/expense_model.dart';
import '../models/category_model.dart';
import '../providers/expenses_provider.dart';
import '../providers/expense_form_provider.dart';

class AddEditExpenseScreen extends StatelessWidget {
  final String? expenseId;
  const AddEditExpenseScreen({super.key, this.expenseId});

  @override
  Widget build(BuildContext context) {
    // Initialize form when navigating
    // Using a microtask or just relying on the fact that this is built once
    // A better pattern for StatelessWidget init is confusing in Flutter without hooks/init state.
    // We can check if the form is dirty or matches current ID.
    // For simplicity, we initialize on every build if ID changed?. 
    // ACTUALLY: The cleanest way without StatefulWidget is using a "Builder" that inits logic,
    // OR just accepting that we init it via the Router builder callback? 
    // GoRouter builder is a good place, but we don't have context easily there.
    
    // Let's use a PostFrameCallback workaround inside build? No, that loops.
    // We will initialize it ONLY if the ID in provider doesn't match the widget ID.
    
    final formProvider = context.read<ExpenseFormProvider>();
    // If expenseId is null and provider.id is not null -> Reset
    // If expenseId is X and provider.id is not X -> Load X
    
    // NOTE: This logic inside build is "okay" given constraints but ideally logic belongs in router.
    // Let's assume the user navigates here, we trigger a "reset/load" before pushing?
    // Hard to do with declarative routes perfectly.
    // We'll leave the init logic to the caller or do a safe check here.
    
    if (expenseId != formProvider.expenseId) {
       // Need to defer this update
       WidgetsBinding.instance.addPostFrameCallback((_) {
         if (expenseId != null) {
            final expense = context.read<ExpensesProvider>().expenses.firstWhere(
              (e) => e.id == expenseId,
              orElse: () => throw Exception('Not found'),
            );
            context.read<ExpenseFormProvider>().init(expense);
         } else {
            context.read<ExpenseFormProvider>().reset();
         }
       });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(expenseId == null ? 'New Expense' : 'Edit Expense'),
        actions: [
          Consumer<ExpenseFormProvider>(
            builder: (context, form, _) => IconButton(
              icon: Icon(Icons.check, color: form.isValid ? Colors.white : Colors.grey),
              onPressed: form.isValid ? () => _saveExpense(context) : null,
            ),
          )
        ],
      ),
      body: Consumer<ExpenseFormProvider>(
        builder: (context, form, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Amount
                TextFormField(
                  controller: form.amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '\$ ',
                  ),
                ),
                const SizedBox(height: 16),
                
                // Description
                TextFormField(
                  controller: form.descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Category Dropdown
                DropdownButtonFormField<ExpenseCategory>(
                  value: form.selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: ExpenseCategory.values.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Row(
                        children: [
                          Icon(cat.icon, color: cat.color, size: 20),
                          const SizedBox(width: 8),
                          Text(cat.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    form.setCategory(val!);
                  },
                ),
                const SizedBox(height: 16),
                
                // Payment Method
                DropdownButtonFormField<String>(
                  value: form.paymentMethod,
                  decoration: const InputDecoration(
                    labelText: 'Payment Method',
                    prefixIcon: Icon(Icons.payment),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'cash', child: Text('Cash')),
                    DropdownMenuItem(value: 'card', child: Text('Card')),
                    DropdownMenuItem(value: 'transfer', child: Text('Transfer')),
                  ],
                  onChanged: (val) {
                    form.setPaymentMethod(val!);
                  },
                ),
                const SizedBox(height: 16),
                
                // Date Picker
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: form.selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      form.setDate(picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(DateFormat.yMMMEd().format(form.selectedDate)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: form.isValid ? () => _saveExpense(context) : null,
          child: const Text('Save Expense'),
        ),
      ),
    );
  }

  Future<void> _saveExpense(BuildContext context) async {
    final form = context.read<ExpenseFormProvider>();
    final amountText = form.amountController.text;
    final description = form.descriptionController.text;

    // Validation
    if (amountText.isEmpty || double.tryParse(amountText) == null || double.parse(amountText) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid amount')));
      return;
    }
    if (description.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Description must be at least 3 chars')));
      return;
    }

    final provider = context.read<ExpensesProvider>();
    final authProvider = context.read<AuthProvider>();

    try {
      if (expenseId == null) {
        // Create
        final newExpense = Expense(
          id: '',
          userId: authProvider.user?.id,
          amount: double.parse(amountText),
          description: description,
          category: form.selectedCategory,
          paymentMethod: form.paymentMethod,
          date: form.selectedDate,
        );
        await provider.addExpense(newExpense);
      } else {
        // Edit
        final updatedExpense = Expense(
          id: expenseId!,
          userId: authProvider.user?.id,
          amount: double.parse(amountText),
          description: description,
          category: form.selectedCategory,
          paymentMethod: form.paymentMethod,
          date: form.selectedDate,
        );
        await provider.updateExpense(updatedExpense);
      }
      
      if (context.mounted) context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
