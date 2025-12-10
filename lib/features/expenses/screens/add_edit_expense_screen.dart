import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/expense_model.dart';
import '../models/category_model.dart';
import '../providers/expenses_provider.dart';
import '../providers/expense_form_provider.dart';

class AddEditExpenseScreen extends StatefulWidget {
  final String? expenseId;
  const AddEditExpenseScreen({super.key, this.expenseId});

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    final formProvider = context.read<ExpenseFormProvider>();
    if (widget.expenseId != formProvider.expenseId) {
      if (widget.expenseId != null) {
        final expense = context.read<ExpensesProvider>().expenses.firstWhere(
          (e) => e.id == widget.expenseId,
          orElse: () => throw Exception('Expense not found'),
        );
        formProvider.init(expense);
      } else {
        formProvider.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expenseId == null ? 'New Expense' : 'Edit Expense'),
        actions: [
          Consumer<ExpenseFormProvider>(
            builder: (context, form, _) => IconButton(
              icon: Icon(
                Icons.check,
                color: form.isValid ? Colors.white : Colors.grey,
              ),
              onPressed: form.isValid ? () => _saveExpense(context) : null,
            ),
          ),
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
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
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
                    DropdownMenuItem(
                      value: 'transfer',
                      child: Text('Transfer'),
                    ),
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
        child: Builder(
          builder: (context) {
            final form = context.watch<ExpenseFormProvider>();
            return ElevatedButton(
              onPressed: form.isValid ? () => _saveExpense(context) : null,
              child: const Text('Save Expense'),
            );
          },
        ),
      ),
    );
  }

  Future<void> _saveExpense(BuildContext context) async {
    final form = context.read<ExpenseFormProvider>();
    final amountText = form.amountController.text;
    final description = form.descriptionController.text;

    // Validation
    if (amountText.isEmpty ||
        double.tryParse(amountText) == null ||
        double.parse(amountText) <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid amount')));
      return;
    }
    if (description.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Description must be at least 3 chars')),
      );
      return;
    }

    final provider = context.read<ExpensesProvider>();
    final authProvider = context.read<AuthProvider>();

    try {
      if (widget.expenseId == null) {
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
          id: widget.expenseId!,
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
