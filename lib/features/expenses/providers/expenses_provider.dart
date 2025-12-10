import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';
import '../models/category_model.dart';
import '../repositories/expenses_repository.dart';

class ExpensesProvider extends ChangeNotifier {
  final ExpensesRepository _repository = ExpensesRepository();
  
  List<Expense> _allExpenses = [];
  List<Expense> _filteredExpenses = [];
  
  bool _isLoading = false;
  String? _error;

  // Filters
  String _searchQuery = '';
  ExpenseCategory? _selectedCategory;
  DateTimeRange? _dateRange; // From - To

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Expense> get expenses => _filteredExpenses;

  // Getters for Stats
  double get totalForMonth {
    final now = DateTime.now();
    return _allExpenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalForDay {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    return _allExpenses
        .where((e) => DateFormat('yyyy-MM-dd').format(e.date) == today)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  Future<void> loadExpenses() async {
    _isLoading = true;
    _error = null;
    notifyListeners(); // Careful with build phase, typically safe if called from init or interaction

    try {
      _allExpenses = await _repository.getExpenses();
      _applyFilters();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addExpense(Expense expense) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.createExpense(expense);
      await loadExpenses(); // Reload to get fresh data/IDs
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateExpense(Expense expense) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.updateExpense(expense);
      await loadExpenses();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteExpense(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.deleteExpense(id);
      await loadExpenses(); // could optimize to just remove locally
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filter Logic
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setCategoryFilter(ExpenseCategory? category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void setDateRangeFilter(DateTimeRange? range) {
    _dateRange = range;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredExpenses = _allExpenses.where((e) {
      bool matchesSearch = _searchQuery.isEmpty || 
          e.description.toLowerCase().contains(_searchQuery.toLowerCase());
      
      bool matchesCategory = _selectedCategory == null || e.category == _selectedCategory;
      
      bool matchesDate = _dateRange == null || 
          (e.date.isAfter(_dateRange!.start.subtract(const Duration(days: 1))) && 
           e.date.isBefore(_dateRange!.end.add(const Duration(days: 1))));

      return matchesSearch && matchesCategory && matchesDate;
    }).toList();
  }
  
  Map<String, List<Expense>> get groupedExpenses {
    final groups = <String, List<Expense>>{};
    for (var expense in _filteredExpenses) {
      final dateKey = DateFormat('yyyy-MM-dd').format(expense.date);
      if (groups[dateKey] == null) groups[dateKey] = [];
      groups[dateKey]!.add(expense);
    }
    return groups;
  }
}
