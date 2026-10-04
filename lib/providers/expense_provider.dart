import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/category.dart';
import '../models/expense.dart';

class ExpenseProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Expense> _expenses = [];
  List<ExpenseCategory> _categories = List.from(ExpenseCategory.defaultCategories);
  double _monthlyBudget = 2000.0;
  DateTime _selectedMonth = DateTime.now();
  String? _selectedCategoryFilter;
  bool _isLoading = false;

  ExpenseProvider() {
    _initData();
  }

  // Getters
  List<Expense> get allExpenses => _expenses;
  List<ExpenseCategory> get categories => _categories;
  double get monthlyBudget => _monthlyBudget;
  DateTime get selectedMonth => _selectedMonth;
  String? get selectedCategoryFilter => _selectedCategoryFilter;
  bool get isLoading => _isLoading;

  // Filtered expenses by selected month and category
  List<Expense> get expenses {
    return _expenses.where((expense) {
      final matchesMonth = expense.date.year == _selectedMonth.year &&
          expense.date.month == _selectedMonth.month;
      if (!matchesMonth) return false;

      if (_selectedCategoryFilter != null) {
        return expense.categoryId == _selectedCategoryFilter;
      }
      return true;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Total spent in selected month
  double get totalSpent {
    return _expenses
        .where((e) =>
            e.date.year == _selectedMonth.year &&
            e.date.month == _selectedMonth.month)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  // Total spent for a specific category in selected month
  double getCategoryTotal(String categoryId) {
    return _expenses
        .where((e) =>
            e.categoryId == categoryId &&
            e.date.year == _selectedMonth.year &&
            e.date.month == _selectedMonth.month)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  // Lookup category by id
  ExpenseCategory getCategory(String id) {
    return ExpenseCategory.getById(id, customCategories: _categories);
  }

  // ================= ASYNC DATABASE OPERATIONS =================

  Future<void> _initData() async {
    _isLoading = true;
    try {
      final dbCategories = await _db.getAllCategories();
      if (dbCategories.isNotEmpty) {
        _categories = dbCategories;
      }

      final dbExpenses = await _db.getAllExpenses();
      if (dbExpenses.isNotEmpty) {
        _expenses = dbExpenses;
      }

      _monthlyBudget = await _db.getMonthlyBudget();
    } catch (e) {
      debugPrint('Local SQLite init notice (using in-memory data): $e');
      if (_expenses.isEmpty) {
        _populateFallbackData();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addExpense(Expense expense) async {
    try {
      final id = await _db.insertExpense(expense);
      final newExpense = expense.copyWith(id: id);
      _expenses.insert(0, newExpense);
    } catch (e) {
      debugPrint('Error writing expense to SQLite: $e');
      final fallbackExpense = expense.copyWith(
        id: expense.id ?? DateTime.now().millisecondsSinceEpoch,
      );
      _expenses.insert(0, fallbackExpense);
    }
    notifyListeners();
  }

  Future<void> updateExpense(Expense updated) async {
    final index = _expenses.indexWhere((e) => e.id == updated.id);
    if (index != -1) {
      _expenses[index] = updated;
      notifyListeners();
    }
    try {
      await _db.updateExpense(updated);
    } catch (e) {
      debugPrint('Error updating expense in SQLite: $e');
    }
  }

  Future<void> deleteExpense(int id) async {
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
    try {
      await _db.deleteExpense(id);
    } catch (e) {
      debugPrint('Error deleting expense from SQLite: $e');
    }
  }

  Future<void> addCategory(ExpenseCategory category) async {
    _categories.add(category);
    notifyListeners();
    try {
      await _db.insertCategory(category);
    } catch (e) {
      debugPrint('Error saving category to SQLite: $e');
    }
  }

  Future<void> deleteCategory(String id) async {
    _categories.removeWhere((c) => c.id == id && c.isCustom);
    if (_selectedCategoryFilter == id) {
      _selectedCategoryFilter = null;
    }
    notifyListeners();
    try {
      await _db.deleteCategory(id);
    } catch (e) {
      debugPrint('Error deleting category from SQLite: $e');
    }
  }

  Future<void> setMonthlyBudget(double amount) async {
    _monthlyBudget = amount;
    notifyListeners();
    try {
      await _db.setMonthlyBudget(amount);
    } catch (e) {
      debugPrint('Error persisting budget to SQLite: $e');
    }
  }

  void filterByCategory(String? categoryId) {
    if (_selectedCategoryFilter == categoryId) {
      _selectedCategoryFilter = null;
    } else {
      _selectedCategoryFilter = categoryId;
    }
    notifyListeners();
  }

  void changeMonth(DateTime newMonth) {
    _selectedMonth = newMonth;
    notifyListeners();
  }

  /// Direct SQLite GROUP BY aggregation query
  Future<Map<String, double>> fetchMonthlyAggregationFromDb(DateTime month) async {
    try {
      return await _db.getMonthlyCategoryAggregation(month);
    } catch (e) {
      debugPrint('Notice: falling back to calculated aggregations: $e');
      final Map<String, double> map = {};
      for (final exp in expenses) {
        map[exp.categoryId] = (map[exp.categoryId] ?? 0.0) + exp.amount;
      }
      return map;
    }
  }

  void _populateFallbackData() {
    final now = DateTime.now();
    _expenses = [
      Expense(
        id: 1,
        title: 'Weekly Supermarket Groceries',
        amount: 84.50,
        categoryId: 'food',
        date: now.subtract(const Duration(hours: 4)),
        notes: 'Organic fruits, vegetables and milk',
      ),
      Expense(
        id: 2,
        title: 'Monthly Electric & Water Bill',
        amount: 125.00,
        categoryId: 'bills',
        date: now.subtract(const Duration(days: 1)),
        notes: 'Utility payment for current month',
      ),
      Expense(
        id: 3,
        title: 'Gas Station Refill',
        amount: 55.20,
        categoryId: 'transport',
        date: now.subtract(const Duration(days: 2)),
        notes: 'Full tank unleaded',
      ),
      Expense(
        id: 4,
        title: 'Cinema & Popcorn',
        amount: 32.00,
        categoryId: 'entertainment',
        date: now.subtract(const Duration(days: 3)),
        notes: 'Weekend movie with friends',
      ),
      Expense(
        id: 5,
        title: 'Running Shoes Sale',
        amount: 110.00,
        categoryId: 'shopping',
        date: now.subtract(const Duration(days: 4)),
        notes: 'New training shoes',
      ),
    ];
  }
}
