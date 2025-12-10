import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expense_model.dart';
import '../models/category_model.dart';
import '../providers/expenses_provider.dart';

class AddEditExpenseScreen extends StatefulWidget {
  final String? expenseId;
  const AddEditExpenseScreen({super.key, this.expenseId});

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  ExpenseCategory _selectedCategory = ExpenseCategory.food;
  String _paymentMethod = 'cash';
  DateTime _selectedDate = DateTime.now();
  
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit && widget.expenseId != null) {
      final expense = context.read<ExpensesProvider>().expenses.firstWhere(
            (e) => e.id == widget.expenseId,
            orElse: () => throw Exception('Expense not found'), // Should handle better
          );
      
      _amountController.text = expense.amount.toString();
      _descriptionController.text = expense.description;
      _selectedCategory = expense.category;
      _paymentMethod = expense.paymentMethod;
      _selectedDate = expense.date;
    }
    _isInit = false;
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ExpensesProvider>();
    final amount = double.parse(_amountController.text);
    final description = _descriptionController.text;

    try {
      if (widget.expenseId == null) {
        // Create
        final newExpense = Expense(
          id: '', // Supabase generates this
          amount: amount,
          description: description,
          category: _selectedCategory,
          paymentMethod: _paymentMethod,
          date: _selectedDate,
        );
        await provider.addExpense(newExpense);
      } else {
        // Edit
        final updatedExpense = Expense(
          id: widget.expenseId!,
          amount: amount,
          description: description,
          category: _selectedCategory,
          paymentMethod: _paymentMethod,
          date: _selectedDate,
        );
        await provider.updateExpense(updatedExpense);
      }
      
      if (mounted) context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expenseId == null ? 'New Expense' : 'Edit Expense'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveExpense,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$ ',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter amount';
                  if (double.tryParse(value) == null) return 'Invalid number';
                  if (double.parse(value) <= 0) return 'Amount must be > 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.length < 3) return 'At least 3 chars';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Category Dropdown
              DropdownButtonFormField<ExpenseCategory>(
                value: _selectedCategory,
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
                  setState(() => _selectedCategory = val!);
                },
              ),
              const SizedBox(height: 16),
              
              // Payment Method
              DropdownButtonFormField<String>(
                value: _paymentMethod,
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
                  setState(() => _paymentMethod = val!);
                },
              ),
              const SizedBox(height: 16),
              
              // Date Picker
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(DateFormat.yMMMEd().format(_selectedDate)),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _saveExpense,
          child: const Text('Save Expense'),
        ),
      ),
    );
  }
}
