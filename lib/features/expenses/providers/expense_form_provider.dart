import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../models/category_model.dart';

class ExpenseFormProvider extends ChangeNotifier {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  
  ExpenseCategory _selectedCategory = ExpenseCategory.food;
  String _paymentMethod = 'cash';
  DateTime _selectedDate = DateTime.now();
  String? _expenseId;

  ExpenseCategory get selectedCategory => _selectedCategory;
  String get paymentMethod => _paymentMethod;
  DateTime get selectedDate => _selectedDate;
  String? get expenseId => _expenseId;

  bool get isValid {
    final amount = double.tryParse(amountController.text);
    final description = descriptionController.text;
    return amount != null && amount > 0 && description.length >= 3;
  }

  void init(Expense? expense) {
    if (expense != null) {
      _expenseId = expense.id;
      amountController.text = expense.amount.toString();
      descriptionController.text = expense.description;
      _selectedCategory = expense.category;
      _paymentMethod = expense.paymentMethod;
      _selectedDate = expense.date;
    } else {
      reset();
    }
    // Listen to changes to update isValid
    amountController.addListener(notifyListeners);
    descriptionController.addListener(notifyListeners);
    notifyListeners();
  }

  void reset() {
    _expenseId = null;
    amountController.clear();
    descriptionController.clear();
    _selectedCategory = ExpenseCategory.food;
    _paymentMethod = 'cash';
    _selectedDate = DateTime.now();
  }

  void setCategory(ExpenseCategory category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  @override
  void dispose() {
    amountController.removeListener(notifyListeners);
    descriptionController.removeListener(notifyListeners);
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
